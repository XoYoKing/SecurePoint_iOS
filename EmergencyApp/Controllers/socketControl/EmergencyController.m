 //
//  EmergencyController.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "EmergencyController.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "ChatgroupsController.h"
#import "SPMainViewController.h"
#import "QAConstants.h"
#import "Constants.h"
#import "SoundManager.h"
#import "ChatTypeViewController.h"
#import "SVProgressHUD.h"
#import "ChatsKindViewController.h"
#import "PortChecking.h"
#import "ClientEmergencyController.h"
#import "SPTabBarController.h"


#define  RECONNECT_DELAY_TIME 20

@interface EmergencyController (){
}
@end

@implementation EmergencyController

NSDictionary * emergenyRequest;
UIAlertView *askPermissionAlertView;
//NSString *regionId;

- (instancetype) init{
    self = [super init];
    _shouldBeConnected = NO;
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    self.connectionCallbacks = [NSMutableArray array];
    return self;
    
}
+ (instancetype) sharedInstance{
    return nil;
}
/*+ (instancetype) sharedInstance{
 static EmergencyController * sharedInstance = nil;
 
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 sharedInstance = [[self alloc] init];
 });
 return sharedInstance;
 }*/


#pragma mark Location

- (void) startPreciseLocationTracking{
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 100; // meters
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
        [_locationManager requestWhenInUseAuthorization];
    [_locationManager stopUpdatingLocation];
    [_locationManager startUpdatingLocation];
}

-(void) stopLocationTracking{
    [_locationManager stopUpdatingLocation];
}

-(NSArray *) getCurrentLocation{
    
    if(_locationManager.location){
        NSNumber *latitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.longitude];
        return @[longitude,latitude];
    }else{
        return nil;
    }
    
    
}

#pragma mark SocketIO
- (void) connectToServerWithParams:(NSDictionary*) dict{
   
    [dict setValue: @"v2" forKey:@"version" ];
    if(![_socketIO isConnected] && ![_socketIO isConnecting]){
        [_socketIO connectToHost:self.serverAddress onPort:PORT withParams:dict];
    }else if([_socketIO isConnected]){
        for(stateCallbackMethod cb in self.connectionCallbacks){
            cb(nil);
        }
        [self.connectionCallbacks removeAllObjects];
    }

}

