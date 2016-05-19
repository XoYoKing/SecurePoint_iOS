//
//  ChatgroupsController.m
//  EmergencyApp
//
//  Created by Mzalih on 04/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatgroupsController.h"
#import "ClientEmergencyController.h"
#import "SPTabBarController.h"
#import "SPMainViewController.h"
#import "SVProgressHUD.h"
#import "QAConstants.h"
#import "EmergencyController.h"

// Replace with your OpenTok API key
// static NSString *const kApiKey = @"45093062";
static NSString *const kApiKey = @"45089312";
UIView * currentVideoView;
id audioButton;
id micButton;

@interface ChatgroupsController (){
    
@protected
    
    NSMutableDictionary *allStreams;
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    UIView * _videoView;
    
    BOOL _publishAudio;
    BOOL _publishVideo;
    BOOL _receiveAudio;
    BOOL _receiveVideo;
    
}
@end
@implementation ChatgroupsController


- (instancetype) init{
    
    self = [super init];
    _chatRooms = [NSMutableArray array];
    _users = [NSMutableDictionary dictionary];
    return self;
}

+ (instancetype) sharedInstance{
    static ChatgroupsController * sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(void)joinToChat:(NSString *)chatRoomID{
    // JOIN TO CHAT IF TRYING TO JOIN A EXISTING CHAT
    //   NSMutableDictionary * chatRoom = [self getOrCreateChatRoomWithID:chatRoomID];
    //   NSMutableArray *users = chatRoom[@"users"];
    // NSString *myID = [[ClientEmergencyController sharedInstance]getUserID];
    // if([[[NSMutableArray alloc]initWithArray:
    //                 [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == myID)"]]]count]<=0)
    // CHECK ALRADY IN OR NOT
    [[ClientEmergencyController sharedInstance]joinChatRoomForChatRoomID:chatRoomID];
    
    
}
-(void)setMicButton:(id)mic andSound:(id)sound{
    micButton =mic;
    audioButton=sound;
}
-(NSDictionary *) getUserForUserID:(NSString *) userID{
    //RETUTN IF EXIST A USER
    return self.users[userID];
}

-(NSMutableDictionary *) getOrCreateChatRoomWithID:(NSString *) chatRoomID{
    
    NSMutableDictionary* chatRoomToFind = nil;
    for(NSMutableDictionary * chatRoom in self.chatRooms){
        if([chatRoom[@"_id"] isEqualToString:chatRoomID]){
            chatRoomToFind = chatRoom;
        }
    }
    
    if(!chatRoomToFind){
        @try {
            chatRoomToFind = [NSMutableDictionary dictionary];
            chatRoomToFind[@"_id"] = chatRoomID;
            chatRoomToFind[@"messages"] = [NSMutableArray array];
            chatRoomToFind[@"typingMessages"] = [NSMutableArray array];
            chatRoomToFind[@"users"] = [NSMutableArray array];
            
            [self.chatRooms addObject:chatRoomToFind];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
        
    }
    return chatRoomToFind;
}
- (void) updateMode:(NSString *) mode forChatRoomID:(NSString *) chatRoomID{
    NSMutableDictionary * chatRoom = [self getOrCreateChatRoomWithID:chatRoomID];
    if(![chatRoom[@"mode"] isEqualToString:mode]){
        chatRoom[@"mode"] = mode;
        if([chatRoomID isEqualToString:self.openedChatRoomID]){
            
            [[SPTabBarController getActiveInstance] switchToMode:mode];
            
        }
    }
}
- (void) updateAvailableModes:(BOOL )chat with:(BOOL )audio and :(BOOL )video forChatRoomID:(NSString *) chatRoomID{
    //GET TGE CHAT ROOM OBJECT
    NSMutableDictionary * chatRoom = [self getOrCreateChatRoomWithID:chatRoomID];
    
    if(chat)
        chatRoom[@"chatAvailable"] = @"1";
    else
        chatRoom[@"chatAvailable"] = @"0";
    if(audio)
        chatRoom[@"audioAvailable"] = @"1";
    else
        chatRoom[@"audioAvailable"] = @"0";
    if(video)
        chatRoom[@"videoAvailable"] = @"1";
    else
        chatRoom[@"videoAvailable"] = @"0";
    
        if([chatRoomID isEqualToString:self.openedChatRoomID] && [SPTabBarController getActiveInstance]){
            
             [[SPTabBarController getActiveInstance] enable:chat with:audio and:video];
        }
}
- (void) usersJoined:(NSArray *) users chatRoomID:(NSString *) chatRoomID{
    
    
    NSMutableDictionary* chatRoomToUpdate = [self getOrCreateChatRoomWithID:chatRoomID];
    NSMutableArray     * updatedUsers = [NSMutableArray arrayWithCapacity:[users count]];
    NSMutableArray *availableUsers = nil;
    
    @try {
        
        availableUsers =chatRoomToUpdate[@"users"];
    }
    @catch (NSException *exception) {
        
    }
    for(NSDictionary * user   in users){
        
        if((availableUsers != nil) && [[availableUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(_id like %@)",[user objectForKey:@"_id"]]]count]<=0){
        [updatedUsers addObject:[self updateUsersWithUser:user]];
        }
    }
    [chatRoomToUpdate[@"users"] addObjectsFromArray:updatedUsers];
    
    
}
-(void) emergencyResolvedForChatRoomRow:(NSInteger) row{
    
    NSDictionary * chatRoom = self.chatRooms[row];
    [self emergencyResolvedForChatRoomID:chatRoom[@"_id"]];
}

-(void) updateUser:(NSDictionary *)user{
    // UPDATE THE COUNT ,USER TABLE IN THE CURRENT CHAT MODE ETC
}

-(NSMutableDictionary *) updateUsersWithUser:(NSDictionary *) user{
    if(self.users[user[@"_id"]]){
        [self.users[user[@"_id"]] addEntriesFromDictionary:user];
    }else{
        [self.users setObject:[user mutableCopy] forKey:user[@"_id"]];
    }
    return self.users[user[@"_id"]];
}


-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID{
    
    
    for(int i = 0; i < [self.chatRooms count]; i++){
        NSDictionary * chatRoom = self.chatRooms[i];
        if([chatRoom[@"_id"] isEqualToString:chatRoomID]){
            [self.chatRooms removeObjectAtIndex:i];
            
            // remove users if they are not in different chatrooms
            for(NSDictionary * user in chatRoom[@"users"]){
                if(![self isUserInAnyChatRoom:user]){
                    [self.users removeObjectForKey:user[@"_id"]];
                }
            }
            break;
        }
    }
    if([chatRoomID isEqualToString:self.openedChatRoomID]){
        self.openedChatRoomID=nil;
    
        [self.currentView emergencyResolved];
    }
}

- (NSArray*) getChatRooms{
    
    return self.chatRooms;
}



-(void) addMessages:(NSArray *)messages typingMessages:(NSArray *) typingMessages toChatRoomID:(NSString *)chatRoomID{
    
    NSMutableDictionary * chatRoomToUpdate = [self getOrCreateChatRoomWithID:chatRoomID];
    
     NSMutableArray * oldTypingMessages = chatRoomToUpdate[@"typingMessages"];
    if([typingMessages count]){
       
        
        for(NSDictionary * message in typingMessages){
            BOOL updated = NO;
            for(int i = 0; i < [oldTypingMessages count]; i++){
                NSDictionary * oldMessage = oldTypingMessages[i];
                if([oldMessage[@"fromID"]  isEqualToString:message[@"fromID"]]){
                    [oldTypingMessages replaceObjectAtIndex:i withObject:message];
                    updated = YES;
                }
            }
            if(!updated){
                [chatRoomToUpdate[@"typingMessages"] addObject:message];
            }
        }
    }
    
//    if([messages count]){
//        NSMutableArray * oldMessages = chatRoomToUpdate[@"messages"];
//        
//        [oldMessages addObjectsFromArray:messages];
//    }
     NSMutableArray * oldMessages = chatRoomToUpdate[@"messages"];
    NSMutableArray *newMessages =[[NSMutableArray alloc]init];
    if([messages count]){
        for(NSDictionary * message in messages){
            NSArray *exData =[oldMessages valueForKey:@"_id"];
            if(![exData containsObject:[message objectForKey:@"_id"]]){
                [newMessages addObject:message];
             [oldMessages addObjectsFromArray:messages];
            }
        }
    }
    
    
    
    if([chatRoomID isEqualToString:self.openedChatRoomID]){
        [self.chatVC addMessages:newMessages typingMessages:typingMessages];
    }
    
}


- (void) addChatRooms:(NSArray *) chatRooms{
    for(NSDictionary * chatRoom in chatRooms){
        NSMutableDictionary * newChatRoom = [chatRoom mutableCopy];
        if(chatRoom[@"messages"]){
            newChatRoom[@"messages"] = [chatRoom[@"messages"] mutableCopy];
        }else{
            newChatRoom[@"messages"] = [NSMutableArray array];
        }
        [_chatRooms addObject:newChatRoom];
    }
}

- (void) currentLocationUpdated{
    // [self.tableView reloadData];
}

#pragma mark Helpers
- (BOOL) isUserInAnyChatRoom:(NSDictionary *) user{
    BOOL found = NO;
    for(NSDictionary * chatRoom in self.chatRooms){
        if([chatRoom[@"users"] indexOfObjectIdenticalTo:user] != NSNotFound){
            found = YES;
            break;
        };
        
    }
    return found;
}
-(void) getOTTokencallback:(void(^)(NSString * sessionID, NSString * token))callbackToView {
    
    
    [[ClientEmergencyController sharedInstance] OTTokenForChatRoomID:self.openedChatRoomID callback:^(NSString *sessionID, NSString *token) {
        
        NSLog(@" INITIATED THE  SESSION :%@, TOCKEN:%@",sessionID, token);
        
        
        self.sessionID = sessionID;
        self.token     = token;
        
        callbackToView(sessionID,token);
        
    }];
}




#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect{
    
    if(!_session)
    {
        _session = [[OTSession alloc] initWithApiKey:kApiKey sessionId:self.sessionID delegate:self];
    }
    if([_session sessionConnectionStatus] == OTSessionConnectionStatusConnected){
        [self doPublish];
        [self updateSubScriber];
    }else if(![_session sessionConnectionStatus] == OTSessionConnectionStatusConnected){
        OTError *error = nil;
        [_session connectWithToken:self.token error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
            
        }
    }
}

-(void)doDisconnect
{
    OTError *error = nil;
    [_session disconnect:&error];
    _session = nil;
    if (error)
    {
        // [self showAlert:[error localizedDescription]];
    }
    
}



/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    if(!_publisher){
        _publisher = [[OTPublisher alloc] initWithDelegate:self];
        _publisher.publishAudio = _publishAudio;
        _publisher.publishVideo = _publishVideo;
        
        OTError *error = nil;
        [_session publish:_publisher error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
    }else{
        _publisher.publishAudio = _publishAudio;
        _publisher.publishVideo = _publishVideo;
    }
    
    CGRect frame = [SPTabBarController getActiveInstance].vidooView.videoView.frame;
    [_publisher.view setFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
    [self removeCurrentViewWith:_publisher.view];
    [[SPTabBarController getActiveInstance].vidooView.videoView addSubview:_publisher.view];
    
    
}
-(void)removeCurrentViewWith:(UIView *)view{
    if(currentVideoView && currentVideoView != view){
        [currentVideoView removeFromSuperview];
        
        if(_publisher){
            if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
                _publisher.view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            } else {
                _publisher.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }
        }
    }
    currentVideoView = view;
}

- (void)doUnpublish{
    
    OTError *error = nil;
    if(_publisher){
        [_session unpublish:_publisher error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
        _publisher = nil;
    }
}
-(void)activateAudio:(BOOL)audioStatus andVideo :(BOOL)videoStatus{
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
        _publishVideo = FALSE;
        _receiveVideo = videoStatus;
    }else{
        _receiveVideo =FALSE;
        _publishVideo = videoStatus;
    }
    _receiveAudio = audioStatus;
    _publishAudio = audioStatus;
    [self activeAudioAndVideo];
    [self changeButtons];
}
-(void)activeAudioAndVideo{
    if(_publisher){
        _publisher.publishAudio =_publishAudio;
        _publisher.publishVideo = _publishVideo;
    }
    if(_subscriber){
        _subscriber.subscribeToAudio =_receiveAudio;
        _subscriber.subscribeToVideo =_receiveVideo;
    }
}

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
    [self updateSubScriber];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    _publisher = nil;
    _subscriber = nil;
    
}



- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    [self doSubscribe:stream];
    
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self doUnsubscribe];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
    
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self doUnsubscribe];
    }
}

