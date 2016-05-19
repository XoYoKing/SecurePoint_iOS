//
//  ConnectionRegionListController.m
//  EmergencyApp
//
//  Created by Jithu on 3/16/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "ConnectionRegionListController.h"
#import <AFNetworking.h>
#import "AFHTTPSessionManager.h"
#import "SVProgressHUD.h"


@implementation ConnectionRegionListController

//API CALL METHOD FOR GETTING REGIONS LIST
- (void)GetGlobalWebserviceConnectivityWithResponseValue:(NSMutableDictionary *)parameters baseUrl:(NSString*) baseUrl   Completion:(void (^)(  NSMutableDictionary *))handler {
    
  
    //___________TRY CODE
    _completionHandlerCommon = [handler copy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        _completionHandlerCommon(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // ALERTVIEW if API call fails to load RegionLists.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error!" message:@"Check your Network connectivity." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        // NSLog(@"Error: %@", error);
        NSMutableDictionary * dict;
        _completionHandlerCommon (dict);
    }];
}


//API CALL POST METHOD

- (void)PostGlobalWebserviceConnectivityWithResponseValue:(NSMutableDictionary *)parameters baseUrl:(NSString*) baseUrl   Completion:(void (^)(  NSMutableDictionary *))handler{
    
    _completionHandlerCommon = [handler copy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
         _completionHandlerCommon(responseObject);
       
        // ALERTVIEW for Message Sending Success
        if ([[responseObject valueForKey:@"status"] intValue] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Success" message:@"Message Sending Success." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];

        }
        else{
            // ALERTVIEW for Message Sending Fail
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Failed!" message:@"Message should not be empty." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // ALERTVIEW if API call fails to load RegionLists.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error!" message:@"Check your Network connectivity." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [SVProgressHUD dismiss];

        
       // NSLog(@"Error: %@", error);
        
        NSMutableDictionary * dict;
        _completionHandlerCommon (dict);
        
    }];

    
}


@end



