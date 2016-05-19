//
//  ConnectionRegionListController.h
//  EmergencyApp
//
//  Created by Jithu on 3/16/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionRegionListController : NSObject

{
    void (^_completionHandlerCommon)(NSMutableDictionary * clientRegionList);
}

- (void)GetGlobalWebserviceConnectivityWithResponseValue:(NSMutableDictionary *)parameters baseUrl:(NSString*) baseUrl   Completion:(void (^)(NSMutableDictionary *))handler ;

- (void)PostGlobalWebserviceConnectivityWithResponseValue:(NSMutableDictionary *)parameters baseUrl:(NSString*) baseUrl   Completion:(void (^)(  NSMutableDictionary *))handler;

@end