//TO CHECK THE PORT IS OPENED OR BLOCKED FOR OPEN-TOK
- (void) session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Port Blocked" message:@"Port needs to be opened." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    
//    [alert show];
    
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriber *)subscriber
{
    //[SVProgressHUD dismiss];
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    //  assert(_subscriber == subscriber);
    @try {
        _subscriber =subscriber;
    }
    @catch (NSException *exception) {
        
    }
    
    [self updateSubScriber];
}

- (void)subscriber:(OTSubscriber*)subscriber
  didFailWithError:(OTError*)error
{
    //[SVProgressHUD dismiss];
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 */
- (void)doUnsubscribe
{
    OTError *error = nil;
    [_session unsubscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    // [_subscriber.view removeFromSuperview];
    _subscriber = nil;
    // [self moveChatViewWithTopOffset:0];
}


# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisher*)publisher
    streamCreated:(OTStream *)stream
{
    // [SVProgressHUD dismiss];
}

- (void)publisher:(OTPublisher*)publisher
  streamDestroyed:(OTStream *)stream
{
    //   [SVProgressHUD dismiss];
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self doUnsubscribe];
    }
}

- (void)publisher:(OTPublisher*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
}
- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" CHAT STOPPED "
        //                                                        message:string
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil] ;
        //          [alert show];
    });
}

