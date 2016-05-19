    //
//  UserEmergencyController.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 24/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "ClientEmergencyController.h"
#import "SocketIOPacket.h"
#import "QAConstants.h"
#import "SPMainViewController.h"
#import <AFNetworking.h>
#import "PortChecking.h"
#import "SPTabBarController.h"

@interface ClientEmergencyController (){
    
}
@property(nonatomic) NSString * clientID;
@property(nonatomic) NSMutableArray * locationCallbacks;

@end

@implementation ClientEmergencyController
NSMutableDictionary *userDetails;

- (instancetype) init{
    self = [super init];
    self.role = @"client";
    self.locationCallbacks = [NSMutableArray array];
    return self;
}

+ (instancetype) sharedInstance{
    static ClientEmergencyController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(NSString *) getUserID{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
        if([prefs stringForKey:kOperatorID]){
            return [prefs stringForKey:kOperatorID];
        }
    }else if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
        if([prefs stringForKey:kClientID]){
            return [prefs stringForKey:kClientID];
        }
    }
    else{
        if ([prefs stringForKey:kGuardianID]) {
            return [prefs stringForKey:kGuardianID];
        }
    }
    return @"";
}



-(void) connectToServer{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
        data[@"userRole"] = @"operator";
        if([prefs stringForKey:kOperatorID]){
            data[@"userID"] = [prefs stringForKey:kOperatorID];
        }
    }else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
        data[@"userRole"] = @"client";
        if([prefs stringForKey:kClientID]){
            data[@"userID"] = [prefs stringForKey:kClientID];
        }
    }else {
        data[@"userRole"] = @"guardian";
        if ([prefs stringForKey:kGuardianID]) {
            data[@"userID"] = [prefs stringForKey:kGuardianID];
        }
    }
    
    @try {
        data[@"userName"] = [prefs stringForKey:kClientName];
        data[@"userPhone"] = [prefs stringForKey:kClientPhone];
        [super connectToServerWithParams:data];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

-(void) startEmergency:(stateCallbackMethod) callback{
    
    __block BOOL isConnected = NO;
    __block BOOL haveLocation = NO;
    __block BOOL callbackCalled = NO;
    
    __weak typeof(self) weakSelf = self;
    stateCallbackMethod connectionCB = ^(NSError * error){
        if(error){
            if(!callbackCalled){
                callbackCalled = YES;
                callback(error);
            }
        }else{
            isConnected = YES;
            if(isConnected && haveLocation){
                [weakSelf contactOperator:callback];
            }
        }
    };
    
    [self.connectionCallbacks addObject:[connectionCB copy]];
    //******************************
    stateCallbackMethod locationCB = ^(NSError * error){
        if(error){
            if(!callbackCalled){
                callbackCalled = YES;
                callback(error);
            }
        }else{
            haveLocation = YES;
            if(isConnected && haveLocation){
                [weakSelf contactOperator:callback];
            }
        }
    };
    [self.locationCallbacks addObject:[locationCB copy]];
    
    [self startPreciseLocationTracking];
    _shouldBeConnected = YES;
    [self connectToServer];
    
}

- (void) contactOperator:(stateCallbackMethod) callback{
    
    NSNumber *latitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:_locationManager.location.coordinate.longitude];
    
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    userDetails = [self.userProfile mutableCopy];
    userDetails[@"userName"] = [prefs stringForKey:kClientName];
    userDetails[@"userPhone"] = [prefs stringForKey:kClientPhone];
    userDetails[@"userRole"] = @"client";
    
    
    userDetails[@"location"] =@{
                                @"type":@"Point",
                                @"coordinates":@[longitude, latitude]
                                };
    
    NSLog(@"Send Event: emergencyRequest");
    NSLog(@"params:%@",userDetails);
    
    [_socketIO sendEvent:@"emergencyRequest" withData:userDetails andAcknowledge:^(id argsData) {
              NSDictionary *response = argsData;
              self.clientID = response[@"clientID"];
              //    NSLog(@"Ack Event: emergencyRequest");
              //   NSLog(@"params:%@",argsData);
              if([response[@"code"]isEqualToString: rcNO_OPERATOR]){
                  [[[UIAlertView alloc]initWithTitle:@"NO OPERATOR" message:@"NO OPERATOR FOUND CONNECTED FOR THIS REGION" delegate:nil cancelButtonTitle:@"CANCEL" otherButtonTitles: nil]show];
                  callback([NSError errorWithDomain:@"emergency" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No Operator Found"}]);
              }
              else if([response[@"code"]isEqualToString: rcNOT_AUTHENTICATE]){
                  [[[UIAlertView alloc]initWithTitle:@"" message:@"YOU ARE NOT IN AN AUTHENTICATED REGION" delegate:nil cancelButtonTitle:@"CANCEL" otherButtonTitles: nil]show];
                  callback([NSError errorWithDomain:@"emergency" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No Operator Found"}]);
                  
              }
                            else if([response[@"code"]isEqualToString: rcNO_REGION]){
                                 [[[UIAlertView alloc]initWithTitle:@"NO REGION" message:@"NO OPERATOR FOUND FOR YOUR LOCATION" delegate:nil cancelButtonTitle:@"CANCEL" otherButtonTitles: nil]show];
                                callback([NSError errorWithDomain:@"emergency" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No Operator Found"}]);
                           }
              else if([response[@"code"]isEqualToString: rcCONTACTED]){
                  callback(nil); 
              }else{
                  NSError * err = [NSError errorWithDomain:@"emergency" code:2 userInfo:@{NSLocalizedDescriptionKey:@"Waiting .... "}];
                  
                  callback(err);
              }
          }
     ];
    
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"portChecking"]) {
        
        [self portChecking:@"true"];
        
    }
    else
    {
     [self portChecking:@"false"];
    }  
    
}


-(void) newPassword:(NSString *) password forRegionID:(NSNumber *) regionID{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray * regionPasswords = [[prefs arrayForKey:kClientRegionPasswords] mutableCopy];
    if(!regionPasswords)
    regionPasswords = [NSMutableArray array];
    BOOL updated = NO;
    for(int i=0; i< [regionPasswords count]; i++){
        NSMutableDictionary * regionPassword = [regionPasswords[i] mutableCopy];
        if([regionPassword[@"regionID"] isEqualToNumber:regionID]){
            regionPassword[@"password"] = password;
            [regionPasswords replaceObjectAtIndex:i withObject:regionPassword];
            updated = YES;
            break;
        }
    }
    if(!updated){
        [regionPasswords addObject:@{@"regionID":regionID, @"password":password}];
    }
    [prefs setObject:regionPasswords forKey:kClientRegionPasswords];
    [self sendDeviceTokenAndLocation];
    
}
-(void) sendDeviceTokenAndLocation{
    [self sendDeviceTokenAndLocation:_locationManager.location andAskPassword:true];
}
-(void) sendDeviceTokenAndLocation :(CLLocation *)_location andAskPassword:(BOOL)askPass{
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * deviceToken = [prefs stringForKey:kDeviceToken];
    NSArray * regionPasswords = [prefs arrayForKey:kClientRegionPasswords];
    NSMutableDictionary * dataToSend = [NSMutableDictionary dictionary];
    
    if([regionPasswords count]){
        dataToSend[@"regionPasswords"] = regionPasswords;
    }
    
    if([deviceToken length]){
        dataToSend[kDeviceToken] = deviceToken;
    }
    if(_location){
        NSNumber *latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
        
        dataToSend[@"location"] =@{@"type":@"Point",@"coordinates":@[longitude, latitude]};
    }
    
    
    if([dataToSend count]){
        stateCallbackMethod sendBlock = ^(NSError * error){
            if(!error){
                [_socketIO sendEvent:@"userUpdate" withData:dataToSend andAcknowledge:^(id argsData) {
                    NSLog(@"Ack Event: userUpdate");
                    NSLog(@"params:%@",argsData);
                    
                    
                    NSDictionary *response = argsData;
                    NSString * resultCode = response[@"resultCode"];
                    
                    if([resultCode isEqualToString:rcPASSWORD_REQUIRED]){
                        
                      //  NSNumber * regionID = response[@"regionID"];
                        //NSString * regionDescription = response[@"regionDescription"];
//                        if(askPass)
//                            [self.contactOperatorVC askForClientPasswordForRegionWithID:regionID andDescription:regionDescription];
                    }
                    
                    if(!_shouldBeConnected){
                        [self disconnectFromServer];
                    }
                }];
            }
        };
        
        if([_socketIO isConnected]){
            sendBlock(nil);
        }else{
            [self connectToServer];
            [self.connectionCallbacks addObject:[sendBlock copy]];
        }
    }
}


#pragma mark SocketIO

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet{
    // handle common events
    [super socketIO:socket didReceiveEvent:packet];
    NSDictionary * data = [packet dataAsJSON];
    
    NSString * eventName = data[@"name"];
    
    NSDictionary * args =data[@"args"][0];
    if([eventName isEqualToString:@"emergencyResponse"]){
        if([self.contactOperatorVC callingOperator]){
            [socket sendAcknowledgement:packet.pId withArgs:@[@{@"code":rcACCEPTED}]];
            NSString * chatRoomID = args[@"chatRoomID"];
            [self.contactOperatorVC operatorResponded:chatRoomID];
            

        }else{
            [socket sendAcknowledgement:packet.pId withArgs:@[@{@"code":rcCANCELED_BY_USER}]];
        }
        
    }else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT &&[eventName isEqualToString:@"userID"]){
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:args[@"userID"] forKey:kClientID];
        [prefs synchronize];
        

    }else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_GUARDIAN &&[eventName isEqualToString:@"userID"]){
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:args[@"userID"] forKey:kGuardianID];
        [prefs synchronize];
    }
    else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR &&[eventName isEqualToString:@"userID"]){
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:args[@"userID"] forKey:kOperatorID];
        [prefs synchronize];
        

    }
}

