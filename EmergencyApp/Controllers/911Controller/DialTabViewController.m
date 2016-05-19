//
//  DialTabViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 09/01/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "DialTabViewController.h"
#import "QAConstants.h"

@interface DialTabViewController ()

@end

@implementation DialTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
     //  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://911"]];
    // Do any additional setup after loading the view.
    
}
-(void)viewDidAppear:(BOOL)animated{
     [self performSegueWithIdentifier:opDialWait sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
