//
//  EmergencyController.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SPLeftMenuViewController.h"

@class ChatRoomsViewController;

typedef void (^stateCallbackMethod)(NSError * error);


@interface EmergencyController : NSObject <SocketIODelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    
@protected
    SocketIO * _socketIO;
    CLLocationManager * _locationManager;
    BOOL _shouldBeConnected;

}

@property (nonatomic) NSString * role;

@property (nonatomic) NSMutableArray * connectionCallbacks; 

@property(nonatomic) ChatRoomsViewController * chatRoomsVC;

// might move/delete
@property(nonatomic) NSString * userID;
@property(nonatomic) NSDictionary * userProfile;
@property(nonatomic) NSString * serverAddress;
@property(nonatomic) Boolean  requireEmergency;

// singleton
+ (instancetype) sharedInstance;

-(void) OTTokenForChatRoomID:(NSString *) chatRoomID callback:(void(^)(NSString * sessionID, NSString * token))callback;

-(void) sendMessages:(NSArray *) messages toChatRoomID:(NSString *) chatRoomID;
-(void) updateMode:(NSString *) mode forChatRoomID:(NSString *)chatRoomID;
-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID withAck:(SocketIOCallback) function;
-(void) joinChatRoomForChatRoomID:(NSString *)chatRoomID;


- (void) connectToServerWithParams:(NSDictionary*) dict;
- (void) disconnectFromServer;
- (void) logoutOperator;

- (void) startPreciseLocationTracking;
- (void) stopLocationTracking;
-(NSArray *) getCurrentLocation; // [longitude, latitude]
-(void)updateRegions:(SPLeftMenuViewController *)tableview;


@end
