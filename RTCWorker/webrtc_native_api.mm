//
//  ZYWebRTCMediaEngineNative.cpp
//  ZYWebRTCDemo
//
//  Created by 杨争 on 4/12/14.
//  Copyright (c) 2014 SMIT. All rights reserved.
//

#include "webrtc_native_api.h"
using namespace webrtc;

class VideoCallbackIOS: public ViEDecoderObserver,
public ViEEncoderObserver{
    // Implements ViEDecoderObserver
    virtual void IncomingRate(const int videoChannel,
                              const unsigned int framerate,
                              const unsigned int bitrate)
    {
        // Let's print out the network statistics from this call back as well
        unsigned short fraction_lost;
        unsigned int dummy;
        int intdummy;
        _vieData.rtp->GetReceivedRTCPStatistics(videoChannel, fraction_lost,
                                                dummy, dummy, dummy, intdummy);
        unsigned short packetLossRate = 0;
        if (fraction_lost > 0)
        {
            // Change from frac to %
            packetLossRate = (fraction_lost * 100) >> 8;
        }
        printf("IncomingRate=====frameRateI:%d  bitRateI:%d packetLoss:%d frameRateO:%d bitRateO:%d \n",framerate,bitrate,packetLossRate,_frameRateO,_bitRateO);
    };
    
    virtual void IncomingCodecChanged(const int video_channel,
                                      const VideoCodec& video_codec){
        printf("video_codec changed");
    };
    
    virtual void RequestNewKeyFrame(const int videoChannel)
    {
       // DEBUG_LOG_NULL;
    }
    ;
    virtual void OutgoingRate(const int videoChannel,
                              const unsigned int framerate,
                              const unsigned int bitrate)
    {
        _frameRateO = framerate;
        _bitRateO = bitrate;
        printf("OutgoingRate====frameRate %d bitrate %d\n",framerate,bitrate);
    };
public:
    VideoEngineData& _vieData;
    int _frameRateO, _bitRateO;
    VideoCallbackIOS(VideoEngineData& vieData):_vieData(vieData){
    }
    
    /*
     该该够函数等同于：
     VideoCallbackIOS(VideoEngineData& vieData)
    {
        _vieData = vieData;
     }
     */
};


int webrtc_native_api::Vie_SetCallback(int channel)
{
    printf("Vie_setCallBack");
    if (NULL == vieData.codec) {
        return -1;
    }
    
    if (vieData.callback == NULL) {
        //
        vieData.callback = new VideoCallbackIOS(vieData);
    }
    
    else if (vieData.codec){
        vieData.codec->DeregisterDecoderObserver(channel);
        vieData.codec->DeregisterEncoderObserver(channel);
    }
    vieData.codec->RegisterDecoderObserver(channel, *vieData.callback);
    vieData.codec->RegisterEncoderObserver(channel, *vieData.callback);
    return 0;
}

bool webrtc_native_api::VE_GetSubApis()
{
    bool getOK = true;
    
    // Base
    voeData.base = VoEBase::GetInterface(voeData.ve);
    if (!voeData.base) {
        printf("Get base sub-API failed");
        getOK = false;
    }
    
    // Codec
    voeData.codec = VoECodec::GetInterface(voeData.ve);
    if (!voeData.codec) {
        printf("Get codec sub-API failed");
        getOK = false;
    }
    
    // File
    voeData.file = VoEFile::GetInterface(voeData.ve);
    if (!voeData.file) {
        printf("Get file sub-API failed");
        getOK = false;
    }
    
    // Network
    voeData.netw = VoENetwork::GetInterface(voeData.ve);
    if (!voeData.netw) {
        printf("Get network sub-API failed");
        getOK = false;
    }
    
    // audioprocessing
    voeData.apm = VoEAudioProcessing::GetInterface(voeData.ve);
    if (!voeData.apm) {
        printf("Get VoEAudioProcessing sub-API failed");
        getOK = false;
    }
    
    // Volume
    voeData.volume = VoEVolumeControl::GetInterface(voeData.ve);
    if (!voeData.volume) {
        printf("Get volume sub-API failed");
        getOK = false;
    }
    
    // Hardware
    voeData.hardware = VoEHardware::GetInterface(voeData.ve);
    if (!voeData.hardware) {
        printf("Get hardware sub-API failed");
        getOK = false;
    }
    
    // RTP
    voeData.rtp = VoERTP_RTCP::GetInterface(voeData.ve);
    if (!voeData.rtp) {
        printf("Get rtp sub-API failed");
        getOK = false;
    }
    
    return getOK;
}

