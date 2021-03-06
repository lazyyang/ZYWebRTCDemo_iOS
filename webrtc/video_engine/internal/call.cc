/*
 *  Copyright (c) 2013 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "webrtc/video_engine/internal/call.h"

#include <assert.h>
#include <string.h>

#include <map>
#include <vector>

#include "webrtc/system_wrappers/interface/critical_section_wrapper.h"
#include "webrtc/system_wrappers/interface/scoped_ptr.h"
#include "webrtc/system_wrappers/interface/trace.h"
#include "webrtc/video_engine/include/vie_base.h"
#include "webrtc/video_engine/include/vie_codec.h"
#include "webrtc/video_engine/include/vie_rtp_rtcp.h"
#include "webrtc/video_engine/internal/video_receive_stream.h"
#include "webrtc/video_engine/internal/video_send_stream.h"

namespace webrtc {

class TraceDispatcher : public TraceCallback {
 public:
  TraceDispatcher()
      : crit_(CriticalSectionWrapper::CreateCriticalSection()),
        initialized_(false),
        filter_(kTraceNone) {}

  ~TraceDispatcher() {
    if (initialized_) {
      Trace::ReturnTrace();
      VideoEngine::SetTraceCallback(NULL);
    }
  }

  virtual void Print(TraceLevel level,
                     const char* message,
                     int length) OVERRIDE {
    CriticalSectionScoped lock(crit_.get());
    for (std::map<Call*, Call::Config*>::iterator it = callbacks_.begin();
         it != callbacks_.end();
         ++it) {
      if ((level & it->second->trace_filter) != kTraceNone)
        it->second->trace_callback->Print(level, message, length);
    }
  }

  void RegisterCallback(Call* call, Call::Config* config) {
    if (config->trace_callback == NULL)
      return;

    CriticalSectionScoped lock(crit_.get());
    callbacks_[call] = config;

    filter_ |= config->trace_filter;
    if (filter_ != kTraceNone && !initialized_) {
      initialized_ = true;
      Trace::CreateTrace();
      VideoEngine::SetTraceCallback(this);
    }
    VideoEngine::SetTraceFilter(filter_);
  }

  void DeregisterCallback(Call* call) {
    CriticalSectionScoped lock(crit_.get());
    callbacks_.erase(call);

    filter_ = kTraceNone;
    for (std::map<Call*, Call::Config*>::iterator it = callbacks_.begin();
         it != callbacks_.end();
         ++it) {
      filter_ |= it->second->trace_filter;
    }

    VideoEngine::SetTraceFilter(filter_);
  }

 private:
  scoped_ptr<CriticalSectionWrapper> crit_;
  bool initialized_;
  unsigned int filter_;
  std::map<Call*, Call::Config*> callbacks_;
};

namespace internal {
  TraceDispatcher* global_trace_dispatcher = NULL;
}  // internal

Call* Call::Create(const Call::Config& config) {
  if (internal::global_trace_dispatcher == NULL) {
    TraceDispatcher* dispatcher = new TraceDispatcher();
    // TODO(pbos): Atomic compare and exchange.
    if (internal::global_trace_dispatcher == NULL) {
      internal::global_trace_dispatcher = dispatcher;
    } else {
      delete dispatcher;
    }
  }

  VideoEngine* video_engine = VideoEngine::Create();
  assert(video_engine != NULL);

  return new internal::Call(video_engine, config);
}

namespace internal {

Call::Call(webrtc::VideoEngine* video_engine, const Call::Config& config)
    : config_(config),
      receive_lock_(RWLockWrapper::CreateRWLock()),
      send_lock_(RWLockWrapper::CreateRWLock()),
      rtp_header_parser_(RtpHeaderParser::Create()),
      video_engine_(video_engine) {
  assert(video_engine != NULL);
  assert(config.send_transport != NULL);

  global_trace_dispatcher->RegisterCallback(this, &config_);

  rtp_rtcp_ = ViERTP_RTCP::GetInterface(video_engine_);
  assert(rtp_rtcp_ != NULL);

  codec_ = ViECodec::GetInterface(video_engine_);
  assert(codec_ != NULL);
}

Call::~Call() {
  global_trace_dispatcher->DeregisterCallback(this);
  codec_->Release();
  rtp_rtcp_->Release();
  webrtc::VideoEngine::Delete(video_engine_);
}

PacketReceiver* Call::Receiver() { return this; }

std::vector<VideoCodec> Call::GetVideoCodecs() {
  std::vector<VideoCodec> codecs;

  VideoCodec codec;
  for (size_t i = 0; i < static_cast<size_t>(codec_->NumberOfCodecs()); ++i) {
    if (codec_->GetCodec(i, codec) == 0) {
      codecs.push_back(codec);
    }
  }
  return codecs;
}

VideoSendStream::Config Call::GetDefaultSendConfig() {
  VideoSendStream::Config config;
  codec_->GetCodec(0, config.codec);
  return config;
}

VideoSendStream* Call::CreateSendStream(const VideoSendStream::Config& config) {
  assert(config.rtp.ssrcs.size() > 0);
  assert(config.codec.numberOfSimulcastStreams == 0 ||
         config.codec.numberOfSimulcastStreams == config.rtp.ssrcs.size());

  VideoSendStream* send_stream = new VideoSendStream(
      config_.send_transport, config_.overuse_detection, video_engine_, config);

  WriteLockScoped write_lock(*send_lock_);
  for (size_t i = 0; i < config.rtp.ssrcs.size(); ++i) {
    assert(send_ssrcs_.find(config.rtp.ssrcs[i]) == send_ssrcs_.end());
    send_ssrcs_[config.rtp.ssrcs[i]] = send_stream;
  }
  return send_stream;
}

SendStreamState* Call::DestroySendStream(webrtc::VideoSendStream* send_stream) {
  assert(send_stream != NULL);

  VideoSendStream* send_stream_impl = NULL;
  {
    WriteLockScoped write_lock(*send_lock_);
    for (std::map<uint32_t, VideoSendStream*>::iterator it =
             send_ssrcs_.begin();
         it != send_ssrcs_.end();
         ++it) {
      if (it->second == static_cast<VideoSendStream*>(send_stream)) {
        send_stream_impl = it->second;
        send_ssrcs_.erase(it);
        break;
      }
    }
  }

  assert(send_stream_impl != NULL);
  delete send_stream_impl;

  // TODO(pbos): Return its previous state
  return NULL;
}

VideoReceiveStream::Config Call::GetDefaultReceiveConfig() {
  return VideoReceiveStream::Config();
}

VideoReceiveStream* Call::CreateReceiveStream(
    const VideoReceiveStream::Config& config) {
  VideoReceiveStream* receive_stream =
      new VideoReceiveStream(video_engine_, config, config_.send_transport);

  WriteLockScoped write_lock(*receive_lock_);
  assert(receive_ssrcs_.find(config.rtp.ssrc) == receive_ssrcs_.end());
  receive_ssrcs_[config.rtp.ssrc] = receive_stream;
  return receive_stream;
}

void Call::DestroyReceiveStream(webrtc::VideoReceiveStream* receive_stream) {
  assert(receive_stream != NULL);

  VideoReceiveStream* receive_stream_impl = NULL;
  {
    WriteLockScoped write_lock(*receive_lock_);
    for (std::map<uint32_t, VideoReceiveStream*>::iterator it =
             receive_ssrcs_.begin();
         it != receive_ssrcs_.end();
         ++it) {
      if (it->second == static_cast<VideoReceiveStream*>(receive_stream)) {
        receive_stream_impl = it->second;
        receive_ssrcs_.erase(it);
        break;
      }
    }
  }

  assert(receive_stream_impl != NULL);
  delete receive_stream_impl;
}

uint32_t Call::SendBitrateEstimate() {
  // TODO(pbos): Return send-bitrate estimate
  return 0;
}

uint32_t Call::ReceiveBitrateEstimate() {
  // TODO(pbos): Return receive-bitrate estimate
  return 0;
}

bool Call::DeliverRtcp(const uint8_t* packet, size_t length) {
  // TODO(pbos): Figure out what channel needs it actually.
  //             Do NOT broadcast! Also make sure it's a valid packet.
  bool rtcp_delivered = false;
  {
    ReadLockScoped read_lock(*receive_lock_);
    for (std::map<uint32_t, VideoReceiveStream*>::iterator it =
             receive_ssrcs_.begin();
         it != receive_ssrcs_.end();
         ++it) {
      if (it->second->DeliverRtcp(packet, length))
        rtcp_delivered = true;
    }
  }

  {
    ReadLockScoped read_lock(*send_lock_);
    for (std::map<uint32_t, VideoSendStream*>::iterator it =
             send_ssrcs_.begin();
         it != send_ssrcs_.end();
         ++it) {
      if (it->second->DeliverRtcp(packet, length))
        rtcp_delivered = true;
    }
  }
  return rtcp_delivered;
}

bool Call::DeliverRtp(const RTPHeader& header,
                      const uint8_t* packet,
                      size_t length) {
  VideoReceiveStream* receiver;
  {
    ReadLockScoped read_lock(*receive_lock_);
    std::map<uint32_t, VideoReceiveStream*>::iterator it =
        receive_ssrcs_.find(header.ssrc);
    if (it == receive_ssrcs_.end()) {
      // TODO(pbos): Log some warning, SSRC without receiver.
      return false;
    }

    receiver = it->second;
  }
  return receiver->DeliverRtp(static_cast<const uint8_t*>(packet), length);
}

bool Call::DeliverPacket(const uint8_t* packet, size_t length) {
  // TODO(pbos): ExtensionMap if there are extensions.
  if (RtpHeaderParser::IsRtcp(packet, static_cast<int>(length)))
    return DeliverRtcp(packet, length);

  RTPHeader rtp_header;
  if (!rtp_header_parser_->Parse(packet, static_cast<int>(length), &rtp_header))
    return false;

  return DeliverRtp(rtp_header, packet, length);
}

}  // namespace internal
}  // namespace webrtc
