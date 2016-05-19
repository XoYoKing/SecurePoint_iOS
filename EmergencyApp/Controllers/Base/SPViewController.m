//
//  SPViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 03/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPViewController.h"
#import "SPMainViewController.h"
#import "QAConstants.h"
#import "ChatgroupsController.h"
@interface SPViewController ()

@end

@implementation SPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ChatgroupsController sharedInstance].currentView= self;
    self.title =cAPPNAME;
    [self setNeedsStatusBarAppearanceUpdate];
  //  self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void) emergencyResolved{
    [self.navigationController popViewControllerAnimated:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
