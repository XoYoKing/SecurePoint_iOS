//
//  SPTabBarController.h
//  EmergencyApp
//
//  Created by Mzalih on 05/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatVideoViewController.h"
@interface SPTabBarController : UITabBarController

+(SPTabBarController*)getActiveInstance;
-(void) switchToMode:(NSString *) mode;

-(void)enable:(BOOL)chat with:(BOOL) audio and:(BOOL)video;

@property(nonatomic) ChatVideoViewController * vidooView;
@end
