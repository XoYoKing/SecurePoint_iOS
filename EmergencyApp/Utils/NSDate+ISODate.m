//
//  NSDate+ISODate.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//
#import "NSDate+ISODate.h"

@implementation NSDate (ISODate)

+(NSDate *) QAdateFromISODate:(NSString *) dateString{
    
    NSDate* nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    
    NSString* myString = [dateFormat stringFromDate:nowDate];
    NSLog(@"%@",myString);
    
    //dateFormat.dateFormat = @"MM-dd-YYYY'T'HH:mm:ss.SSS'Z'";

    NSTimeZone * timezone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormat.timeZone = timezone;

    // Always use this locale when parsing fixed format date strings
    NSLocale* posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormat.locale = posix;
    return [dateFormat dateFromString:dateString];
}

+(NSString *) QAcurrentISODate{
    
    NSDate * nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];

    NSTimeZone * timezone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormat.timeZone = timezone;
    
    //dateFormat.dateFormat = @"MM-dd-YYYY'T'HH:mm:ss.SSS'Z'";
    
    // Always use this locale when parsing fixed format date strings
    NSLocale* posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormat.locale = posix;

    return [dateFormat stringFromDate:nowDate];
}
@end