//OPERATOR LOGIN CONNECTON WITH SERVER
-(void) connectToServerForMapRegionID:(NSNumber *) regionID withPassword:(NSString *) password callback:(stateCallbackMethod) callback{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * userName = [prefs stringForKey:kClientName];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userName"]=userName;
    dic[@"userRole"]=@"operator";
    if(regionID)
    dic[@"regionID"]=regionID;
    if(password)
    dic[@"password"]=password;
    dic[kDeviceToken]=@"";
    dic[@"provider"]=@"apn";
    dic[@"version"]=kAppVersion;
    
    if([prefs stringForKey:kOperatorID]){
        dic[@"userID"] = [prefs stringForKey:kOperatorID];
    }
    NSString * deviceToken = [prefs stringForKey:kDeviceToken];
    if([deviceToken length]){
        dic[kDeviceToken] = deviceToken;
    }
    
    if(_socketIO.isConnected && [SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
        
        [_socketIO sendEvent:@"login" withData:dic andAcknowledge:^(id argsData) {
            
            if(argsData== nil || [argsData isKindOfClass:[NSNull class]]){
                callback(nil);
            }else{
                 callback(argsData);
            }
        }];
        
    }else{
        
        __weak typeof(self) weakSelf = self;
        
        stateCallbackMethod connectionCB = ^(NSError * error){
            if(error){
                callback(error);
            }else{
                [_socketIO sendEvent:@"login" withData:dic andAcknowledge:^(id argsData) {
                    
                    if(argsData== nil || [argsData isKindOfClass:[NSNull class]]){
                        callback(nil);
                    }else{
                        callback(argsData);
                    }
                }];
                [weakSelf startPreciseLocationTracking];
            }
        };
        [self.connectionCallbacks addObject:[connectionCB copy]];
        [super connectToServerWithParams:dic];
    }
    
    //  [super connectToServerWithParams:@{@"userName":userName,@"userRole":@"operator", @"regionID":regionID, @"password":password}];
}


//CLIENT OR GUARDIAN LOGIN CONNECTON WITH SERVER
-(void) connectToServerForMapClientRegionID:(NSNumber *) regionID withPassword:(NSString *) password callback:(stateCallbackMethod) callback{
    _shouldBeConnected= true;
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * userName = [prefs stringForKey:kClientName];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    dic[@"userName"]=userName;
    if ([SPMainViewController getActiveInstance].tryToLogin == LOGGED_GUARDIAN){
      dic[@"userRole"]=@"guardian";
    }else
    dic[@"userRole"]=@"client";
    dic[@"time"]=TimeStamp;
    if(regionID)
        dic[@"regionID"]=regionID;
    if(password)
        dic[@"password"]=password;
    dic[kDeviceToken]=@"";
    dic[@"provider"]=@"apn";
    dic[@"version"]=kAppVersion;
    
    if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
    if([prefs stringForKey:kClientID]){
        dic[@"userID"] = [prefs stringForKey:kClientID];
    }
    }
    else{
        if ([prefs stringForKey:kGuardianID]) {
            dic[@"userID"] = [prefs stringForKey:kGuardianID];
        }
    }
    
    
    NSString * deviceToken = [prefs stringForKey:kDeviceToken];
    if([deviceToken length]){
        dic[kDeviceToken] = deviceToken;
    }
    
    if(_socketIO.isConnected ){
        
        [_socketIO sendEvent:@"login" withData:dic andAcknowledge:^(id argsData) {
            
            if(argsData== nil || [argsData isKindOfClass:[NSNull class]]){
                callback(nil);
            }else{
                callback(argsData);
            }
        }];
    
    }
    
else{
        
        __weak typeof(self) weakSelf = self;
        
        stateCallbackMethod connectionCB = ^(NSError * error){
            if(error){
                callback(error);
            }else{
                [_socketIO sendEvent:@"login" withData:dic andAcknowledge:^(id argsData) {
                    
                    if(argsData== nil || [argsData isKindOfClass:[NSNull class]]){
                        callback(nil);
                    }else{
                        callback(argsData);
                    }
                }];

               // callback(nil);
                [weakSelf startPreciseLocationTracking];
            }
        };
        [self.connectionCallbacks addObject:[connectionCB copy]];
        [super connectToServerWithParams:dic];
    }
    
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    for(stateCallbackMethod cb in self.locationCallbacks){
        cb(nil);
    }
    [self.locationCallbacks removeAllObjects];
    
    [self sendDeviceTokenAndLocation];
    
}
//******************************
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    for(stateCallbackMethod cb in self.locationCallbacks){
        cb(error);//********************************
    }
    [self.locationCallbacks removeAllObjects];
}
-(void) sendPushNotification:(NSMutableDictionary *) data andoncompltion:(void (^)(id args))completionBlock{
    // [_socketIO sendEvent:@"pushNotification" withData:@{@"text":text}];
    data[@"userID"]=self.userID;
    [_socketIO sendEvent:@"pushNotification" withData:data andAcknowledge:^(id argsData) {
        if(completionBlock){
            completionBlock(argsData);
        }
    }];
}
-(void)fetchPushHistory:(NSString *)number andoncompltion:(void (^)(id args))completionBlock{
    
    
    if ([_socketIO isConnected]) {
        
        [_socketIO sendEvent:@"pushNotificationHistory"
                    withData:@{
                               @"start":number}
              andAcknowledge:^(id argsData) {
                  
                  NSLog(@"%@",argsData);
                  if(completionBlock){
                      completionBlock(argsData);
                  }
              }];

    }else
    {
        [super reconnectServer];
        
        NSLog(@"DISCONNECTED");
    
    }
    
    
}
-(void)cancellActiveCall{
    
    //CANCELLING A ACTIVE CALL
    [_socketIO sendEvent:@"emergencyRequestCancel"
                withData:userDetails
          andAcknowledge:^(id argsData) {
              NSLog(@"%@",argsData);
          }];
}
-(void)logoutOperator:(NSString *)region callback:(stateCallbackMethod) callback{
    //LOGOT REGION
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    dic[@"regionID"]=region;

    if(_socketIO.isConnected && [SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
        
        [_socketIO sendEvent:@"logout" withData:dic andAcknowledge:^(id argsData) {
            
            if(argsData== nil || [argsData isKindOfClass:[NSNull class]]){
                callback(nil);
            }else{
                callback(argsData);
            }
        }];
        
    }
}

-(void)logoutClient:(NSString *)region callback:(stateCallbackMethod)callback{
    //LOGOT REGION
    if(!region)return;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"regionID"]=region;
    
    
        stateCallbackMethod sendBlock = ^(NSError * error){
            if(!error){
                
                [_socketIO sendEvent:@"logout" withData:dic andAcknowledge:^(id argsData) {
                    callback (argsData);
                }];
            }
        };
        
        if([_socketIO isConnected]){
            sendBlock(nil);
        }else{
            [self connectToServer];
            [self.connectionCallbacks addObject:[sendBlock copy]];
        }
    }

//SENDEVENT FOR SILENTBUTTON MODE
-(void)silent :(NSString *)mode{

    [_socketIO sendEvent:@"silent" withData:@{
                                              @"silentMode":mode}];
}

//SENDEVENT FOR PORT BLOCK STATUS CHECKING
-(void)portChecking : (NSString *) statusMode{
    
    if (_socketIO. isConnected) {
        
        [_socketIO sendEvent:@"portBlock" withData:@{@"status":statusMode}];
    }
 
    
}

@end
