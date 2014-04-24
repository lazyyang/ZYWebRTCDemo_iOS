//
//  ZYWebRTCMediaEngineNative.h
//  ZYWebRTCDemo
//
//  Created by 杨争 on 4/12/14.
//  Copyright (c) 2014 SMIT. All rights reserved.
//

#ifndef __ZYWebRTCDemo__ZYWebRTCMediaEngineNative__
#define __ZYWebRTCDemo__ZYWebRTCMediaEngineNative__

#include <iostream>

#define VALIDATE_BASE_POINTER                                       \
if (!voeData.base)                                                  \
{                                                                   \
printf("Base pointer doesn't exist");                           \
return -1;                                                      \
}

#define VALIDATE_CODEC_POINTER                                      \
if (!voeData.codec)                                                 \
{                                                                   \
printf("Codec pointer doesn't exist");                          \
return -1;                                                      \
}
#define VALIDATE_FILE_POINTER                                       \
if (!voeData.file)                                                  \
{                                                                   \
printf("File pointer doesn't exist");                           \
return -1;                                                      \
}

#define VALIDATE_APM_POINTER                                        \
if (!voeData.codec)                                                 \
{                                                                   \
printf("Apm pointer doesn't exist");                            \
return -1;                                                      \
}

#define VALIDATE_HARDWARE_POINTER                                   \
if (!voeData.hardware)                                              \
{                                                                   \
printf("Hardware pointer doesn't exist");                       \
return -1;                                                      \
}

#define VALIDATE_VOLUME_POINTER                                     \
if (!voeData.volume)                                                \
{                                                                   \
printf("Volume pointer doesn't exist");                         \
return -1;                                                      \
}

#define VALIDATE_RTP_POINTER                                        \
if (!voeData.rtp)                                                   \
{                                                                   \
printf("rtp pointer doesn't exist");                            \
return -1;                                                      \
}


#include "webrtc/voice_engine/include/voe_audio_processing.h"
#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/voice_engine/include/voe_codec.h"
#include "webrtc/voice_engine/include/voe_file.h"
#include "webrtc/voice_engine/include/voe_hardware.h"
#include "webrtc/voice_engine/include/voe_network.h"
#include "webrtc/voice_engine/include/voe_rtp_rtcp.h"
#include "webrtc/voice_engine/include/voe_volume_control.h"

#include "webrtc/video_engine/include/vie_base.h"
#include "webrtc/video_engine/include/vie_capture.h"
#include "webrtc/video_engine/include/vie_codec.h"
#include "webrtc/video_engine/include/vie_external_codec.h"
#include "webrtc/video_engine/include/vie_network.h"
#include "webrtc/video_engine/include/vie_render.h"
#include "webrtc/video_engine/include/vie_rtp_rtcp.h"

#include "webrtc/common_types.h"

#include "webrtc/system_wrappers/interface/scoped_ptr.h"
#include "webrtc/test/channel_transport/include/channel_transport.h"

#include "webrtc/modules/video_render/ios/video_render_ios_view.h"

class VideoCallbackIOS;
using namespace webrtc;


typedef struct
{
    // VoiceEngine
    VoiceEngine* ve;
    // Sub-APIs
    VoEBase* base;
    VoECodec* codec;
    VoEFile* file;
    VoENetwork* netw;
    VoEAudioProcessing* apm;
    VoEVolumeControl* volume;
    VoEHardware* hardware;
    VoERTP_RTCP* rtp;
    scoped_ptr<test::VoiceChannelTransport> transport;
}   VoiceEngineData;


typedef struct
{
    //VideoEngine
    VideoEngine* vie;
    //Sub-APIs
    ViEBase* base;
    ViECodec* codec;
    ViENetwork* netw;
    ViERTP_RTCP* rtp;
    ViERender* render;
    ViECapture* capture;
    ViEExternalCodec* externalCodec;
    VideoCallbackIOS *callback;
    scoped_ptr<test::VideoChannelTransport> transport;
}   VideoEngineData;

class webrtc_native_api
{
private:
    VoiceEngineData voeData;
    VideoEngineData vieData;
    
    bool VE_GetSubApis();
    bool VE_ReleaseSubApis();
    
public:
    int Vie_SetCallback(int channel);//设置回调
    int getVideoEngine();
    bool VoE_Create();
    int Init(bool enableTrace);
    
    int VoE_Init(bool enableTrace);
    int VoE_CreateChannel();
    int VoE_SetLocalReceiver(int channel,int port);
    int VoE_StartListen(int channel);
    int VoE_SetLoudspeakerStatus(bool enable);
    int VoE_StartPlayout(int channel);
    int VoE_SetSendDestination(int channel,int port,const char* ipaddr);
    int VoE_SetSendCodec(int channel,int index);
    int VoE_SetECStatus(bool enable);
    int VoE_SetAGCStatus(bool enable);
    int VoE_SetNSStatus( bool enable);
    int VoE_StartSend( int channel);
    int VoE_SetSpeakerVolume(int level);
    bool VoE_Delete();
    
    int StartCamera(int channel,int cameraNum);
    int StopCamera(int cameraId);

    int StartSent(int channel);
    int SetRotation(int cameraID,int degrees);
    int setSendCodec(int channel,int codecType,int intBitRate,int width,int height,int frameRate);
    int CreateChannel(int voiceChannel);
    int SetLocalReceiver( int channel, int port, const char* multicastIpAddr);
    int SetSendDestination(int channel,int port,const char * ipaddr);
    int SetReceiveCodec( int channel, int codecNum,int intbitRate,int width,int height,int frameRate);
    int StartRender(int channel);
    int StartReceive(int channel);
    /*stop voiceengine*/
    int VoE_StopSend(int channel);
    int VoE_StopListen(int channel);
    int VoE_StopPlayout(int channel);
    int VoE_DeleteChannel(int channel);
    int VoE_Terminate();
    /*stop videoengine*/
    int StopRender(int channel);
    int StopReceive(int channel);
    int StopSend(int channel);
    int RemoveRemoteRenderer(int channel);
    int ViE_DeleteChannel(int channel);
    int Terminate();
    
    int EnablePLI(int channel,bool enable);
    int EnableNACK(int channel,bool enable);
    
    int AddRemoteRenderer(int channel, void* glSurface);
};



#endif /* defined(__ZYWebRTCDemo__ZYWebRTCMediaEngineNative__) */

