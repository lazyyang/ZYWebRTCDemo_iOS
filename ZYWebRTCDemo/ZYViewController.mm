//
//  ZYViewController.m
//  ZYWebRTCDemo
//
//  Created by SMIT on 14-3-28.
//  Copyright (c) 2014年 SMIT. All rights reserved.
//

#import "ZYViewController.h"
#import "ZYAppDelegate.h"
#include "webrtc/modules/video_render/ios/video_render_ios_view.h"
#include <AVFoundation/AVFoundation.h>
//#import "ZYMediaEngineAPI.h"
#import "ZYRTCMediaEngineAPI.h"

@interface ZYViewController ()



@property (nonatomic,copy) NSArray *videoCodecArray;
@property (nonatomic,copy) NSArray *voiceCodecArray;
@property (strong, nonatomic) IBOutlet UISegmentedControl *topSegment;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *settingView;
@property (strong, nonatomic) IBOutlet UIButton *startCallBtn;
@property (strong, nonatomic) IBOutlet UIButton *SwitchToFrontBtn;

@property (strong, nonatomic) IBOutlet UISwitch *videoReceiveSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *videoSendSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *voiceSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *loopBackModeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *StatsSwitch;

//ip textfiled
@property (strong, nonatomic) IBOutlet UITextField *remoteIPTextField;

@property (strong,nonatomic) VideoRenderIosView *myView;

@end
@implementation ZYViewController


- (IBAction)startCallBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"StartCall"]) {
        NSLog(@"StartCall");
        if (engineAPI == nil) {
            engineAPI = [[ZYRTCMediaEngineAPI alloc]init];
        }
        [engineAPI stratMediaEngine];

    
        _myView = [[VideoRenderIosView alloc] initWithFrame:CGRectMake(0, 80, 320, 426)];
        self.myView.backgroundColor = [UIColor greenColor];
        [self.mainView addSubview:self.myView];

        [engineAPI startCall:(void *)self.myView WithIPAddress:self.remoteIPTextField.text WithVoiceEnable:YES WithVideoEnable:YES WithVideoReceiveEnable:YES WithVideoSendEnable:YES];
        [btn setTitle:@"StopCall" forState:UIControlStateNormal];
    }
    else{
        [engineAPI stopAll];
         engineAPI = nil;
        [self.myView removeFromSuperview];
        self.myView = nil;
        [btn setTitle:@"StartCall" forState:UIControlStateNormal];
    }

}

- (IBAction)swithToFrontBtnClicked:(id)sender
{
    NSLog(@"SwitchToFront");
    [engineAPI switchCapture];
}

- (IBAction)switchClicked:(id)sender
{
    UISwitch *myswitch = (UISwitch *)sender;
    NSLog(@"switchClicked");
    if (myswitch == self.videoReceiveSwitch) {
        NSLog(@"videoReceiveSwitch");
    }
    else if (myswitch == self.videoSendSwitch){
        NSLog(@"videoSendwitch");
    }
    else if (myswitch == self.voiceSwitch){
        NSLog(@"voiceSwitch");
    }
    else if (myswitch == self.loopBackModeSwitch){
        NSLog(@"loopbackSwitch");
    }
    else{
        NSLog(@"StatsSwitch");
    }
}

- (IBAction)topSegmentValueChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    NSLog(@"changed");
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.mainView.hidden = NO;
            self.settingView.hidden = YES;
            break;
        case 1:
            self.mainView.hidden = YES;
            self.settingView.hidden = NO;
            break;
        case 2:
            self.mainView.hidden = YES;
            self.settingView.hidden = YES;
            break;
        case 3:
            self.mainView.hidden = YES;
            self.settingView.hidden = YES;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.remoteIPTextField.delegate = self;
    
    self.mainView.hidden = NO;
    self.settingView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
