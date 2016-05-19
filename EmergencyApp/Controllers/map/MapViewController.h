//
//  MapViewController.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 16/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatgroupsController.h"
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController <MKMapViewDelegate>

@property(nonatomic,weak) IBOutlet MKMapView * mapView;

@property(nonatomic) ChatRoomsViewController * chatRoomsVC;
@property (nonatomic, strong) UISegmentedControl * mapSegmentControll;
@property (nonatomic, strong) UISegmentedControl * ChatAudioVideoControll;


@end
