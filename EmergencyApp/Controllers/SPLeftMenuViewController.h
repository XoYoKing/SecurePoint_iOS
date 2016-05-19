//
//  SPLeftMenuViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "AMSlideMenuLeftTableViewController.h"

@interface SPLeftMenuViewController : AMSlideMenuLeftTableViewController <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet UIView *silentModeView;
@property (strong, nonatomic) IBOutlet UIImageView *silentImage;
@property(nonatomic) UIAlertView * operatorPasswordView;
@property(nonatomic) UIAlertView * regionCheckoutView;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *loginLogoutButton;
@property (strong, nonatomic) IBOutlet UISwitch *silentModeButton;

-(IBAction)loginLogout:(id)sender;
-(IBAction) logOutOperator;
-(void) updateLoginStatus:(int)loginStatus;
-(void)openHomePage;

-(IBAction)silentMode:(id)sender;


@end

