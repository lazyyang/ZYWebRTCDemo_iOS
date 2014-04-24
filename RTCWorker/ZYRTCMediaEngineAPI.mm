//
//  ZYRTCMediaEngineAPI.m
//  ZYWebRTCDemo
//
//  Created by 杨争 on 4/12/14.
//  Copyright (c) 2014 SMIT. All rights reserved.
//

#import "ZYRTCMediaEngineAPI.h"

#define kEnableTrace TRUE
#define kVideoSendPort 11111
#define kVideoReceivePort 11111
#define kVoiceSendPort 11113
#define kVoiceReceivePort 11113
#define kVoiceCodecType 0 //ISAC
#define kVideoCodecType 0 //VP8

#define kCaptureNeededRotation 270
#define kCaptureBackNeedRotation 0

#define kIntBitRate 500
#define kVideoWidth 640
#define kVideoHeight 480
#define kFrameRate 15

enum CaptureType
{
    kBackCapture,
    kFrontCapture
};


@implementation ZYRTCMediaEngineAPI

- (id)init
{
    if (self = [super init]) {
        voiceChannel = -1;
        videoChannel = -1;
        vieIosAPI = new webrtc_native_api();
        
    }
    return self;
}

- (void)dealloc
{
    if (vieIosAPI != NULL) {
        delete vieIosAPI;
        vieIosAPI = NULL;
    }
}

- (void)startVoiceEngine:(BOOL)speakerEnable ACEMEnable:(BOOL)acemEnable ACGEnable:(BOOL)acgEnable NSEnable:(BOOL)nsEnable IPAddress:(NSString *)ipAddress
{
    voiceChannel = vieIosAPI->VoE_CreateChannel();
    if (0 > voiceChannel) {
        NSLog(@"VoE create channel failed");
        return;
    }
    //Set local receiver
    if (0 != vieIosAPI->VoE_SetLocalReceiver(voiceChannel, kVoiceSendPort)) {
        NSLog(@"VoE set local receiver failed");
    }
    
    if (0 != vieIosAPI->VoE_StartListen(voiceChannel)) {
        NSLog(@"VoE start listen failed");
    }
    
    //Start playout
    if (0 != vieIosAPI->VoE_StartPlayout(voiceChannel)) {
        NSLog(@"VoE start playout failed");
    }
    
    //DestinationPortVoice
    if (0 != vieIosAPI->VoE_SetSendDestination(voiceChannel, kVoiceSendPort, [ipAddress UTF8String])) {
        NSLog(@"VoE set send destination failed");
    }
    
    //SendCodec
    if (0 != vieIosAPI->VoE_SetSendCodec(voiceChannel, kVoiceCodecType)) {
        NSLog(@"VoE set send codec failed");
    }
    
    //EC  回声消除
    if (0 != vieIosAPI->VoE_SetECStatus(true)) {
        NSLog(@"VoE set EC Status failed");
    }
    
    //AGC 一种是数字模式、一种是模拟模式，用来调整增益。数字AGC是直接对你采集到的信号进行作用，而模拟是用来控制你采集端麦克风的音量的
    if (0 != vieIosAPI->VoE_SetAGCStatus(true)) {
        NSLog(@"VoE set AGC Status failed");
    }
    
    if (0 != vieIosAPI->VoE_SetNSStatus(true)) {
        NSLog(@"VoE set NS Status failed");
    }
    
    if (0 != vieIosAPI->VoE_StartSend(voiceChannel)) {
        NSLog(@"VoE start send failed");
    }
    voERunning = true;
    return;
}

