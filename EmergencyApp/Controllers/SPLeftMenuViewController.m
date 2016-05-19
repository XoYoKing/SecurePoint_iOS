//
//  SPLeftMenuViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPLeftMenuViewController.h"
#import "SPMainViewController.h"
#import "QAConstants.h"
#import "ClientEmergencyController.h"
#import "ChatgroupsController.h"
#import "SVProgressHUD.h"
#import "MenuCell.h"
#import "RegionListViewController.h"
#import "SocketIO.h"


@interface SPLeftMenuViewController (){
}

@end

@implementation SPLeftMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults * prefs =[NSUserDefaults standardUserDefaults];
    if([prefs boolForKey:@"silentValue"]){
        [_silentModeButton setOn:TRUE];
        _silentImage.image = [UIImage imageNamed:@"soundOff"];


           } else{
       [_silentModeButton setOn:FALSE];
    _silentImage.image = [UIImage imageNamed:@"soundOn"];

    }
    
    [self updateProfileName];
     [self autoLogin];
}
-(void)autoLogin{
    // LOADING SAVED STATE OF THE OPERATOR OR CLIENT
     NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [SPMainViewController getActiveInstance].loginStatus=(int)[prefs integerForKey:kLOGINMODE];
    //IS LOGGED IN SO CONNECT TO SERVER
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
      //CONNECT TO SERVER AND FETCH REGION LIST
         [[ClientEmergencyController sharedInstance]updateRegions:self];
        if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR) {
            _silentModeView.hidden =NO;
        }

        
    }
}
-(void)updateProfileName{
    // UPDATE PROFILE NAME CHANGE TO DISPLAY
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * clientName = [prefs stringForKey:kClientName];
    if (clientName != nil && ![clientName isEqualToString:@""]) {
        [_profileButton setTitle:clientName forState:UIControlStateNormal];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
        return 3;
        } else{
            return 2;
        }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        //OPERATOR MODE
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
        _topBar.backgroundColor =[UIColor blackColor];
        // HOME BUTTON
        // PUSH NOTIFICATION
        return 2;
    }
        // HOME BUTTON ONLY
            return 1;
    }
    else if(section == 1){
        if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
            //ARRAY COUNT FOR LOGGED REGIONS
            if([SPMainViewController getActiveInstance].regionArray){
             return   [[SPMainViewController getActiveInstance].regionArray count];
            }
        return 0;
            
        }else{
          //  NOT LOGGED SO SHOW LOGIN BUTTONS
            //  LOGIN AS OPERATOR MODE
            //  LOGIN AS CLIENT MODE
            //  LOGIN AS GUARDIAN MODE
            return 3;
        }
    }
    else if(section == 2){
        // LOGIN TO ANOTHER REGION
        return 1;
    }
    else return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuCell *cell;
    static NSString *CellIdentifier = @"menuCell";
    @try {
        
          cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    [self styleCell:cell for:indexPath];
    // configure your cell here...
   
    return cell;
    
}
-(void)styleCell:(MenuCell *)cell for:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        //NOT LOGGED IN
        if(indexPath.row ==0 ){
            cell.titleView.text=@"Home";
            cell.iconView.image =[UIImage imageNamed:@"homeIcon"];
        }
        else{
            //IS LOGGED IN
            cell.titleView.text=@"Push Notifications";
            cell.iconView.image =[UIImage imageNamed:@"pushMessage"];
        }
    }
    else if ((indexPath.section==1))
    { //LOGGED AS OPERATOR OR CLIENT OR GUARDIAN, SHOWS REGIONS NAMES
        if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
            @try {
                NSDictionary *regionData = [[SPMainViewController getActiveInstance].regionArray objectAtIndex:indexPath.row];
                 cell.titleView.text=[regionData objectForKey:@"description"];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
             cell.iconView.image =[UIImage imageNamed:@"logout"];
            
        }else{
            if(indexPath.row ==0 ){
                //SHOWS LABEL AS OPERATOR MODE
                  cell.titleView.text=@"Operator Mode";
                 cell.iconView.image =[UIImage imageNamed:@"logout"];
               // _silentModeView.hidden=NO;
            }else if (indexPath.row == 1){
                //SHOWS LABEL AS CLIENT MODE
                 cell.titleView.text=@"Client Mode";
                 cell.iconView.image =[UIImage imageNamed:@"logout"];
                //_silentModeView.hidden=YES;
            }else if (indexPath.row == 2){
                //SHOWS LABEL AS GUARDIAN MODE
                cell.titleView.text = @"Guardian Mode";
                cell.iconView.image =[UIImage imageNamed:@"logout"];
               // _silentModeView.hidden=YES;

            }
            
        }
        
    }else if (indexPath.section==2){
        //LOGIN TO ANOTHER REGION
        cell.titleView.text=@"Log to another Region";
        cell.iconView.image =[UIImage imageNamed:@"logout"];
        if([[SPMainViewController getActiveInstance].regionArray count] <=0){
             cell.titleView.text=@"Trying To Connect ...";
        }

    }
}
-(void)openHomePage{
    SPMainViewController *mainView =[SPMainViewController getActiveInstance];
    if(mainView){
        // GET SEGUE FOR HOME PAGE
        NSString *segueIdentifierForIndexPathInLeftMenu =
        [mainView segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForRow:0 inSection:1]];
        // MOVE TO THE HOME PAGE
        [mainView.leftMenu performSegueWithIdentifier:segueIdentifierForIndexPathInLeftMenu sender:mainView.leftMenu];
        // TO RELOAD THE NAME MENTIONED IN THE MENU BAR
        //[mainView.leftMenu viewWillAppear:false];
    }
}
-(IBAction)loginLogout:(id)sender{
    if([SPMainViewController getActiveInstance].loginStatus !=LOGGED_OPERATOR)
        [self logInOperator:sender];
    else{
        [self logOutOperator];
    }
}
-(IBAction)logInOperator:(id)sender{
    
    if(self.operatorPasswordView)
        return;
    
    NSString * message = [NSString stringWithFormat:@"Enter regionID and password."];
    UIAlertView * passwordView = [[UIAlertView alloc] initWithTitle:@"Operator password" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
    self.operatorPasswordView = passwordView;
    passwordView.alertViewStyle =  UIAlertViewStyleLoginAndPasswordInput;
    UITextField * regionIDTextField = [self.operatorPasswordView textFieldAtIndex:0];
    regionIDTextField.placeholder = @"RegionID";
    [passwordView show];
}
-(IBAction) logoutForRegion :(NSString *)regionId{
    if([SPMainViewController getActiveInstance].loginStatus !=LOGGED_OPERATOR){
        
        [[ClientEmergencyController sharedInstance]logoutClient:regionId callback:^(NSError *error) {
            
               [[ClientEmergencyController sharedInstance]updateRegions:self];
                [self .loginLogoutButton setTitle:cLOGOUT forState:UIControlStateNormal];
                [self openHomePage];
            
        }];
    }
    
    else{
        
    [[ClientEmergencyController sharedInstance]logoutOperator:regionId callback:^(NSError *error) {
        
        if(error){
            UIAlertView * failedView = [[UIAlertView alloc] initWithTitle:@"Connection failed." message:@"Try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [failedView show];
            // DDLogInfo(@"becomOperatorForRegion failed with error:%@",[error localizedDescription]);
        }else{
            [[ClientEmergencyController sharedInstance]updateRegions:self];
            [self.loginLogoutButton setTitle:cLOGOUT forState:UIControlStateNormal];
            [self openHomePage];
        }
    }];
}
}

-(IBAction) logOutOperator{
    ClientEmergencyController* operatorEC = [ClientEmergencyController sharedInstance];
    [operatorEC logoutOperator];
    [operatorEC disconnectFromServer];
    [ChatgroupsController sharedInstance].openedChatRoomID =nil;
    operatorEC.chatRoomsVC = nil;

    [SPMainViewController getActiveInstance].loginStatus = LOGGED_NONE;
    [[self tableView ]reloadData];
    [self.loginLogoutButton setTitle:cLOGIN forState:UIControlStateNormal];
    [self openHomePage];
   
}
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView == self.operatorPasswordView){
        if(buttonIndex == 1){
            UITextField * regionIDTextField = [alertView textFieldAtIndex:0];
            UITextField * passwordTextField = [alertView textFieldAtIndex:1];
            
            NSString * regionIDString = regionIDTextField.text;
            if([regionIDString intValue]){
                NSNumber * regionID = [NSNumber numberWithInt:[regionIDString intValue]];
                NSString * password = passwordTextField.text;
                
                if(regionID!=nil){
                    
                  [self becomeOperatorForRegionID:regionID withPassword:password];
                }else [[[UIAlertView alloc]initWithTitle:nil message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show ];
                
            }
            
        }
        self.operatorPasswordView = nil;
    }else if (alertView == self.regionCheckoutView){
        if (buttonIndex == 1) {
            NSDictionary *region = [[SPMainViewController getActiveInstance].regionArray objectAtIndex:alertView.tag];
            [self logoutForRegion:[region objectForKey:@"regionID"] ];

        }
//        else
//            [[[UIAlertView alloc]initWithTitle:nil message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show ];

    }
}



//OPERATOR REGION LOGGED INN
-(void) becomeOperatorForRegionID:(NSNumber *) regionID withPassword:(NSString *) password{
    [SVProgressHUD showWithStatus:@"Logging in .."];
    [SPMainViewController getActiveInstance].loginStatus = LOGGED_OPERATOR;
     ClientEmergencyController * operatorEC = [ClientEmergencyController sharedInstance];
    [operatorEC connectToServerForMapRegionID:regionID withPassword:password callback:^(NSError *error) {
        [SVProgressHUD dismiss];
        if(error){
            UIAlertView * failedView = [[UIAlertView alloc] initWithTitle:@"Connection failed." message:@"Your password is not correct. Try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [failedView show];
            // RESET THE LOGIN STATUS
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            [SPMainViewController getActiveInstance].loginStatus=(int)[prefs integerForKey:@"LOGINMODE"];
            
            // DDLogInfo(@"becomOperatorForRegion failed with error:%@",[error localizedDescription]);
        }else{
           if(regionID && password)
            [self updateLoginStatus:LOGGED_OPERATOR];
            [SPMainViewController getActiveInstance].loginStatus = LOGGED_OPERATOR;
            [self updateRegion];
            [self openHomePage];
        
        }
    }];
}
-(void) updateLoginStatus:(int)loginStatus{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:loginStatus forKey:kLOGINMODE];
    [prefs synchronize];
}
-(void)updateRegion{
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
        if([prefs stringForKey:kOperatorID]){
            //LOGIN IS COMPLETED
            [[ClientEmergencyController sharedInstance]updateRegions: self];
        }else{
            //LOGIN NOT COMPLETED SO PLEASE WAIT A SECOND
            [self performSelector:@selector(updateRegion) withObject:self afterDelay:1.0 ];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        // NO TITTLE
    return 0.0;
    }else if(section == 1){
        // TITTLE SAYS LOGIN/OP MODE / CL MODE / GURD MODE
        return 40;
    }else{
        // LAST NO TITTLE
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //SHOWS LABEL NAME AS OPERATOR, CLIENT, LOGIN, GUARDIAN
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(20,0, 320, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame] ;
    label.textColor = [UIColor grayColor];
    
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
        label.text = @"Operator Mode";
        _silentModeView.hidden=NO;
    }
    
    else if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_GUARDIAN){
        
        label.text = @"Guardian Mode";
        _silentModeView.hidden=YES;
    }
    
    else if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
       
        label.text = @"Client Mode";
        _silentModeView.hidden=YES;

    }

    else {
        label.text = @"Login Mode";
        _silentModeView.hidden=YES;

    }
    
    [headerView addSubview:label];
    return headerView;
}


