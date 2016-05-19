//
//  UpdateLocationManager.m
//  EmergencyApp
//
//  Created by Mzalih on 12/01/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "UpdateLocationManager.h"
#import "ClientEmergencyController.h"

@implementation UpdateLocationManager

- (instancetype) init{
    self = [super init];
    __locationManager = [[CLLocationManager alloc] init];
    NSLog(@"__________ LOCATION INSTANCE CREATED ___________");
    return self;
}

+ (instancetype) sharedInstance:(AppDelegate  *)appDelegate{
    static UpdateLocationManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    sharedInstance.appDelegate =appDelegate;
    return sharedInstance;
}
- (void) startBackGroundUpdate{
    [self startPreciseLocationTracking];
}
- (void) startPreciseLocationTracking{
if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    [__locationManager requestAlwaysAuthorization];
    __locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    __locationManager.distanceFilter = 1000.0f;
    __locationManager.delegate = self;
    __locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    [__locationManager startUpdatingLocation];
    [self._locationManager startMonitoringSignificantLocationChanges];
}
-(void)enterBackGround{
    
    NSLog(@"Went to Background");
    
    // Need to stop regular updates first
    [self._locationManager stopUpdatingLocation];
    // Only monitor significant changes
    [self._locationManager startMonitoringSignificantLocationChanges];
}
-(void)enterForground{
    [self._locationManager stopMonitoringSignificantLocationChanges];
    [self._locationManager startUpdatingLocation];
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
   NSLog(@"Location manager didUpdateLocation");
   NSLog(@"locations:%@",locations);

        [self sendBackgroundLocationToServer:[locations lastObject]];
}

-(void) sendBackgroundLocationToServer:(CLLocation *)location
{
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier locationUpdateTaskID = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:locationUpdateTaskID];
                locationUpdateTaskID = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // You might consider what to do here if you do not ever get a location accurate enough to pass the test.
        // Also consider comparing to previous report and verifying that it is indeed beyond your threshold distance and/or recency. You cannot count on the LM not to repeat.
        if ([location horizontalAccuracy] < 100.0f) {
            [self sendDataToServer:location];
        }
        
        // Close out task Identifier on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:locationUpdateTaskID];
                locationUpdateTaskID = UIBackgroundTaskInvalid;
            }
        });
    });
    
}
-(void)sendDataToServer:(CLLocation *)location{
    //HERE GO AHEAD WITH THE LOCATION UPDATE
    [[ClientEmergencyController sharedInstance]sendDeviceTokenAndLocation:location andAskPassword:NO];
}

@end