- (void)startCall:(void *)glViewVideoRemote WithIPAddress:(NSString *)ipAddress WithVoiceEnable:(BOOL)voiceEnable WithVideoEnable:(BOOL)videoEnable WithVideoReceiveEnable:(BOOL)VideoReceiveEnable WithVideoSendEnable:(BOOL)videoSendEnable
{
    int ret = 0;
    if (voiceEnable) {
        [self startVoiceEngine:NO ACEMEnable:NO ACGEnable:NO NSEnable:NO IPAddress:ipAddress];
    }
    if (videoEnable) {
        videoChannel = vieIosAPI->CreateChannel(voiceChannel);
        ret = vieIosAPI->SetLocalReceiver(videoChannel, kVideoReceivePort, [ipAddress UTF8String]);
        if (ret != 0) {
            NSLog(@"Video set local receivei failed");
        }
        
        ret = vieIosAPI->SetSendDestination(videoChannel,kVideoSendPort,[ipAddress UTF8String]);
        if (ret != 0) {
            NSLog(@"Video set remoteIP failed");
        }
        
        if (videoSendEnable) {
            ret = vieIosAPI->setSendCodec(videoChannel, kVideoCodecType, kIntBitRate, kVideoWidth, kVideoHeight, kFrameRate);
            currentCapture = kFrontCapture;
            camID = vieIosAPI->StartCamera(videoChannel, kFrontCapture);
            if (camID > 0) {
                NSLog(@"-------%d",camID);
                vieIosAPI->SetRotation(camID, kCaptureNeededRotation);
            }
            else{
                ret = camID;
            }
            ret = vieIosAPI->StartSent(videoChannel);
        }
        
        if (VideoReceiveEnable) {
            ret = vieIosAPI->AddRemoteRenderer(videoChannel, glViewVideoRemote);
            ret = vieIosAPI->SetReceiveCodec(videoChannel, kVideoCodecType, kIntBitRate, kVideoWidth, kVideoHeight, kFrameRate);
            ret = vieIosAPI->StartRender(videoChannel);
            ret = vieIosAPI->StartReceive(videoChannel);
        }
        
        ret = vieIosAPI->EnableNACK(videoChannel, true);
        ret = vieIosAPI->EnablePLI(videoChannel, true);
        
        ret = vieIosAPI->Vie_SetCallback(videoChannel);
        viERunning = true;
    }
    
}

- (int)setUpVoiceEngine
{
    //Create VoiceEngine
    //Error logging is done in native API wrapper
    vieIosAPI->VoE_Create();
    
    //Initializeb
    if (0 != vieIosAPI->VoE_Init(kEnableTrace)) {
        NSLog(@"VoE init failed");
        return -1;
    }
    return 0;
}

- (void)stratMediaEngine{
    
    if ([self setUpVoiceEngine] < 0||vieIosAPI->getVideoEngine() < 0||vieIosAPI->Init(kEnableTrace)) {
        NSLog(@"WebRTC Error");
    }
}

- (void)stopVoiceEngine
{
    voERunning = false;
    if (0 != vieIosAPI->VoE_StopSend(voiceChannel)) {
        NSLog(@"VoE stop send failed");
    }
    
    if (0 != vieIosAPI->VoE_StopListen(voiceChannel)) {
        NSLog(@"VoE stop listen failed");
    }
    
    if (0 != vieIosAPI->VoE_StopPlayout(voiceChannel)) {
        NSLog(@"VoE stop playout failed");
    }
    
    if (0 != vieIosAPI->VoE_DeleteChannel(voiceChannel)) {
        NSLog(@"VoE delete channel failed");
    }
    
    voiceChannel = -1;
    if (0 != vieIosAPI->VoE_Terminate()) {
        NSLog(@"VoE terminate failed");
    }
}

- (void)switchCapture
{
    if (currentCapture == kFrontCapture) {
        vieIosAPI->StopCamera(camID);
        camID = vieIosAPI->StartCamera(videoChannel, kBackCapture);
        vieIosAPI->SetRotation(camID, kCaptureBackNeedRotation);
        currentCapture = kBackCapture;
    }
    else{
        vieIosAPI->StopCamera(camID);
        camID = vieIosAPI->StartCamera(videoChannel, kFrontCapture);
        vieIosAPI->SetRotation(camID, kCaptureNeededRotation);
        currentCapture = kFrontCapture;
    }

}

- (void)stopAll
{
    if (vieIosAPI != NULL) {
        if (voERunning) {
            voERunning = false;
            [self stopVoiceEngine];
        }
        
        if (viERunning) {
            viERunning = false;
            vieIosAPI->StopRender(videoChannel);
            vieIosAPI->StopReceive(videoChannel);
            vieIosAPI->StopSend(videoChannel);
            vieIosAPI->RemoveRemoteRenderer(videoChannel);
            vieIosAPI->ViE_DeleteChannel(videoChannel);
            videoChannel = -1;
            vieIosAPI->Terminate();
        }
    }
}

@end
