//
//  ZYRTCMediaEngineAPI.h
//  ZYWebRTCDemo
//
//  Created by 杨争 on 4/12/14.
//  Copyright (c) 2014 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "webrtc_native_api.h"

@interface ZYRTCMediaEngineAPI : NSObject
{
    webrtc_native_api *vieIosAPI;
    int currentCapture;
    int voiceChannel;
    int videoChannel;
    int voERunning;
    int viERunning;
    int camID;
}


- (void)startCall:(void *)glViewVideoRemote WithIPAddress:(NSString *)ipAddress WithVoiceEnable:(BOOL)voiceEnable WithVideoEnable:(BOOL)videoEnable WithVideoReceiveEnable:(BOOL)VideoReceiveEnable WithVideoSendEnable:(BOOL)videoSendEnable;

- (void)stratMediaEngine;

- (void)stopAll;

- (void)switchCapture;

@end
