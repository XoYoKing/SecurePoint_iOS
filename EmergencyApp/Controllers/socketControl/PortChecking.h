//
//  PortChecking.h
//  EmergencyApp
//
//  Created by Jithu on 7/6/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"


@interface PortChecking : NSObject<SocketIODelegate>{
    SocketIO * _socketIO_Check;
    
    void (^_completionHandlerCommon)(bool responseData);
}

@property(nonatomic)BOOL hasAblockedPort;
@property(nonatomic)int blockedPort;

@property(nonatomic)BOOL portCheckingCount;

//@property(nonatomic) NSString * serverAddress;

+ (instancetype) sharedInstance;

- (void) connectToServeForChecking: (int) portAddress withCallBack:(void (^)(bool))handler ;

@end
