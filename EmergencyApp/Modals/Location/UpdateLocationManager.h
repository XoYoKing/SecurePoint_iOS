//
//  UpdateLocationManager.h
//  EmergencyApp
//
//  Created by Mzalih on 12/01/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface UpdateLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic)  CLLocationManager * _locationManager;
@property (nonatomic)  AppDelegate * appDelegate;

+ (instancetype) sharedInstance:(AppDelegate  *)appDelegate;
- (void) startBackGroundUpdate;
-(void)enterBackGround;
-(void)enterForground;
@end