-(void) updateSubScriber{
    
    _receiveAudio =TRUE;
    //_receiveVideo =TRUE; //
    _receiveVideo =[SPMainViewController getActiveInstance].loginStatus ==LOGGED_OPERATOR;
    
    if(_subscriber){
        _subscriber.subscribeToAudio = _receiveAudio;
        _subscriber.subscribeToVideo = _receiveVideo;
        if( _receiveVideo){
            if(_subscriber.stream.hasVideo || currentVideoView ==nil ){
            CGRect frame = [SPTabBarController getActiveInstance].vidooView.videoView.frame;
            [_subscriber.view setFrame:CGRectMake(0, 0, frame.size.width,
                                                  frame.size.height)];
            [[SPTabBarController getActiveInstance].vidooView.videoView addSubview:_subscriber.view];
            [self removeCurrentViewWith:_subscriber.view];
            }
        }
    }
    [self changeButtons];
}
-(void)updateSubscriber:(OTSubscriber *)subscriber{
    CGRect frame = [SPTabBarController getActiveInstance].vidooView.videoView.frame;
    [_subscriber.view setFrame:CGRectMake(0, 0, frame.size.width,
                                          frame.size.height)];
    [[SPTabBarController getActiveInstance].vidooView.videoView addSubview:_subscriber.view];
    [self removeCurrentViewWith:_subscriber.view];
}
-(void)subscriberVideoDataReceived:(OTSubscriber *)subscriber{
    // [SVProgressHUD dismiss];
        NSLog(@"DATA RECEVIED");
        _subscriber =subscriber;
        [self updateSubscriber:subscriber];
    
}
-(void)resetStreamning{
    if((_publisher && !_publisher.stream.hasAudio )|| (_subscriber ||!_subscriber.stream.hasAudio)){
        [self stopStreaming];
    
    }
}

