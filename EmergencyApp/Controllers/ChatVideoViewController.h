//
//  ChatVideoViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 05/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPViewController.h"

@interface ChatVideoViewController : SPViewController
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (strong, nonatomic) IBOutlet UIButton *swichCamButton;

- (IBAction)switchCam:(id)sender;
- (IBAction)micOff:(id)sender;
- (IBAction)mute:(id)sender;
- (IBAction)toggleScreen:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *controllerView;
@property (strong, nonatomic) IBOutlet UIView *controlertransperentView;
@property (strong, nonatomic) IBOutlet UIView *controlHolderView;


@property (strong, nonatomic) IBOutlet UIButton *swichMic;
@property (strong, nonatomic) IBOutlet UIButton *swichSound;
@end