bool webrtc_native_api::VE_ReleaseSubApis() {
    bool releaseOK = true;
    // Base
    if (voeData.base) {
        if (0 != voeData.base->Release()) {
            printf("Release base sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.base = NULL;
        }
    }
    
    // Codec
    if (voeData.codec) {
        if (0 != voeData.codec->Release()) {
            printf("Release codec sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.codec = NULL;
        }
    }
    
    // File
    if (voeData.file) {
        if (0 != voeData.file->Release()) {
            printf("Release file sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.file = NULL;
        }
    }
    
    // Network
    if (voeData.netw) {
        if (0 != voeData.netw->Release()) {
            printf("Release network sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.netw = NULL;
        }
    }
    
    // apm
    if (voeData.apm) {
        if (0 != voeData.apm->Release()) {
            printf("Release apm sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.apm = NULL;
        }
    }
    
    // Volume
    if (voeData.volume) {
        if (0 != voeData.volume->Release()) {
            printf("Release volume sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.volume = NULL;
        }
    }
    
    // Hardware
    if (voeData.hardware) {
        if (0 != voeData.hardware->Release()) {
            printf("Release hardware sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.hardware = NULL;
        }
    }
    
    if (voeData.rtp) {
        if (0 != voeData.rtp->Release()) {
            printf("Release rtp sub-API failed");
            releaseOK = false;
        }
        else {
            voeData.rtp = NULL;
        }
    }
    
    return releaseOK;
}

/* Video Engine API */
int webrtc_native_api::getVideoEngine(){
    // Check if already got
    if (vieData.vie) {
        printf("ViE already got");
        return 0;
    }
    // Create
    vieData.vie = VideoEngine::Create();
    if (!vieData.vie) {
        printf("Get ViE failed");
        return -1;
    }
    vieData.base = ViEBase::GetInterface(vieData.vie);
    if (!vieData.base) {
        printf("Get base sub-API failed");
        return -1;
    }
    
    vieData.codec = ViECodec::GetInterface(vieData.vie);
    if (!vieData.codec) {
        printf("Get codec sub-API failed");
        return -1;
    }
    
    vieData.netw = ViENetwork::GetInterface(vieData.vie);
    if (!vieData.netw) {
        printf("Get network sub-API failed");
        return -1;
    }
    
    vieData.rtp = ViERTP_RTCP::GetInterface(vieData.vie);
    if (!vieData.rtp) {
        printf("Get RTP sub-API failed");
        return -1;
    }
    
    vieData.render = ViERender::GetInterface(vieData.vie);
    if (!vieData.render) {
        printf("Get Render sub-API failed");
        return -1;
    }
    
    vieData.capture = ViECapture::GetInterface(vieData.vie);
    if (!vieData.capture) {
        printf("Get Capture sub-API failed");
        return -1;
    }
    
    vieData.externalCodec = ViEExternalCodec::GetInterface(vieData.vie);
    if (!vieData.externalCodec) {
        printf("Get External Codec sub-API failed");
        return -1;
    }
    char webrtcversion[1024];
    vieData.base->GetVersion(webrtcversion);
    printf("%s",webrtcversion);
    return 0;
}

int webrtc_native_api::Init(bool enableTrace)
{
    if (vieData.vie) {
        int ret = vieData.base->Init();
        if (enableTrace)
        {
//            NSLog(@"SetTraceFile");
//            NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"trace/trace.txt"];
//            if (0 != vieData.vie->SetTraceFile(path.UTF8String,false)) {
//                NSLog(@"Video Engine could not enable trace");
//            }
//            
//            NSLog(@"SetTraceFilter");
//            if (0 != vieData.vie->SetTraceFilter(webrtc::kTraceError)) {
//                NSLog(@"Could not set trace filter");
//            }
        }
        else
        {
            if (0 != vieData.vie->SetTraceFilter(webrtc::kTraceNone))
            {
                printf("Could not set trace filter");
            }
        }
        if (voeData.ve) // VoiceEngine is enabled
        {
            printf("SetVoiceEngine");
            if (0 != vieData.base->SetVoiceEngine(voeData.ve))
            {
                printf("SetVoiceEngine failed");
            }
        }
        return ret;
    }
    else
    {
        return -1;
    }
}

int webrtc_native_api::Terminate()
{
    printf("Terminate\n");
    
    if (vieData.vie) {
        if (!vieData.rtp || vieData.rtp->Release() != 0) {
            printf("Failed to release RTP sub-API\n");
        }
        
        if (!vieData.netw || vieData.netw->Release() != 0) {
            printf("Failed to release Network sub-API\n");
        }
        
        if (!vieData.codec || vieData.codec->Release() != 0) {
            printf("Failed to release Codec sub-API\n");
        }
        
        if (!vieData.render || vieData.render->Release()) {
            printf("Failed to release Render sub-API\n");
        }
        
        if (!vieData.capture || vieData.capture->Release()) {
            printf("Failed to release Capture sub-API\n");
        }
        
        if (!vieData.base || vieData.base->Release() != 0) {
            printf("Failed to release Base sub-API\n");
        }
        
        if (!vieData.externalCodec || vieData.externalCodec->Release()) {
            printf("Failed to release External Codec sub-API\n");
        }
        
        // Delete Vie
        if (!VideoEngine::Delete(vieData.vie)) {
            printf("Failed to delete ViE\n");
            return -1;
        }
        memset(&vieData, 0, sizeof(vieData));
        return 0;
    }
    else {
        return -1;
    }
}

int webrtc_native_api::StartSent(int channel)
{
    printf("StartSend\n");
    if (vieData.base) {
        int ret = vieData.base->StartSend(channel);
        return ret;
    }
    else{
        return -1;
    }
}

int webrtc_native_api::StopRender(int channel)
{
    printf("StopRender\n");
    if (vieData.render) {
        return vieData.render->StopRender(channel);
    }
    else {
        return -1;
    }
}

int webrtc_native_api::StopSend(int channel)
{
    printf("StopSend\n");
    
    if (vieData.base) {
        return vieData.base->StopSend(channel);
    }
    else {
        return -1;
    }
}

int webrtc_native_api::StartReceive(int channel)
{
    printf("StartReceive\n");
    
    if (vieData.base) {
        return vieData.base->StartReceive(channel);
    }
    else {
        return -1;
    }
}

int webrtc_native_api::StopReceive(int channel)
{
    printf("StopReceive\n");
    if (vieData.base) {
        return vieData.base->StopReceive(channel);
    }
    else {
        return -1;
    }
}


/* Channel functions */
int webrtc_native_api::CreateChannel(int voiceChannel)
{
    printf("CreateChannel\n");
    
    if (vieData.vie) {
        int channel = 0;
        if (vieData.base->CreateChannel(channel) != 0) {
            return -1;
        }
        if (voiceChannel >= 0) {
            vieData.base->ConnectAudioChannel(channel, voiceChannel);
        }
        vieData.transport.reset(new test::VideoChannelTransport(vieData.netw,channel));
        return channel;
    }
    else {
        return -1;
    }
}

/*Receiver & Destination function */
int webrtc_native_api::SetLocalReceiver( int channel, int port , const char* multicastIpAddr)
{
    printf("SetLocalReceiver\n");
    
    if (vieData.transport.get()) {
        return vieData.transport->SetLocalReceiver(port);
    }
    return -1;
}

int webrtc_native_api::SetSendDestination(int channel,int port,const char * ipaddr)
{
    
    if (NULL == vieData.vie)
        return -1;
    
    const char* ip = ipaddr;
    if (!ip) {
        printf("Could not get UTF string\n");
        return -1;
    }
    
    printf("SetSendDestination: channel=%d, port=%d, ip=%s\n",channel, port, ip);
    
    if (vieData.transport.get()) {
        return vieData.transport->SetSendDestination(ip, port);
    }
    return -1;
}


/* Codec */
int webrtc_native_api::SetReceiveCodec(int channel,int codecNum,int intbitRate, int width,int height,int frameRate)
{
    if (NULL == vieData.codec)
        return -1;
    
    //Create codec
    webrtc::VideoCodec codec;
    vieData.codec->GetCodec(codecNum, codec);
    
    printf("SetReceiveCodec %s, pltype=%d, bitRate=%d, maxBitRate=%d,"
           " width=%d, height=%d, frameRate=%d \n",codec.plName, codec.plType, codec.startBitrate,codec.maxBitrate, codec.width, codec.height,codec.maxFramerate);
    int ret = vieData.codec->SetReceiveCodec(channel, codec);
    return ret;
}

int webrtc_native_api::setSendCodec(int channel,int codecType,int intBitRate,int width,int height,int frameRate)
{
    if (NULL == vieData.codec) {
        return -1;
    }
    //Create codec
    webrtc::VideoCodec codec;
    vieData.codec->GetCodec(codecType, codec);
    codec.startBitrate = intBitRate;
    codec.maxBitrate = 600;
    codec.width = width;
    codec.height = height;
    codec.maxFramerate = frameRate;
    
    for (int i = 0; i < vieData.codec->NumberOfCodecs(); ++ i) {
        webrtc::VideoCodec codecToList;
        vieData.codec->GetCodec(i, codecToList);
        printf("Codec list = %s,pltype = %d,bitRate = %d,maxBitRate = %d, width = %d,height = %d,frameRate = %d\n",codecToList.plName,codecToList.plType,codecToList.startBitrate,codecToList.maxBitrate,codecToList.width,codecToList.height,codecToList.maxFramerate);
    }
    
    printf("SetSendCodec %s,pltype = %d,bitRate = %d,maxBitRate = %d,width = %d,height = %d,frameRate = %d\n",codec.plName,codec.plType,codec.startBitrate,codec.maxBitrate,codec.width,codec.height,codec.maxFramerate);
    
    return vieData.codec->SetSendCodec(channel, codec);
}

/* Rendering */
int webrtc_native_api::AddRemoteRenderer(
                                         int channel,
                                         void* glSurface)
{
    printf("AddRemoteRenderer\n");
    if (vieData.vie) {
        return vieData.render->AddRenderer(channel, glSurface, 0, 0, 0, 1, 1);
    }
    else {
        return -1;
    }
}

int webrtc_native_api::RemoveRemoteRenderer(int channel)
{
    printf("RemoveRemoteRenderer\n");
    
    if (vieData.vie) {
        return vieData.render->RemoveRenderer(channel);
    }
    else {
        return -1;
    }
    return 0;
}

int webrtc_native_api::StartRender(int channel)
{
    printf("StartRender\n");
    
    if (vieData.render) {
        return vieData.render->StartRender(channel);
    }
    else {
        return -1;
    }
}


/* Capture */
int webrtc_native_api::StartCamera(
                                   int channel,
                                   int cameraNum)
{
    if (NULL == vieData.vie)
        return -1;
    
    int i = 0;
    char deviceName[64];
    char deviceUniqueName[64];
    int re;
    do {
        re = vieData.capture->GetCaptureDevice(i, deviceName,
                                               sizeof(deviceName),
                                               deviceUniqueName,
                                               sizeof(deviceUniqueName));
        printf("GetCaptureDevice ret %d devicenum %d deviceUniqueName %s\n",
               re, i, deviceUniqueName);
        i++;
    } while (i < 2);
    
    int ret;
    int cameraId;
    vieData.capture->GetCaptureDevice(cameraNum, deviceName,
                                      sizeof(deviceName), deviceUniqueName,
                                      sizeof(deviceUniqueName));
    vieData.capture->AllocateCaptureDevice(deviceUniqueName,
                                           sizeof(deviceUniqueName), cameraId);
    
    if (cameraId >= 0) { //Connect the
        ret = vieData.capture->ConnectCaptureDevice(cameraId, channel);
        
        printf("ConnectCaptureDevice ret %d ", ret);
        
        ret = vieData.capture->StartCapture(cameraId);
        printf("StartCapture ret %d ", ret);
    }
    
    return cameraId;
}

int webrtc_native_api::StopCamera(int cameraId)
{
    if (NULL == vieData.capture)
        return -1;
    
    int ret = vieData.capture->StopCapture(cameraId);
    printf("StopCapture  ret %d \n", ret);
    ret = vieData.capture->ReleaseCaptureDevice(cameraId);
    printf("ReleaseCaptureDevice  ret %d \n", ret);
    
    return ret;
}

int webrtc_native_api::SetRotation(int cameraID,int degrees)
{
    if (NULL == vieData.capture) {
        return -1;
    }
    RotateCapturedFrame rotation = RotateCapturedFrame_0;
    if (degrees == 90) {
        rotation = RotateCapturedFrame_90;
    }
    else if (degrees == 180){
        rotation = RotateCapturedFrame_180;
    }
    else if (degrees == 270){
        rotation = RotateCapturedFrame_270;
    }
    int ret = vieData.capture->SetRotateCapturedFrames(cameraID, rotation);
    return ret;
}

/* NACK */
int webrtc_native_api::EnableNACK(int channel,bool enable)
{
    if (NULL == vieData.rtp)
        return -1;
    
    int ret = vieData.rtp->SetNACKStatus(channel, enable);
    printf("EnableNACK(%d) ret:%d\n", enable, ret);
    return ret;
}

/* PLI */
int webrtc_native_api::EnablePLI(int channel,bool enable)
{
    if (NULL == vieData.rtp)
        return -1;
    
    if (enable){
        printf("EnablePLI enable");
    }
    else{
        printf("EnablePLI disable");
    }
    
    int ret = vieData.rtp->SetKeyFrameRequestMethod(channel,
                                                    kViEKeyFrameRequestPliRtcp);
    return ret;
}

/* Voice Engine API */
bool  webrtc_native_api::VoE_Create() {
    // Check if already created
    if (voeData.ve) {
        printf("VoE already created");
        return false;
    }
    
    // Create
    voeData.ve = VoiceEngine::Create();
    if (!voeData.ve) {
        printf("Create VoE failed");
        return false;
    }
    
    // Get sub-APIs
    if (!VE_GetSubApis()) {
        // If not OK, release all sub-APIs and delete VoE
        VE_ReleaseSubApis();
        if (!VoiceEngine::Delete(voeData.ve)) {
            printf("Delete VoE failed");
        }
        return false;
    }
    return true;
}

bool webrtc_native_api::VoE_Delete()
{
    //check if exists
    if (!voeData.ve) {
        printf("VoE does not exist\n");
        return false;
    }
    
    //Release sub-APIs
    VE_ReleaseSubApis();
    
    //Delete
    if (!VoiceEngine::Delete(voeData.ve)) {
        printf("Delete VoE failed\n");
        return false;
    }
    voeData.ve = NULL;
    return true;
}


/* Initialization and Termination functions */
int webrtc_native_api::VoE_Init(bool enableTrace)
{
    printf("VE_Init");
    
    VALIDATE_BASE_POINTER;
    
    return voeData.base->Init();
}


int webrtc_native_api::VoE_Terminate()
{
    VALIDATE_BASE_POINTER;
    int retVal = voeData.base->Terminate();
    return retVal;
}

/* Channel functions */
int webrtc_native_api::VoE_CreateChannel()
{
    VALIDATE_BASE_POINTER;
    webrtc::CodecInst voiceCodec;
    int numOfVeCodecs = voeData.codec->NumOfCodecs();
    
    //enum all the supported codec
    printf("Supported Voice Codec:\n");
    for (int i = 0; i < numOfVeCodecs; ++i) {
        if (voeData.codec->GetCodec(i, voiceCodec) != -1) {
            printf("num: %d name: %s\n", i, voiceCodec.plname);
        }
    }
    
    int channel = voeData.base->CreateChannel();
    voeData.transport.reset(new test::VoiceChannelTransport(voeData.netw,
                                                            channel));
    return channel;
}

int webrtc_native_api::VoE_DeleteChannel(int channel)
{
    VALIDATE_BASE_POINTER;
    voeData.transport.reset(NULL);
    return voeData.base->DeleteChannel(channel);
}

int webrtc_native_api::ViE_DeleteChannel(int channel)
{
    VALIDATE_BASE_POINTER;
    vieData.transport.reset(NULL);
    return vieData.base->DeleteChannel(channel);
}

/* Receiver&Destination functions */
int webrtc_native_api::VoE_SetLocalReceiver(int channel,int port)
{
    VALIDATE_BASE_POINTER;
    if (voeData.transport.get()) {
        return voeData.transport->SetLocalReceiver(port);
    }
    return -1;
}

int webrtc_native_api::VoE_SetSendDestination(int channel,int port,const char* ipaddr)
{
    printf("SetSendDestination\n");
    VALIDATE_BASE_POINTER;
    
    const char* ipaddrNative = ipaddr;
    if (!ipaddrNative) {
        printf("Could not get send destination ip string\n");
        return -1;
    }
    if (voeData.transport.get()) {
        int retVal = voeData.transport->SetSendDestination(ipaddrNative, port);
        return retVal;
    }
    return -1;
}


/* Media functions */
int webrtc_native_api::VoE_StartListen(int channel)
{
    printf("StartListen" );
    VALIDATE_BASE_POINTER;
    return voeData.base->StartReceive(channel);
}

int webrtc_native_api::VoE_StartPlayout(int channel)
{
    printf("StartPlayout");
    VALIDATE_BASE_POINTER;
    return voeData.base->StartPlayout(channel);
}

int webrtc_native_api::VoE_StartSend( int channel)
{
    printf("StartSend");
    VALIDATE_BASE_POINTER;
    return voeData.base->StartSend(channel);
}

int webrtc_native_api::VoE_StopListen(int channel)
{
    VALIDATE_BASE_POINTER;
    return voeData.base->StartReceive(channel);
}

int webrtc_native_api::VoE_StopPlayout(int channel)
{
    VALIDATE_BASE_POINTER;
    return voeData.base->StopPlayout(channel);
}

int webrtc_native_api::VoE_StopSend(int channel)
{
    VALIDATE_BASE_POINTER;
    return voeData.base->StopSend(channel);
}

/* Volume */
int webrtc_native_api::VoE_SetSpeakerVolume(int level)
{
    VALIDATE_VOLUME_POINTER;
    if (voeData.volume->SetSpeakerVolume(level) != 0) {
        return -1;
    }
    return 0;
}

/* Hardware */
int webrtc_native_api::VoE_SetLoudspeakerStatus(bool enable)
{
    VALIDATE_HARDWARE_POINTER;
    if (voeData.hardware->SetLoudspeakerStatus(enable) != 0) {
        return -1;
    }
    return 0;
}

/* Codec-setting functions */
int webrtc_native_api::VoE_SetSendCodec(int channel,int index)
{
    VALIDATE_CODEC_POINTER;
    
    webrtc::CodecInst codec;
    
    for (int i = 0; i < voeData.codec->NumOfCodecs(); ++i) {
        webrtc::CodecInst codecToList;
        voeData.codec->GetCodec(i, codecToList);
        printf("VE Codec list %s, pltype=%d\n",codecToList.plname, codecToList.pltype);
    }
    
    if (voeData.codec->GetCodec(index, codec) != 0) {
        printf("Failed to get codec\n");
        return -1;
    }
    printf("SetSendCodec %s\n",codec.plname);
    
    return voeData.codec->SetSendCodec(channel, codec);
}

/* VoiceEngine funtions */
int webrtc_native_api::VoE_SetECStatus(bool enable)
{
    VALIDATE_APM_POINTER;
    if (voeData.apm->SetEcStatus(enable, kEcAecm) < 0) {
        printf("Failed SetECStatus(%d,%d)\n", enable, kEcAecm);
        return -1;
    }
    if (voeData.apm->SetAecmMode(kAecmSpeakerphone, false) != 0) {
        printf("Failed SetAecmMode(%d,%d)\n", kAecmSpeakerphone, 0);
        return -1;
    }
    return 0;
}

int webrtc_native_api::VoE_SetAGCStatus(bool enable)
{
    VALIDATE_APM_POINTER;
    if (voeData.apm->SetAgcStatus(enable, kAgcFixedDigital) < 0) {
        printf("Failed SetAgcStatus(%d,%d)", enable, kAgcFixedDigital);
        return -1;
    }
    webrtc::AgcConfig config;
    // The following settings are by default, explicitly set here.
    config.targetLeveldBOv = 3;
    config.digitalCompressionGaindB = 9;
    config.limiterEnable = true;
    if (voeData.apm->SetAgcConfig(config) != 0) {
        printf( "Failed SetAgcConfig(%d,%d,%d)",
               config.targetLeveldBOv,
               config.digitalCompressionGaindB,
               config.limiterEnable);
        return -1;
    }
    return 0;
}

int webrtc_native_api::VoE_SetNSStatus( bool enable) {
    VALIDATE_APM_POINTER;
    if (voeData.apm->SetNsStatus(enable, kNsModerateSuppression) < 0) {
        printf("Failed SetNsStatus(%d,%d)",enable, kNsModerateSuppression);
        return -1;
    }
    return 0;
}