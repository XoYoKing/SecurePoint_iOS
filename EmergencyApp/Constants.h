//
//  define.h
//  EmergencyApp
//
//  Created by Jithu on 3/17/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#ifndef EmergencyApp_define_h
#define EmergencyApp_define_h
#import "AppDelegate.h"

//PRODUCTION URL

//#define BaseURL @ "dev.campusofficer.com"
#define BaseURL @ "52.8.111.191"

//#define PORT 8000
#define PORT 80

#define PORT443 443
#define PORT3478 3478
//#define PORT34404 34404



//TESTING URL
//#define BaseURL @"54.179.154.20"
//#define PORT 4000

//URL's

#define CLientRegionListURL @"/mapBoundaries/clientregions/match?text"
#define PushNotificationURL @"/pushNotification/send"
#define GuardianRegionURL @"/mapBoundaries/guardianregions/match?text"
#endif

