//
//  DialWaitViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 08/01/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialWaitViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *dialLabel;
- (IBAction)cancelNow:(id)sender;
@end

