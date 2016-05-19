//
//  UserDefaults.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 17/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

static int  LOGGED_NONE = 0;
static int  LOGGED_OPERATOR = 1;
static int  LOGGED_CLIENT = 2;
static int  LOGGED_GUARDIAN = 3;

// nsuserdefaults
extern NSString * const kDeviceToken;
extern NSString * const kClientName;
extern NSString * const kClientPhone;
extern NSString * const kClientID;
extern NSString * const kOperatorID;
extern NSString * const kGuardianID;
extern NSString * const kClientRegionPasswords;
//extern NSString * const  kIsOpertor;
//extern NSString * const  kIsClient;
//extern NSString * const  kIsGuardian;
//extern NSString * const  kIsLOGEDIN;

extern NSString * const  kLOGINMODE;
extern NSString * const  kRegionID ;
extern NSString * const  kRegionPassword;
extern NSString * const  kAppVersion;


// resultCode
// event userUpdate
extern NSString * const rcOK;
extern NSString * const rcPASSWORD_REQUIRED;
extern NSString * const rcNOT_MONITORED_LOCATION;

// event emergencyResponse
extern NSString * const rcACCEPTED;
extern NSString * const rcCANCELED_BY_USER;
extern NSString * const  rcNO_OPERATOR;
extern NSString * const  rcNO_REGION;
extern NSString * const  rcNOT_AUTHENTICATE;
extern NSString * const  rcCONTACTED;


extern NSString * const opPROFILE;
extern NSString * const  opDialWait;
extern NSString * const opDialer;
extern NSString  * const  opCHATPAGE;
extern  NSString * const opCHATMODE;
extern NSString * const  opPUSHPAGE;
extern NSString * const opREGIONLIST;
extern NSString * const clREGIONLIST;

extern NSString * const  cAPPNAME;
extern NSString * const  cCONTACT;
extern NSString * const  cLOGIN;
extern NSString * const  cLOGOUT;

extern NSString * const  opCHATLIST ;
extern NSString * const  opVIDLIST  ;
extern NSString * const  opAUDLIST  ;




@interface QAConstants : NSObject

+(UIColor *) QAYellowColor;
+(UIColor *) QAOrangeColor;
+(UIColor *) QARedColor;
+(UIColor *) QABlueColor;
+(UIColor *) QAGreenColor;
+(UIColor *) QATextBlueColor;
+(UIColor *) QATextGrayColor;
+(NSString *)getCurrentTime:(NSDate*)dateString inFormat :(NSString *)format;
@end
