//
//  MapAnnotation.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 27/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : MKPointAnnotation <MKAnnotation> {
    CLLocationCoordinate2D *coordinate;
}

@property (nonatomic) NSString * chatRoomID;
@property (nonatomic) NSString * mode; // chat/audio/video
@property (nonatomic) NSString * involved; // opened/me/other

// Other methods and properties.

@end