//*******************
-(void) updateMode:(NSString *) mode forChatRoomID:(NSString *)chatRoomID{
    
    NSString * portStatus;
    
    if ([PortChecking sharedInstance].hasAblockedPort) {
        portStatus=@"true";
    }else{
        portStatus=@"false";
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:chatRoomID, @"chatRoomID",mode ,@"mode",portStatus,@"clientBlockStatus", nil];
    
    [_socketIO sendEvent:@"chatRoomUpdate" withData:dict andAcknowledge:^(id argsData) {
        
        NSLog(@"%@",argsData);
        
        if ([[NSString stringWithFormat:@"%@",[argsData valueForKey:@"clientBlockStatus"]] isEqualToString:@"1"])  {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firewall Alert" message:@"Audio/Video facility is not avaliable on other side" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }];
    
    [[ChatgroupsController sharedInstance] updateMode:mode forChatRoomID:chatRoomID];
}
-(void) joinChatRoomForChatRoomID:(NSString *)chatRoomID{
    [_socketIO sendEvent:@"joinChatRoom" withData:@{@"chatRoomID":chatRoomID}];
}

-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID withAck:(SocketIOCallback) function{
    
//    [_socketIO sendEvent:@"emergencyResolved" withData:@{@"chatRoomID":chatRoomID}];
    [_socketIO sendEvent:@"emergencyResolved" withData:@{@"chatRoomID":chatRoomID} andAcknowledge:function];
    
}

-(void) sendMessages:(NSArray *) messages toChatRoomID:(NSString *) chatRoomID{
    
    NSDictionary * data =@{@"chatRoomID": chatRoomID,
                           @"messages":messages};
    [_socketIO sendEvent:@"messages" withData:data andAcknowledge:^(id argsData) {
        int index =0;
        if([[argsData objectForKey:@"messages"]count]==[messages count])
            for(NSDictionary *data in messages){
                @try{
                    if([[[argsData objectForKey:@"messages"]objectAtIndex:index ] valueForKey:@"_id"]){
                        [data setValue:[[[argsData objectForKey:@"messages"]objectAtIndex:index ] valueForKey:@"_id"] forKey:@"_id"];
                    }
                }
                @catch (NSException *exception) {
                    
                }
                
                index++;
            }
    }];
}


-(void) OTTokenForChatRoomID:(NSString *) chatRoomID callback:(void(^)(NSString * sessionID, NSString * token))callback {
    NSDictionary * data =@{@"chatRoomID":chatRoomID};
    [_socketIO sendEvent:@"OTToken" withData:data andAcknowledge:^(id argsData) {
        NSDictionary * data = argsData;
        
        NSLog(@"Ack Event: AVRequest");
        NSLog(@"params:%@",data);
        
        callback(data[@"sessionID"],data[@"token"]);
    }];
}



- (void) disconnectFromServer{
    [_socketIO disconnect];
}

-(void)logoutOperator{
    [_socketIO sendEvent:@"logout" withData:nil];
}

#pragma mark socketIO delegate
- (void) socketIODidConnect:(SocketIO *)socket{
    
    for(stateCallbackMethod cb in self.connectionCallbacks){
        cb(nil);
    }
    [self.connectionCallbacks removeAllObjects];
    
    // CHECK ALL PORTS WE ARE USING
    [self checkPortsAvailability];
    NSLog(@"SocketIO connected:%@",socket);
}

-(void)checkPortsAvailability{
    // CHECKANY PORT IS BLOCKED
    
    //[[PortChecking sharedInstance]connectToServeForChecking: CHECKPORT];
    [[PortChecking sharedInstance]connectToServeForChecking: PORT443 withCallBack:^(bool status) {
        if(status == FALSE){
            //fIRST PORT IS OK SO CHECK SECOND PORT
            [[PortChecking sharedInstance]connectToServeForChecking:PORT3478  withCallBack:^(bool status) {
                if(status == FALSE){
                    //BOTH PORTS ARE OK
                    [self hasBlockedPort:false forPort:PORT3478];
                }else{
                    //SECOND PORT IS BLOCKED
                    [self hasBlockedPort:true forPort:PORT3478];
                }
                
            }];
        }else{
            // HAS A BLOCKED PORT NO
            [self hasBlockedPort:true forPort:PORT443];
        }
        
    }];

}
-(void)hasBlockedPort :(bool)status forPort: (int) blockedPort{
    //SET PORT STATUS FOR FUTURE REFERENCE
    [PortChecking sharedInstance].hasAblockedPort = status;
    
    
    if(status){
        // UPDATE SERVER :- THE PORT IS BLOCKED
      // [[ClientEmergencyController sharedInstance]portChecking:@"true"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"portChecking"];
        
        
        [PortChecking sharedInstance].blockedPort = blockedPort;
        
        //Show an alert to the user
        if(! [PortChecking sharedInstance].portCheckingCount)
        [[[UIAlertView alloc] initWithTitle:@"Firewall Alert" message:[NSString stringWithFormat:@"%i port is blocked!",blockedPort] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
         [PortChecking sharedInstance].portCheckingCount = true;
        
        //DISABLE THE TAB BAR BUTTONS
        if([SPTabBarController getActiveInstance]!= nil){
        [[[SPTabBarController getActiveInstance].tabBar.items objectAtIndex:1] setEnabled:NO];
        [[[SPTabBarController getActiveInstance].tabBar.items objectAtIndex:2] setEnabled:NO];
        }
        
    }else{
        
        
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"portChecking"];
           // UPDATE SERVER :- THE PORT IS AVAILABLE
      // [[ClientEmergencyController sharedInstance]portChecking:@"false"];
    }
    
}
-(void)reconnectServer{
    if(!(_socketIO.isConnected || _socketIO.isConnecting)){
        
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        NSString * userName = [prefs stringForKey:kClientName];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userName"]=userName;
        if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
            if([prefs stringForKey:kOperatorID]){
                dic[@"userID"] = [prefs stringForKey:kOperatorID];
            }
             dic[@"userRole"]=@"operator";
        }else if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
            if([prefs stringForKey:kClientID]){
                dic[@"userID"] = [prefs stringForKey:kClientID];
            }
             dic[@"userRole"]=@"client";
        }
        else{
            if([prefs stringForKey:kGuardianID]){
                dic[@"userID"] = [prefs stringForKey:kGuardianID];
            }
            dic[@"userRole"]=@"guardian";
        }
        NSString * deviceToken = [prefs stringForKey:kDeviceToken];
        if([deviceToken length]){
            dic[kDeviceToken] = deviceToken;
        }
        [self connectToServerWithParams:dic];
    }
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    
     for(stateCallbackMethod cb in self.connectionCallbacks){
        cb(error);
    }
    [self.connectionCallbacks removeAllObjects];
    if(error){
        if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
         [self performSelector:@selector(reconnectServer) withObject:nil afterDelay:RECONNECT_DELAY_TIME];
        }
    }
    NSLog(@"SocketIO Disconnected with error:%@",error);
    
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet{
    NSLog(@"SocketIO received Message:%@, data:%@",packet,packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet{
    NSLog(@"SocketIO received JSON:%@", packet);
}
 
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet{
    
    NSDictionary * data = [packet dataAsJSON];
    NSString * eventName = data[@"name"];
    NSDictionary * args =data[@"args"][0];
    NSLog(@"Received Event:%@",eventName);
    NSLog(@"params:%@",args);
    
    
    if( [SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR ){
        
        if([eventName isEqualToString:@"emergencyRequest"]){
            
           // regionId = [NSString stringWithFormat:@"%@", [args valueForKey:@"regionID"]];
            
            if(askPermissionAlertView == nil){
                NSLog(@"%@", args);
                emergenyRequest =args;
                [self askToAnswer];
                
            }
            
        }else if([eventName isEqualToString:@"userID"]){
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            [prefs setValue:args[@"userID"] forKeyPath:kOperatorID];
            self.userID =args[@"userID"];
        }
    }
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT && [eventName isEqualToString:@"userID"]){
         NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
         [prefs setValue:args[@"userID"] forKeyPath:kClientID];
        NSDictionary * args = data[@"args"][0];
        self.userID = args[@"userID"];
    }else if([eventName isEqualToString:@"messages"]){
        NSArray * messages = args[@"messages"];
        NSString * chatRoomID = args[@"chatRoomID"];
        NSMutableArray * typingMessages = [NSMutableArray array];
        NSMutableArray * finishedMessages = [NSMutableArray array];
        for(NSDictionary * message in messages){
            if([message[@"typing"] boolValue]){
                [typingMessages addObject:message];
            }else{
                [finishedMessages addObject:message];
            }
        }
        
        [[ChatgroupsController sharedInstance] addMessages:finishedMessages typingMessages:typingMessages toChatRoomID:chatRoomID];
        
    }else if([eventName isEqualToString:@"chatRoomUpdate"]){
        
        NSArray  * users      = args[@"users"];
        NSString * chatRoomID = args[@"chatRoomID"];
        NSString * mode       = args[@"mode"];
        NSDictionary *region = args[@"region"];
        
        
        if ([[NSString stringWithFormat:@"%@",[args valueForKey:@"clientBlockStatus"]] isEqualToString:@"true"])  {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firewall Alert" message:@"Audio/Video facility is not avaliable on other side" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        
        
        // IF IS RINGING AND SOME ONE ANSWERD THE CALL
        if(askPermissionAlertView){
            // IS RINGING
            for (NSDictionary *user in users){
                if([emergenyRequest[@"clientID"]isEqualToString:user[@"_id"] ]){
                    // SOME ONE ANSWERD THE CHAT
                    
                    [askPermissionAlertView dismissWithClickedButtonIndex:1 animated:true];
                    // HIDE THE ANSWER OPTION AND STOP RINGING
                    [self alertView:askPermissionAlertView clickedButtonAtIndex:1];
                }
            }
        }
        
        if(region != (NSDictionary*)[NSNull null] &&[region count]){
            
            // UPDATE FOR REAGIONS AVAILABLITY OF MODES
            
            // DEFAULT IS ALL ANABLED
            BOOL chatAvailable  = true;
            BOOL videoAvailable = true;
            BOOL audioAvailable = true;
            
            //SETTING FALSE FOR EACH ONE IF ANY OF THEM IS DISABLED
            if([region valueForKey:@"chat"]!= [NSNull null]){
                chatAvailable =[[region valueForKey:@"chat"]boolValue];
            }
            if([region valueForKey:@"audio"]!= [NSNull null]){
                audioAvailable =[[region valueForKey:@"audio"]boolValue];
            }
            if([region valueForKey:@"video"]!= [NSNull null]){
                videoAvailable =[[region valueForKey:@"video"]boolValue];
            }
            // UPDATE THE STATUS WITH NEW VALUES TO THE CHATROOM
            
            [[ChatgroupsController sharedInstance] updateAvailableModes:chatAvailable with:audioAvailable and :videoAvailable forChatRoomID:chatRoomID];
        }
        
        if([mode length]){
            // CHANGING CHAT MODE
            [[ChatgroupsController sharedInstance] updateMode:mode forChatRoomID:chatRoomID];
            
        }
        if([users count]){
            // NEW USER JOINED
            [[ChatgroupsController sharedInstance]  usersJoined:users chatRoomID:chatRoomID];
        }
        
    }else if([eventName isEqualToString:@"emergencyRequestCancel"]){
        
        // IF IS RINGING AND SOME ONE CANCELLED THE CALL
        if(askPermissionAlertView){
            // IS RINGING
                    [askPermissionAlertView dismissWithClickedButtonIndex:1 animated:true];
                    // HIDE THE ANSWER OPTION AND STOP RINGING
                    [self alertView:askPermissionAlertView clickedButtonAtIndex:1];
        }

    }
    else if([eventName isEqualToString:@"emergencyResolved"]){
        
        // CHAT RESOLVED BY SOME OPERATER
        NSString * chatRoomID = args[@"chatRoomID"];
        
        if ([[data valueForKey:@"name"] isEqualToString:@"emergencyResolved"]) {
            

              [[ChatgroupsController sharedInstance] emergencyResolvedForChatRoomID:chatRoomID];
            
        }
        
      
        
    }else if([eventName isEqualToString:@"userUpdate"]){
        // CHANGE IN USER DATA
        NSDictionary * userData = args;
        [[ChatgroupsController sharedInstance] updateUser:userData];
    }
    
    if([ChatTypeViewController getActiveInstance]!=nil){
        
        //UPDATE TYHE COUNT IN THE VIEW IF A CHANGE IN THE VIEW
        [[ChatTypeViewController getActiveInstance]updateCount];
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    NSString * type = packet.type;
    
    if([type isEqualToString:@"event"]){
        NSDictionary * data = [packet dataAsJSON];
        NSDictionary * args =data[@"args"][0];
        NSString * eventName = data[@"name"];
        
        NSLog(@"Send Event:%@",eventName);
        NSLog(@"params:%@",args);
    }
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
     [SVProgressHUD dismiss];
    @try {
        for(stateCallbackMethod cb in self.connectionCallbacks){
            cb(error);
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
    if(error){
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
    [self performSelector:@selector(reconnectServer) withObject:nil afterDelay:RECONNECT_DELAY_TIME];
    }
    }
    [self.connectionCallbacks removeAllObjects];

    
    NSLog(@"SocketIO onError:%@",error);  
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    NSLog(@"Location manager didUpdateLocation");
    NSLog(@"locations:%@",locations);
}


-(void)askToAnswer{
    
    [SoundManager sharedManager].allowsBackgroundMusic=true;
    NSUserDefaults * prefs =[NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:@"silentValue"] ) {
        [[SoundManager sharedManager]playMusic:@"sound2.caf"];
        [self showLocalNotification];
        askPermissionAlertView = [[UIAlertView alloc]initWithTitle:@"Emergency Request" message:@"You have a emergency request to answer" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Answer",@"Reject", nil];
        [askPermissionAlertView show];

    }
    [self clearNotifications];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    askPermissionAlertView = nil;
    [[SoundManager sharedManager]stopMusic];
    [self clearNotifications];
    
    if(buttonIndex ==0){
        // ANSWER CODE
        [_socketIO sendEvent:@"emergencyResponse"
                    withData:@{@"clientID":emergenyRequest[@"clientID"], @"regionID": emergenyRequest[@"regionID"] }
              andAcknowledge:^(id argsData) {
                  NSDictionary *response = argsData;
                  // todo maybe do this in usersJoined.. not very important
                  [ChatgroupsController sharedInstance].openedChatRoomID =response[@"chatRoomID"];
                  [[SPMainViewController getActiveInstance]openHomePage];
                  //[[ChatgroupsController sharedInstance] openChatForChatRoomID:response[@"chatRoomID"]];
              }];
    }else{
        //REGECT CODE
    }
}
-(void)showLocalNotification{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.alertBody = @"You have a emergency request to answer!";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber =[[UIApplication sharedApplication] applicationIconBadgeNumber]+ 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
- (void) clearNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


-(void)updateRegions:(SPLeftMenuViewController *)leftMenuController{
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    
    if( [SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
         dic[@"userRole"]=@"operator";
    if([prefs stringForKey:kOperatorID]){
        dic[@"userID"] = [prefs stringForKey:kOperatorID];
    }
    }else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
           dic[@"userRole"]=@"client";
        if([prefs stringForKey:kClientID]){
            dic[@"userID"] = [prefs stringForKey:kClientID];
        }
    }
    else{
         dic[@"userRole"]=@"guardian";
        if([prefs stringForKey:kGuardianID]){
            dic[@"userID"] = [prefs stringForKey:kGuardianID];
        }
    }
    if(!dic[@"userID"]){
         [self performSelector:@selector(updateRegions:) withObject:leftMenuController afterDelay:RECONNECT_DELAY_TIME];
        return;
    }

    stateCallbackMethod connectionCB = ^(NSError * error){
        if(error){
            //ERROR IN CONNECTION
        [self performSelector:@selector(updateRegions:) withObject:leftMenuController afterDelay:RECONNECT_DELAY_TIME];
        }else{
            //GET REGIONS
            [_socketIO sendEvent:@"getRegions" withData:dic andAcknowledge:^(id argsData) {
                
                NSLog(@"%@", argsData);
                
                [SPMainViewController getActiveInstance].regionArray = nil;
                if([argsData count]>0){
                    
                    [self updateLoginStatus: [SPMainViewController getActiveInstance].loginStatus];
                    
                    for (NSDictionary *data in argsData) {
                        if([SPMainViewController getActiveInstance]){
                            if(![SPMainViewController getActiveInstance].regionArray){
                                [SPMainViewController getActiveInstance].regionArray =[[NSMutableArray alloc]init];
                            }
                            [[SPMainViewController getActiveInstance].regionArray addObject:data];
                        }
                    }

                }else{
                    if([ChatgroupsController sharedInstance].openedChatRoomID == nil || [[ChatgroupsController sharedInstance].openedChatRoomID isEqualToString:@""] ){
                    [self disconnectFromServer];
                    }
                    [self updateLoginStatus:LOGGED_NONE];
                    [SPMainViewController getActiveInstance].loginStatus =LOGGED_NONE;
                    
                }
                [leftMenuController.tableView reloadData];
               // [leftMenuController viewWillAppear:false];
                [leftMenuController openHomePage];
            }];
            
        }
    };
     
if(_socketIO.isConnected)
{
    connectionCB(nil);
}else{
    
    [self connectToServerWithParams:dic];
    [self.connectionCallbacks addObject:connectionCB];
}
}
-(void) updateLoginStatus:(int)loginStatus{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:loginStatus forKey:kLOGINMODE];
    [prefs synchronize];
}




@end
