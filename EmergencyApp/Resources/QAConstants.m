//
//  UserDefaults.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 17/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "QAConstants.h"
// nsuserdefaults

NSString * const  kDeviceToken = @"deviceToken";
NSString * const  kClientName = @"ClientName";
NSString * const  kClientPhone = @"ClientPhone";
NSString * const  kClientID     = @"ClientID";
NSString * const  kOperatorID = @"OperatorID";
NSString * const  kGuardianID     = @"GuardianID";
NSString * const  kClientRegionPasswords = @"ClientRegionPasswords";

NSString * const  kLOGINMODE= @"LOGINMODE";
NSString * const  kRegionID = @"REGIONID";
NSString * const  kRegionPassword = @"REGIONPASSWORD";
NSString * const  kAppVersion= @"v2";


// resultCode
// event userUpdate
NSString * const  rcOK = @"OK";
NSString * const  rcPASSWORD_REQUIRED = @"PASSWORD_REQUIRED";
NSString * const  rcNOT_MONITORED_LOCATION = @"NOT_MONITORED_LOCATION";


// event emergencyResponse
NSString * const  rcACCEPTED= @"ACCEPTED";
NSString * const  rcCANCELED_BY_USER= @"CANCELED_BY_USER";
NSString * const  rcNO_OPERATOR= @"NO_OPERATOR";
NSString * const  rcNO_REGION= @"NO_REGION";
NSString * const  rcNOT_AUTHENTICATE= @"NOT_AUTHENTICATE";
NSString * const   rcCONTACTED =@"OPERATORS_CONTACTED";

//SegueS Using
NSString * const  opPROFILE   = @"profileSegue";
NSString * const  opDialer    = @"showDialer";
NSString * const  opDialWait    = @"showDialwait";
NSString * const  opChatRooms = @"showChatRoom";
NSString * const  opCHATMODE  = @"showChatMode";
NSString * const  opCHATPAGE  = @"showChatPage";
NSString * const  opPUSHPAGE = @"pushView";
NSString * const  opREGIONLIST = @"regionList";
NSString * const  clREGIONLIST = @"clientRegionList";

NSString * const  opCHATLIST  = @"chatList";
NSString * const  opVIDLIST  = @"videoList";
NSString * const  opAUDLIST  = @"audioList";

//Warnings
NSString * const  cAPPNAME= @"SecurePoint";
NSString * const  cCONTACT= @"Contact an Operator";
NSString * const  cLOGIN  = @"Login as operarator";
NSString * const  cLOGOUT=  @"Logout operator mode";

@implementation QAConstants

+(UIColor *) QAYellowColor{ // 245 192 46
    return [UIColor colorWithRed:0.960 green:0.753 blue:0.180 alpha:1];
}
+(UIColor *) QAOrangeColor{ // 234 122 33
    return [UIColor colorWithRed:0.918 green:0.478 blue:0.129 alpha:1];
}
+(UIColor *) QARedColor{ // 226 24 47
    return [UIColor colorWithRed:0.883 green:0.0937 blue:0.184 alpha:1];
}

+(UIColor *) QABlueColor{ // 141 187 224
    return [UIColor colorWithRed:0.553 green:0.733 blue:0.878 alpha:1];
}

+(UIColor *) QAGreenColor{ //128 203 74
    return [UIColor colorWithRed:0.502 green:0.796 blue:0.290 alpha:1];
}

+(UIColor *) QATextBlueColor{ //66 165 233
    return [UIColor colorWithRed:0.256 green:0.647 blue:0.914 alpha:1];
}
+(UIColor *) QATextGrayColor{ //134 134 134
    return [UIColor colorWithRed:0.525 green:0.525 blue:0.525 alpha:1];
}

+(NSString *)getCurrentTime:(NSDate*)dateObj inFormat :(NSString *)format{
    
    NSDateFormatter *formatter;
    
    NSString        *formatteddateString=@"";
    if(format == nil){
      format =@"MM-dd-yyyy HH:mm";
    }
    
    if(dateObj ==nil){
        dateObj =[NSDate date];
    }
    formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:format];
    formatteddateString = [formatter stringFromDate:dateObj];
    
    if(formatteddateString){
        return formatteddateString;
    }else{
        return @"";
    }
    
}

@end
