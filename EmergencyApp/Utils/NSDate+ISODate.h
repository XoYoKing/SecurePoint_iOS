//
//  NSDate+ISODate.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISODate)
+(NSDate *) QAdateFromISODate:(NSString *) dateString;
+(NSString *) QAcurrentISODate;

@end
