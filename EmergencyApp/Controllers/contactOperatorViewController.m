              //
//  contactOperatorViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "contactOperatorViewController.h"
#import "QAConstants.h"
#import "SPMainViewController.h"
#import "ClientEmergencyController.h"
#import "CallingOperatorViewController.h"
#import "ChatTypeViewController.h"
#import "ChatgroupsController.h"
#import "SVProgressHUD.h"
#import <AFNetworking.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface contactOperatorViewController ()

@end

@implementation contactOperatorViewController

NSTimer *myTimer;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self openchatInitialy];
    [self setArts];
    [self updateProfileName];
    
    if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_GUARDIAN) {
        self.contactButton.hidden = YES;
    }

    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactOperator:) name:@"requireEmergency" object:nil];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
     [[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [QAConstants QARedColor];
    [self.navigationController.navigationBar setTranslucent:false];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openClientProfile :(id)app{
    [self performSegueWithIdentifier:opPROFILE sender:self];
}

-(void)updateProfileName{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * clientName = [prefs stringForKey:kClientName];
    NSString * clientPhone = [prefs stringForKey:kClientPhone];
    if (![clientName length] || ![clientPhone length]) {
        [self openClientProfile:self];
    }
}

-(void)openchatInitialy{
    ChatgroupsController *chatgroup =[ChatgroupsController sharedInstance];
    if(chatgroup.openedChatRoomID!=nil && ![chatgroup.openedChatRoomID isEqualToString:@""]){
    UIViewController *targetViewController = [self.storyboard instantiateViewControllerWithIdentifier:opCHATPAGE];
    if (self.navigationController) {
        [self.navigationController pushViewController:targetViewController animated:NO];
    }
    }
}

-(void )setArts{
    self.title =cAPPNAME;
    [[SPMainViewController getActiveInstance]setNavigationColor:self];
    //CONTACT BUTTON CUST ART
    self.contactButton.layer.cornerRadius=5;
    self.contactButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contactButton.titleLabel.textAlignment =NSTextAlignmentCenter;
    [self.contactButton setTitle:[cCONTACT uppercaseString] forState:UIControlStateNormal];
    //[self.contactButton setBackgroundColor:[QAConstants QARedColor]];
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

-(IBAction)contactOperator:(id)sender{
   //AFNETWORKING FOR CHECKING THE NETWORK AVAILABILITY STATUS
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
     [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
         //NO NEWTWROK AVAILABLE SHOW UIALERTVIEW.
         if(status ==0 ){
            [[[UIAlertView alloc]initWithTitle:@"Network Error! " message:@"Please check the Network" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show];
         }
    }];
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_NONE){
        NSLog(@"%d",[SPMainViewController getActiveInstance].loginStatus);
        [[[UIAlertView alloc]initWithTitle:@"Please Select a Region" message:@"Please Login" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show];
        return;
    }
    ClientEmergencyController * clientEC = [ClientEmergencyController sharedInstance];
    [clientEC disconnectFromServer];
    clientEC.contactOperatorVC =self;
    [SVProgressHUD showWithStatus:@"Contacting operator .."];
    NSLog(@"startEmergency");
    
    [clientEC startEmergency:^(NSError * error){
        
        NSLog(@"READY TO DAIL");
        [SVProgressHUD dismiss];
        if(error){
            NSLog(@"startEmergency error:%@",[error localizedDescription]);
            // [[[UIAlertView alloc]initWithTitle:@"Location Error! " message:@"Please allow application to access your location" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show];
            if(error.code != 1){
                self.callingOperator =true;
                [self openDialWait];
            }
        };
        
        if(!error){
            
            @try{
                // START DIALING
                [self performSegueWithIdentifier:opDialer sender:self];
                self.callingOperator = YES;
                
                //WAIT FOR A RESPONSE FOR 20 SECS
                myTimer = [NSTimer scheduledTimerWithTimeInterval: 20 target: self
                                                                   selector: @selector(openDialWait) userInfo: nil repeats: NO];
                
            }
            @catch (NSException *exception) {
                
            }
        }
    }];
}

-(void)openDialWait{
    //myTimer = [NSTimer scheduledTimerWithTimeInterval: number target: self
     //                                        selector: @selector(openDialWait) userInfo: nil repeats: NO];
    if(self.callingOperator){
        // NO RESPONSE SO OPEN THE CANSELLER
     [self.navigationController popToRootViewControllerAnimated:NO];
     [self performSegueWithIdentifier:opDialWait sender:self];
    [[ClientEmergencyController sharedInstance]cancellActiveCall];
    }
}

-(void) askForClientPasswordForRegionWithID:(NSNumber *) regionID andDescription:(NSString *) description{
    if(self.passwordView)
        return;
    
    self.lastRegionID = regionID;
    NSString * message = [NSString stringWithFormat:@"Enter password for region:%@", description];
    
    UIAlertView * passwordView = [[UIAlertView alloc] initWithTitle:@"Password" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    
    self.passwordView = passwordView;
    passwordView.alertViewStyle =  UIAlertViewStylePlainTextInput;
    [passwordView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView == self.passwordView){
        if(buttonIndex == 0){
            UITextField * textField = [alertView textFieldAtIndex:0];
            [[ClientEmergencyController sharedInstance] newPassword:textField.text forRegionID:self.lastRegionID];
        }
        self.passwordView = nil;
    }
    
    if(alertView == self.resolvedView){
        self.resolvedView = nil;
    }
}

-(void)callingOperatorCancelled{
    // CANCEL THE CALL
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[ClientEmergencyController sharedInstance]cancellActiveCall];
    self.callingOperator = NO;
    // INVATIDATE TIMER
    if(myTimer){
        [myTimer invalidate];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier]isEqualToString:opDialer]){
        CallingOperatorViewController *destView = [segue destinationViewController];
        destView.contactOperatorVC =self;
    }
    else if([[segue identifier]isEqualToString:opCHATMODE]){
        //ChatTypeViewController *destView = [segue destinationViewController];
        
    }
}

-(void) operatorResponded:(NSString *) chatRoomID{
    
        NSLog(@"START CHAT");
    
    // INVATIDATE TIMER
    if(myTimer){
        [myTimer invalidate];
    }
    ChatgroupsController *chtgroups =[ChatgroupsController sharedInstance];
    chtgroups.openedChatRoomID =chatRoomID;
    [[SPMainViewController getActiveInstance]openHomePage];
    
    self.callingOperator =NO;
}

-(void)dealloc{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
