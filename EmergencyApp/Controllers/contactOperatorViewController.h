//
//  contactOperatorViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPViewController.h"

@interface contactOperatorViewController : SPViewController
@property (strong, nonatomic) IBOutlet UIButton *contactButton;

@property(nonatomic) BOOL callingOperator;
@property(nonatomic) NSNumber * lastRegionID;
@property(nonatomic) UIAlertView * passwordView;
@property(nonatomic) UIAlertView * resolvedView;

-(void) askForClientPasswordForRegionWithID:(NSNumber *) regionID andDescription:(NSString *) description;
-(IBAction)contactOperator:(id)sender;
-(void)callingOperatorCancelled;
-(void) operatorResponded:(NSString *) chatRoomID;
@end
