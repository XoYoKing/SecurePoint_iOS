//
//  UserEmergencyController.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 24/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "EmergencyController.h"
//#import "ChatViewController.h"
#import "contactOperatorViewController.h"
@interface ClientEmergencyController : EmergencyController

@property(nonatomic)  contactOperatorViewController * contactOperatorVC;

-(void) startEmergency:(stateCallbackMethod) callback;

-(void) sendDeviceTokenAndLocation;
-(void) sendDeviceTokenAndLocation :(CLLocation *)_location andAskPassword:(BOOL)askPass;

-(void) newPassword:(NSString *) password forRegionID:(NSNumber *) regionID;

-(void) connectToServerForMapRegionID:(NSNumber *) regionID withPassword:(NSString *) password callback:(stateCallbackMethod) callback;

-(void) connectToServerForMapClientRegionID:(NSNumber *) regionID withPassword:(NSString *) password callback:(stateCallbackMethod) callback;

-(void) sendPushNotification:(NSMutableDictionary *) data andoncompltion:(void (^)(id args))completionBlock;

-(void)fetchPushHistory:(NSString *)number andoncompltion:(void (^)(id args))completionBlock;

-(void)cancellActiveCall;

-(NSString *) getUserID;

-(void)logoutOperator:(NSString *)region callback:(stateCallbackMethod) callback;

-(void)logoutClient:(NSString *)region callback:(stateCallbackMethod) callback;

-(void)silent :(NSString *)mode;
-(void)portChecking : (NSString *) statusMode;
@end