/*----------------------------------------------------*/
#pragma mark - TableView Delegate -
/*----------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else if(indexPath.section == 1){
        if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
            
            // LOGOUT CONFIRMATION FOR THAT REGION
            
            NSMutableDictionary *regionsData = [[SPMainViewController getActiveInstance].regionArray objectAtIndex:indexPath.row];
            NSString *logoutRegionName = [regionsData objectForKey:@"description"];
            
            self.regionCheckoutView = [[UIAlertView alloc] initWithTitle:@"Logout of Region: " message:logoutRegionName delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            
            
            self.regionCheckoutView.tag=indexPath.row;
            [self.regionCheckoutView  show];
            //[self logOutOperator];

            
            
        }else{
            if(indexPath.row == 0){
                // LOGIN AS OPERATOR MODE
                if([SPMainViewController getActiveInstance].loginStatus !=LOGGED_OPERATOR){
                     [self logInOperator:self];
                }
            }else{
                 // LOGIN AS CLIENT MODE
                if(indexPath.row == 1){
                    [SPMainViewController getActiveInstance].tryToLogin =LOGGED_CLIENT;
                }else{
                    // LOGIN AS GUARDIAN MODE
                    [SPMainViewController getActiveInstance].tryToLogin =LOGGED_GUARDIAN;
                }
                [self loginAsClient];
            }
        }
    }else if(indexPath.section == 2){
        
        // LOGIN TO ANOTHER OPERATOR REGION
        if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR ){
            _silentModeView.hidden=NO;
            [self logInOperator: self];

        }else{
            // LOGIN TO ANOTHER CLIENT REGION
            // LOGIN AS CLIENT OR GUARDIAN
            if([SPMainViewController getActiveInstance].loginStatus ==LOGGED_CLIENT){
                 [SPMainViewController getActiveInstance].tryToLogin =LOGGED_CLIENT;
            [self loginAsClient];
            }else{
                 [SPMainViewController getActiveInstance].tryToLogin =LOGGED_GUARDIAN;
                 [self loginAsClient];
            }
    }
    
    }
}

//CLIENT LOGIN IN METHOD

-(void)loginAsClient{
    SPMainViewController *mainView =[SPMainViewController getActiveInstance];
    
    NSString *segueIdentifierForIndexPathInLeftMenu =
    [mainView segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    // MOVE TO THE HOME PAGE
    [mainView.leftMenu performSegueWithIdentifier:segueIdentifierForIndexPathInLeftMenu sender:mainView.leftMenu];

}

-(void)dealloc{
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(IBAction)silentMode:(id)sender{
    
    NSUserDefaults * prefs =[NSUserDefaults standardUserDefaults];

    if([sender isOn]){
        NSLog(@"Switch is ON");
        [[ClientEmergencyController sharedInstance]silent:@"true"];
        [prefs setBool:YES forKey:@"silentValue"];
        _silentImage.image = [UIImage imageNamed:@"soundOff"];

    } else{
        NSLog(@"Switch is OFF");
         [[ClientEmergencyController sharedInstance]silent:@"false"];
        [prefs setBool:NO forKey:@"silentValue"];
        _silentImage.image = [UIImage imageNamed:@"soundOn"];

    }
    
}

@end
