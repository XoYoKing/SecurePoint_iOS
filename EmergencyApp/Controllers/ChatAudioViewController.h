//
//  ChatAudioViewController.h
//  EmergencyApp
//
//  Created by Muhammed Salih on 10/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPViewController.h"

@interface ChatAudioViewController : SPViewController

- (IBAction)audioClicked:(id)sender;
- (IBAction)micClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *controllerView;

@property (strong, nonatomic) IBOutlet UIButton *swichMic;
@property (strong, nonatomic) IBOutlet UIButton *swichSound;

@end
