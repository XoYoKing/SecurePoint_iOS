//
//  SPMainViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "AMSlideMenuMainViewController.h"

@interface SPMainViewController : AMSlideMenuMainViewController
+(SPMainViewController*)getActiveInstance;
-(void)openHomePage;
- (void) setNavigationColor:(UIViewController *)view;
@property (nonatomic)UIImageView *leftIconImage;
@property (nonatomic)int loginStatus;
@property (nonatomic)int tryToLogin;
@property (nonatomic, strong) NSMutableArray *regionArray;
@end
