//
//  ChatVideoViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 05/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatVideoViewController.h"
#import "ChatgroupsController.h"
#import "SPMainViewController.h"
#import "SPTabBarController.h"
#import "QAConstants.h"
#import "ClientEmergencyController.h"
@interface ChatVideoViewController ()

@end

@implementation ChatVideoViewController
NSString    *_sessionID;
NSString    *_token;
CGRect      videoFrame;
NSTimer* myTimer;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [self timer:7.0];
    // Do any additional setup after loading the view.
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
  //  CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    // UNLOCK THE HIDDEN VIEW
    [self unlock];
    [self timer:7.0];
    //Do stuff here...
}
-(void)timer:(float)number{
    // LOCK AFTER A TIME
    if(myTimer){
        [myTimer invalidate];
    }
    myTimer = [NSTimer scheduledTimerWithTimeInterval: number target: self
                                             selector: @selector(lock) userInfo: nil repeats: NO];
}
-(void)unlock{
    // UNLOCK NOW
    if( _controllerView.hidden){
        
        _controllerView.hidden= false;
        [UIView animateWithDuration:1.0 animations:^{
            _controllerView.alpha =1;
        }];
        
    }
}
-(void)lock{
    // LOCK NOW
    if( !_controllerView.hidden){

        [UIView animateWithDuration:1.0 animations:^{
            _controllerView.alpha =0;
             _controllerView.hidden= true
;
        }];
        
    }
}
-(void)clearView{
    //REMOVE OLD VIDEO VIEWS
    for(UIView *view in[_videoView subviews]){
        [view removeFromSuperview];
    }
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
    
    self.title =@"Video";
    self.tabBarController.title=@"Video";
    [SPTabBarController getActiveInstance].vidooView =self;
    self.navigationController.navigationBar.barTintColor =[QAConstants QARedColor];

    // ADD CHAT VIEW
    [self addchatView];
    // INITATE VEDIO CHAT
    [self initiateVedioChat];
   // [[ChatgroupsController sharedInstance]resetStreamning];
    [[ChatgroupsController sharedInstance] getOTTokencallback:^(NSString *sessionID, NSString *token) {
        _sessionID =sessionID;
        _token =token;
        [[ChatgroupsController sharedInstance]setMicButton:_swichMic andSound:_swichSound];
        [[ChatgroupsController sharedInstance]activateAudio:TRUE andVideo:TRUE];
        [[ChatgroupsController sharedInstance]doConnect];
        
    }];
}
-(void)addchatView{
    
    //THE VIEW FROM CHAT TO THE CURRENT VIEW
    UIView  *subview =[ChatgroupsController sharedInstance].chatVC.view;
   // subview.backgroundColor =[UIColor redColor];
    CGRect frame =_chatView.frame;
    frame.origin.x=0;
    frame.origin.y=0;
    subview.frame=frame;
    
    [_chatView addSubview:subview];
    if(_videoView){
        // HIDE VIEW
    [self.view addSubview:_videoView];
    }
    if(_controllerView){
        // HIDE CAM
        [self hideswitchCam];
    }
}
-(void)hideswitchCam{
    // SWITCH THE CAMERA
    [self.view addSubview:_controllerView];
    
//    if([SPMainViewController getActiveInstance].isOperrator ){
//        [_swichCamButton setHidden:true];
//    }else{
//        [_swichCamButton setHidden:false];
//    }
}
-(void)initiateVedioChat{
    
    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    // CHECK A NEW SWITCH TO CHAT MODE
    if(![chatRoom[@"mode"] isEqualToString:@"video"]){
        // UPDATE THE SERVER WITH THE CHANHGE IN VIDEO
    [[ClientEmergencyController sharedInstance] updateMode:@"video" forChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
     if([chatRoom[@"mode"] isEqualToString:@"video"]){
         // STOP VIDEO STREAMING
         //[[ChatgroupsController sharedInstance]stopStreaming];
             [[ChatgroupsController sharedInstance]activateAudio:FALSE andVideo:FALSE];
     }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)toggleFullScreen{
    // TOGGLE BETWEEN THE FULL SCREEN
    [self unlock];
    [self timer:7.0];
    if(self.view.frame.size.height !=_videoView.frame.size.height){
        videoFrame =_videoView.frame;
        
        CGRect _frame      = _videoView.frame;
        _frame.size.height = self.view.frame.size.height;
        
        CGRect vidFrame = _frame;
        vidFrame.origin.x=vidFrame.origin.y=0;
        
        CGRect controllerFrame = _controllerView.frame;
        controllerFrame.origin.y=vidFrame.size.height  -100;;
        
        
        [UIView animateWithDuration:0.5 animations:^{
            _videoView.frame   =_frame;

             [[ChatgroupsController sharedInstance]changeVideoFrame:vidFrame];
             _controllerView.frame = controllerFrame;
        }];
    }else{
        
        CGRect _frame      = _videoView.frame;
        _frame.size.height = videoFrame.size.height;
        
        CGRect vidFrame = _frame;
        vidFrame.origin.x=vidFrame.origin.y=0;
        
        CGRect controllerFrame = _controllerView.frame;
        controllerFrame.origin.y=_frame.size.height-100+_frame.origin.y ;
        
        [UIView animateWithDuration:0.5 animations:^{
            _videoView.frame   =_frame;
             [[ChatgroupsController sharedInstance]changeVideoFrame:vidFrame];
            _controllerView.frame = controllerFrame;
           
        }];
    }
}
- (IBAction)switchCam:(id)sender {
    // SWITCH CAM
    [self unlock];
    [self timer:7.0];
    
    [[ChatgroupsController sharedInstance]switchCam];
}

- (IBAction)micOff:(id)sender {
    // SWITCH MIC ON OR OFF
    [self unlock];
    [self timer:5.0];
    
   UIButton *button =sender;
    if(  [[ChatgroupsController sharedInstance]micOff]){
         //CHANGE ICON
     [button setImage:[UIImage imageNamed:@"micOn"] forState:UIControlStateNormal];
        
    }else{
         //CHANGE ICON
   [button setImage:[UIImage imageNamed:@"micOff"] forState:UIControlStateNormal];
    }
}

- (IBAction)mute:(id)sender {
    // TOGGLE MUTE THE SPEAKERS
    [self unlock];
    [self timer:5.0];
     CGRect _frame      = _controllerView.frame;
     UIButton *button =sender;
    if([[ChatgroupsController sharedInstance]soundOff]){
        //CHANGE ICON
        [button setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
    }else{
        //CHANE ICON
  [button setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
    }
    _controllerView.frame =_frame;
}

- (IBAction)toggleScreen:(id)sender {
    // INITAIATE TOGGLE FULL SCREEN
    [self toggleFullScreen];
}
 @end
