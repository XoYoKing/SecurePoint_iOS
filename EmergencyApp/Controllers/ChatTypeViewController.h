//
//  ChatTypeViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 04/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPViewController.h"

@interface ChatTypeViewController : SPViewController
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *chatCount;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UILabel *audioCount;

@property (weak, nonatomic) IBOutlet UIButton *vidButton;
@property (weak, nonatomic) IBOutlet UILabel *vidCount;
-(void)updateCount;
+(instancetype)getActiveInstance;
@end
