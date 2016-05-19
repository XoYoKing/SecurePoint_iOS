//
//  CallingOperatorViewController.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 09/07/14.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "CallingOperatorViewController.h"
#import "ClientEmergencyController.h"

@interface CallingOperatorViewController ()

@end

@implementation CallingOperatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)call911:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://911"]];

}

-(IBAction)cancel:(id)sender{
    [self.contactOperatorVC callingOperatorCancelled];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.activityView startAnimating];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.activityView stopAnimating];
    if(self.contactOperatorVC.callingOperator){
         [[ClientEmergencyController sharedInstance]cancellActiveCall];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
