//
//  ChatAudioViewController.m
//  EmergencyApp
//
//  Created by Muhammed Salih on 10/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatAudioViewController.h"
#import "ChatgroupsController.h"
#import "ClientEmergencyController.h"
#import "QAConstants.h"
@interface ChatAudioViewController ()

@end

@implementation ChatAudioViewController
NSString *_sessionID;
NSString *_token;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =@"Audio";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)becomeActive{
    [[ChatgroupsController sharedInstance]resetStreamning];
    [self viewWillAppear:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    self.tabBarController.title= @"Audio";
    self.navigationController.navigationBar.barTintColor =[QAConstants QAOrangeColor];
    [[UITabBar appearance] setTintColor:[QAConstants QAOrangeColor]];
    [self addchatView];
    [self initiateAudioChat];
   // [[ChatgroupsController sharedInstance]resetStreamning];
    
    [[ChatgroupsController sharedInstance] getOTTokencallback:^(NSString *sessionID, NSString *token) {
            _sessionID =sessionID;
            _token =token;
        [[ChatgroupsController sharedInstance]setMicButton:_swichMic andSound:_swichSound];
         [[ChatgroupsController sharedInstance]activateAudio:TRUE andVideo:FALSE];
        [[ChatgroupsController sharedInstance]doConnect];
       
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)initiateAudioChat{
    
    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    if(![chatRoom[@"mode"] isEqualToString:@"audio"]){
        [[ClientEmergencyController sharedInstance] updateMode:@"audio" forChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
    }
}
-(void)addchatView{
    UIView  *subview =[ChatgroupsController sharedInstance].chatVC.view;
    subview.frame= CGRectMake(0, 200, subview.frame.size.width, self.view.frame.size.height-200);
    [self.view addSubview:subview];
       [self.view addSubview:_controllerView];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    if([chatRoom[@"mode"] isEqualToString:@"audio"]){
        // [[ChatgroupsController sharedInstance]stopStreaming];
            [[ChatgroupsController sharedInstance]activateAudio:FALSE andVideo:FALSE];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)audioClicked:(id)sender {
    UIButton *button =sender;
    if([[ChatgroupsController sharedInstance]soundOff]){
        [button setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
    }

}

- (IBAction)micClick:(id)sender {
    UIButton *button =sender;
    if(  [[ChatgroupsController sharedInstance] micOff]){
        [button setImage:[UIImage imageNamed:@"micOn"] forState:UIControlStateNormal];
        
    }else{
        [button setImage:[UIImage imageNamed:@"micOff"] forState:UIControlStateNormal];
    }
}
@end