//METHOD FOR STOPPING OPEN-TOK AUDIO WHEN SIRI PRESSED.
-(void)stopStreamingSiri{
    // STOP STREAMING
    NSLog(@"STOPPING STREAM >> >> >>");
    // [SVProgressHUD dismiss];
    //_sessionID =nil;
    //_token = nil;
    if(_subscriber && _subscriber.view){
        [_session unsubscribe:_subscriber error:nil];
        [_subscriber.view removeFromSuperview];
    }
    if(_publisher && _publisher.view){
        [_session unpublish:_publisher error:nil];
        [_publisher.view removeFromSuperview];
    }
    //stop subscription
    _subscriber = nil;
    _publisher = nil;
    _session = nil;
    
}


//-(void)resetStreamning{
//    if((_publisher && !_publisher.stream.hasAudio )|| (_subscriber ||!_subscriber.stream.hasAudio)){
//        //[self doPublish];
//        //        [self  activateAudio:YES andVideo:NO];
//        
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [self doConnect ];
//        
//        // -(void)activateAudio:(BOOL)audioStatus andVideo :(BOOL)videoStatus{
//    }
//}


-(void)stopStreaming{
    // STOP STREAMING
    NSLog(@"STOPPING STREAM >> >> >>");
    // [SVProgressHUD dismiss];
    _sessionID =nil;
    _token = nil;
    if(_subscriber && _subscriber.view){
        [_session unsubscribe:_subscriber error:nil];
        [_subscriber.view removeFromSuperview];
    }
    if(_publisher && _publisher.view){
        [_session unpublish:_publisher error:nil];
        [_publisher.view removeFromSuperview];
    }
    //stop subscription
    _subscriber = nil;
    _publisher = nil;
    _session = nil;
    
}
-(void)switchCam{
    if(_publisher){
        if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
            _publisher.cameraPosition =AVCaptureDevicePositionBack;
             _publisher.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        } else {
            _publisher.cameraPosition = AVCaptureDevicePositionFront;
            _publisher.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
    }
}
-(BOOL)micOff{
    if(_publisher){
        if(_publisher.publishAudio){
            _publisher.publishAudio =false;
            return false;
            
        }else{
            _publisher.publishAudio =true;
            return true;
        }
    }
    return  _publisher.publishAudio;
}
-(BOOL)soundOff{
    if(_subscriber){
        if(_subscriber.subscribeToAudio){
            _subscriber.subscribeToAudio =false;
            return false;
        }else{
            _subscriber.subscribeToAudio =true;
            return true;
        }
    }
    return _subscriber.subscribeToAudio;
}
-(void)changeVideoFrame:(CGRect)height{
    if(currentVideoView){
        [currentVideoView setFrame:height];
        
    }
//    if(_subscriber.subscribeToVideo){
//        [_subscriber.view setFrame:height];
//        
//    }
//    if (_publisher.publishVideo){
//        [_publisher.view setFrame:height];
//    }
}
-(void)changeButtons{
    [self audioChanged];
    [self micChanged];
}
- (void)audioChanged {
    if (audioButton && _subscriber) {
        UIButton *button =audioButton;
        if(_subscriber && _subscriber.subscribeToAudio){
            [button setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
        }else{
            [button setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
        }
    }
}

- (void)micChanged {
    
    if (micButton && _publisher) {
        UIButton *button =micButton;
        if(_publisher && _publisher.publishAudio){
            [button setImage:[UIImage imageNamed:@"micOn"] forState:UIControlStateNormal];
        }else{
            [button setImage:[UIImage imageNamed:@"micOff"] forState:UIControlStateNormal];
        }
        
    }
}
@end

