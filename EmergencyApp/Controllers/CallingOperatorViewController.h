//
//  CallingOperatorViewController.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 09/07/14.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "contactOperatorViewController.h"
#import "SPViewController.h"
@interface CallingOperatorViewController : SPViewController
@property(nonatomic,weak) IBOutlet UIActivityIndicatorView * activityView;
@property(nonatomic) contactOperatorViewController * contactOperatorVC;
@end
