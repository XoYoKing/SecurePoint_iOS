//
//  SPTabBarController.m
//  EmergencyApp
//
//  Created by Mzalih on 05/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPTabBarController.h"
#import "SPMainViewController.h"
#import "ChatgroupsController.h"
#import "QAConstants.h"
#import "PortChecking.h"
#import "ClientEmergencyController.h"
@interface SPTabBarController ()

@end

@implementation SPTabBarController

static SPTabBarController* _sharedMyInstance = nil;
NSString *previusKeyBoard;

bool audioEnable = true;
bool videoEnable =true;
bool chatEnable = true;

+(SPTabBarController*)getActiveInstance
{
    if (_sharedMyInstance)
        return _sharedMyInstance;
    return nil;
}
-(void)enable:(BOOL)chat with:(BOOL) audio and:(BOOL)video{
    
    audioEnable = audio;
    videoEnable = video;
    chatEnable  = chat;
    
     //DISABLING AUDIO TAB AND VIDEO TAB IF 443 PORT IS BLOCKED.
    if ([PortChecking sharedInstance].hasAblockedPort) {
        
        [[[self.tabBar items] objectAtIndex:1] setEnabled:NO];
        [[[self.tabBar items] objectAtIndex:2] setEnabled:NO];
        
    }
    else
    {
        //DISABLE DISABLED TABS FOR BASED ON BACKEND ADMIN PORTAL
        if(audioEnable)
            [[[self.tabBar items] objectAtIndex:1] setEnabled:YES];
        else{
              [[[self.tabBar items] objectAtIndex:1] setEnabled:NO];
        }
        if(videoEnable)
            [[[self.tabBar items] objectAtIndex:2] setEnabled:YES];
        else{
            [[[self.tabBar items] objectAtIndex:2] setEnabled:NO];
        }
    }
    if(chatEnable){
        [[[self.tabBar items] objectAtIndex:0] setEnabled:YES];
    }else{
        [[[self.tabBar items] objectAtIndex:0] setEnabled:NO];
    }

}
- (void)viewDidLoad {
    
     [super viewDidLoad];
//   Do any additional setup after loading the view
     _sharedMyInstance =self;

    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    
    //FETCH AVAILABLE CHAT ROOM STATUS
    chatEnable = [[chatRoom valueForKey:@"chatAvailable"]boolValue];
    audioEnable =[[chatRoom valueForKey:@"audioAvailable"]boolValue];
    videoEnable =[[chatRoom valueForKey:@"videoAvailable"]boolValue];
    
    [self enable:chatEnable with:audioEnable and:videoEnable];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    [[UITabBar appearance]setTintColor:[QAConstants QAYellowColor]];
    
    self.navigationController .navigationBar.tintColor =[UIColor whiteColor];
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR ){
        // Is an operator so show back Button
        [self.navigationItem setHidesBackButton:NO];
       
    }else{
        [self.navigationItem setHidesBackButton:YES];
    }
    
    // Join the room if a new user
    [[ChatgroupsController sharedInstance]joinToChat:[ChatgroupsController sharedInstance].openedChatRoomID] ;

    [[ChatgroupsController sharedInstance] getOTTokencallback:^(NSString *sessionID, NSString *token) {
        [[ChatgroupsController sharedInstance]activateAudio:FALSE andVideo:FALSE];
        [[ChatgroupsController sharedInstance]doConnect];
    }];
    [self switchToMode:chatRoom[@"mode"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForDictationKeyboard:)
                                                 name:@"UITextInputCurrentInputModeDidChangeNotification"
                                               object:nil];
    
   }
- (void)checkForDictationKeyboard:(NSNotification *)note {
    
    NSString *primaryLanguage = [UITextInputMode currentInputMode].primaryLanguage;
    if([primaryLanguage isEqualToString:@"dictation"]){
         [[ChatgroupsController sharedInstance]stopStreamingSiri];
    }
    else{
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [[ChatgroupsController sharedInstance]doConnect];
    }
    previusKeyBoard = primaryLanguage;

}



-(void)viewDidDisappear:(BOOL)animated{
        [[ChatgroupsController sharedInstance]activateAudio:FALSE andVideo:FALSE];
        [[ChatgroupsController sharedInstance]stopStreaming];
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR)
        [ChatgroupsController sharedInstance].openedChatRoomID=nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchToMode:(NSString *) mode{
    @try {
       
        if(!mode){
            mode=@"chat";
        }
    if([mode isEqualToString:@"audio"]){
        if(audioEnable){
            [self setSelectedIndex:1];
        }else{
            [self switchToMode:@"video"];
        }
    }else if([mode isEqualToString:@"video"]){
        if(videoEnable){
            [self setSelectedIndex:2];
        }else{
              [self switchToMode:@"chat"];
        }
    }else if(chatEnable) {
        [self setSelectedIndex:0];
    }
    else if(chatEnable||audioEnable||videoEnable){
          [self switchToMode:@"audio"];
    }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

@end
