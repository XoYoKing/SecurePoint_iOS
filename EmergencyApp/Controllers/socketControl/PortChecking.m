//
//  PortChecking.m
//  EmergencyApp
//
//  Created by Jithu on 7/6/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "PortChecking.h"
#import "Constants.h"
#import "SPTabBarController.h"
#import "SocketIO.h"
#import "ClientEmergencyController.h"


@implementation PortChecking


+ (id)sharedInstance{
    // SHARING A SINGLE INSTANCE
    
    static PortChecking *_sharedInstance = nil;
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           
        _sharedInstance = [[PortChecking alloc] init];
        _sharedInstance.portCheckingCount = FALSE;
    });
    return _sharedInstance;
}


- (void) connectToServeForChecking: (int) portAddress  withCallBack:(void (^)(bool))handler
{
        _completionHandlerCommon = [handler copy];
        _socketIO_Check = [[SocketIO alloc] initWithDelegate:self];
       // _socketIO_Check.useSecure =true;
    
    
    
        [_socketIO_Check connectToHost:BaseURL onPort:portAddress withParams:nil];
    
    }
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    [_socketIO_Check disconnect];
    _completionHandlerCommon(true);
}


- (void) socketIODidConnect:(SocketIO *)socket{
    [_socketIO_Check disconnect];
    _completionHandlerCommon(FALSE);
    
}



@end

