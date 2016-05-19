//
//  DialWaitViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 08/01/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "DialWaitViewController.h"
#import "SPMainViewController.h"
@interface DialWaitViewController ()

@end
@implementation DialWaitViewController
int maxTime =9;
int counter =0;
bool needDial =true;
NSTimer *myTimer;
- (void)viewDidLoad {
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [super viewDidLoad];
    counter =0;
    needDial = true;
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                             selector: @selector(dial911) userInfo: nil repeats: YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];                                                                                                                     
    // Dispose of any resources that can be recreated.
}

-(void)dial911{
    if(counter == maxTime){
        [myTimer invalidate];
        [self cancelNow:self];
        // IF NOT CANCELED
        if(needDial){
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://911"]];
        }
        
    }else{
        // CONTINUE TIMER
        counter ++;
        _dialLabel.text =[NSString stringWithFormat:@"Dialing 911 in %i Seconds",maxTime- counter];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelNow:(id)sender {
    needDial = false;
     [myTimer invalidate];
    [self.navigationController popToRootViewControllerAnimated:NO];
    SPMainViewController *mainView =[SPMainViewController getActiveInstance];
    if(mainView){
        // GET SEGUE FOR HOME PAGE
        NSString *segueIdentifierForIndexPathInLeftMenu =
        [mainView segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForRow:0 inSection:1]];
        // MOVE TO THE HOME PAGE
        [mainView.leftMenu performSegueWithIdentifier:segueIdentifierForIndexPathInLeftMenu sender:mainView.leftMenu];
    }
}

@end
