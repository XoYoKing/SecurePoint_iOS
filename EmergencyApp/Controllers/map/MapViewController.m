 //
//  MapViewController.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 16/05/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import "ClientEmergencyController.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "PortChecking.h"
#import "QAConstants.h"


@interface MapViewController ()

    @property(nonatomic) NSMutableArray * annotations;
    @property(nonatomic) NSArray * chatRooms;


@end

@implementation MapViewController
@synthesize mapSegmentControll;
@synthesize ChatAudioVideoControll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self updateMapView];
}


-(void) updateMapView{
    [self updateMapAnnotations];
    [self updateMapVisibleArea];
}


-(void) updateMapAnnotations{
    if(!self.annotations){
        self.annotations = [NSMutableArray array];
    }
    if([self.annotations count]){
        [self.mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
    }

    NSArray * chatRooms = [[ChatgroupsController sharedInstance] getChatRooms];
    self.chatRooms = chatRooms;

    for(NSDictionary * chatRoom in chatRooms){
        NSArray * users = chatRoom[@"users"];
        NSArray * clients = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(role == 'client')"]];
        NSArray * operators = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(role == 'operator')"]];

        if([clients count]>0){
        NSArray * clientLocation = clients[0][@"location"][@"coordinates"];
        MapAnnotation * annotation = [[MapAnnotation alloc] init];
        annotation.title = clients[0][@"userName"];
            if (chatRoom[@"mode"])
            annotation.mode = chatRoom[@"mode"];
            else
             annotation.mode = @"chat";
            
        
        annotation.chatRoomID = chatRoom[@"_id"];
        
        if([chatRoom[@"_id"] isEqualToString:[ChatgroupsController sharedInstance].openedChatRoomID]){
            annotation.involved = @"opened";
            annotation.subtitle = @"opened";
        }else{
            NSString * currentOperatorID = [[ClientEmergencyController sharedInstance] userID];
            BOOL involved = NO;
            NSMutableString * operatorsList = [NSMutableString string];
            for(NSDictionary * operator in operators){
                if([operatorsList length] != 0) [operatorsList appendString:@", "];
                
                if([operator[@"_id"] isEqualToString:currentOperatorID]){
                    involved = YES;
                    [operatorsList appendString:@"me"];
                }else{
                    [operatorsList appendString:operator[@"userName"]];
                }
            }
            annotation.subtitle = [@"operators:" stringByAppendingString: operatorsList];
            if(involved)
                annotation.involved = @"me";
            
            else
                annotation.involved = @"other";
        }
        
        
        CLLocationCoordinate2D coordinate;
        coordinate.longitude = [clientLocation[0] doubleValue];
        coordinate.latitude = [clientLocation[1] doubleValue];
            [annotation setCoordinate: coordinate];
        [self.annotations addObject:annotation];
        //[self.mapView addAnnotation:annotation];
    }
    [self.mapView addAnnotations:self.annotations];
        [self.mapView reloadInputViews];
   // [self.mapView selectAll:self];
}
}


-(void) updateMapVisibleArea{

    double cumulativeLatitude = 0;
    double cumulativeLogitude = 0;
    for(MKPointAnnotation * annotation in self.annotations){
        cumulativeLatitude += annotation.coordinate.latitude;
        cumulativeLogitude += annotation.coordinate.longitude;
    }
    
    double centerLatitude = cumulativeLatitude / [self.annotations count];
    double centerLongitude = cumulativeLogitude / [self.annotations count];
    
    double longestDistanceFromCenter = 0;
    
    CLLocation * clCenterLocation = [[CLLocation alloc] initWithLatitude:centerLatitude longitude:centerLongitude];
    
    for(MKPointAnnotation * annotation in self.annotations){
        CLLocation * clPointLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        
        CLLocationDistance distance = [clCenterLocation distanceFromLocation:clPointLocation];
        if(distance > longestDistanceFromCenter){
            longestDistanceFromCenter = distance;
        }

    }
    
    if(longestDistanceFromCenter<10){
        longestDistanceFromCenter = 100;
    }
    
    CLLocationCoordinate2D center;
    center.latitude = centerLatitude;
    center.longitude = centerLongitude;
    
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMakeWithDistance(center, longestDistanceFromCenter*1.5, longestDistanceFromCenter*1.5);
    
    @try {
        [self.mapView setRegion:visibleRegion];
    }
    @catch (NSException *exception) {
        
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //frame for the segemented button
    CGRect segmentframe = CGRectMake(50, screenSize.height-105, 220, 30);
    //Array of items to go inside the segment control
    NSArray *itemArray = [NSArray arrayWithObjects: @"Standard", @"Satellite", @"Hybrid", nil];
    //create an intialize our segmented control
    mapSegmentControll = [[UISegmentedControl alloc] initWithItems:itemArray];
    //set the size and placement
    mapSegmentControll.frame = segmentframe;
    mapSegmentControll.tintColor = [UIColor redColor];
    //attach target action for if the selection is changed by the user
    [mapSegmentControll addTarget:nil action:@selector(segmentMapToggle:) forControlEvents:UIControlEventValueChanged];
    [_mapView addSubview:mapSegmentControll];
    [self.mapSegmentControll setSelectedSegmentIndex:0];
    
}

/*
 * jithu
 * function for segmentMapToggle: action
 * Toggle three map views
 */
-(IBAction)segmentMapToggle:(UISegmentedControl *)sender
{
    UISegmentedControl *seg=(UISegmentedControl*)sender;
    if(seg.selectedSegmentIndex==0){
        _mapView.mapType=MKMapTypeStandard;
    }
    if(seg.selectedSegmentIndex==1){
        _mapView.mapType=MKMapTypeSatellite;
    }
    if(seg.selectedSegmentIndex==2){
        _mapView.mapType=MKMapTypeHybrid;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
       // MKAnnotationView*    userView = (MKAnnotationView*)[mapView
    //                                                             dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
//
    MKAnnotationView*    userView;
        if (!userView)
        {
            userView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                   reuseIdentifier:@"UserAnnotationView"];
            
            
            userView.centerOffset = CGPointMake(0, -20);
            userView.canShowCallout = YES;
            
            if (ChatAudioVideoControll) {
                ChatAudioVideoControll = nil;
            }
            //frame for the segemented button
            CGRect segmentframe = CGRectMake(0, 0, 130, 20);
            //Array of items to go inside the segment control
            NSArray *itemArray = [NSArray arrayWithObjects: @"Chat", @"Audio", @"Video", nil];
            //create an intialize our segmented control
            ChatAudioVideoControll = [[UISegmentedControl alloc] initWithItems:itemArray];
            //set the size and placement
            ChatAudioVideoControll.frame = segmentframe;
            ChatAudioVideoControll.tintColor = [UIColor blackColor];
            //attach target action for if the selection is changed by the user
            [ChatAudioVideoControll addTarget:nil action:@selector(ChatAudioVideoToggle:) forControlEvents:UIControlEventValueChanged];
            userView.rightCalloutAccessoryView = ChatAudioVideoControll;

            
//            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//            userView.rightCalloutAccessoryView = rightButton;
//             //If appropriate, customize the callout by adding accessory views (code not shown).
        }
    
        else
            userView.annotation = annotation;
      
    NSString * imageName = @"MapMarker";
    MapAnnotation * mapAnnotation  = (MapAnnotation *) annotation;
    
    if([mapAnnotation.involved isEqualToString:@"opened"]){
        imageName = [imageName stringByAppendingString:@"Open"];

        
    }else if([mapAnnotation.involved isEqualToString:@"me"]){
        imageName = [imageName stringByAppendingString:@"Same"];

        
    }else{
        imageName = [imageName stringByAppendingString:@"Other"];

    }
    
    if([mapAnnotation.mode isEqualToString:@"chat"]){
        imageName = [imageName stringByAppendingString:@"Chat"];
        
    }else if([mapAnnotation.mode isEqualToString:@"audio"]){
        imageName = [imageName stringByAppendingString:@"Audio"];
    }else{
        imageName = [imageName stringByAppendingString:@"Video"];
    }
    
    userView.image = [UIImage imageNamed:imageName];
    return userView;
    
}

//DELEGATE METHOD FOR SELECTING ANNOTATION VIEW
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    MapAnnotation * annotation1 = view.annotation;
    NSString * chatRoomID = annotation1.chatRoomID;
    [ChatgroupsController sharedInstance].openedChatRoomID =chatRoomID;
    
}


//METHOD FOR TOGGLEING THREE (CHAT, AUDIO, VIDEO)MODES
-(IBAction)ChatAudioVideoToggle:(UISegmentedControl *)sender{

    NSString * imageName = @"MapMarker";
    UISegmentedControl *seg=(UISegmentedControl*)sender;
    if(seg.selectedSegmentIndex==0){
        imageName = [imageName stringByAppendingString:@"Chat"];

        [self openchatInitialy:@"chat"];
 
    }
    if(seg.selectedSegmentIndex==1){
        imageName = [imageName stringByAppendingString:@"Audio"];

        [self openchatInitialy:@"audio"];

    }
    
    if(seg.selectedSegmentIndex==2){
        imageName = [imageName stringByAppendingString:@"Video"];


        [self openchatInitialy:@"video"];

    }

}

//REDIRECT TO UPDATEMODE WHILE SWITCHING CHAT AUDIO VIDEO MODE USING SEGMENT CONTROLL
-(void)openchatInitialy :(NSString *)mode{
    ChatgroupsController *chatgroup =[ChatgroupsController sharedInstance];
    if(chatgroup.openedChatRoomID!=nil && ![chatgroup.openedChatRoomID isEqualToString:@""]){
        UIViewController *targetViewController = [self.storyboard instantiateViewControllerWithIdentifier:opCHATPAGE];
        if (self.navigationController) {
            [self.navigationController pushViewController:targetViewController animated:NO];
            [[ChatgroupsController sharedInstance] updateMode:mode forChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID  ];
            [[ClientEmergencyController sharedInstance] updateMode:mode forChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
            
          }
    }
}




- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    NSLog(@"mapView calloutAccessoryControlTapped");
    MapAnnotation * annotation = (MapAnnotation *)view.annotation;
    NSString * chatRoomID = annotation.chatRoomID;
    [ChatgroupsController sharedInstance].openedChatRoomID =chatRoomID;
    [self.navigationController popToRootViewControllerAnimated:NO];
//    [[ChatgroupsController sharedInstance]  openChatForChatRoomID:chatRoomID];
}
         
         
         

@end
