//
//  RegionListViewController.m
//  EmergencyApp
//
//  Created by Jithu on 3/16/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import "RegionListViewController.h"
#import "Constants.h"
#import "ConnectionRegionListController.h"
#import "ClientEmergencyController.h"
#import "SPMainViewController.h"
#import "EmergencyController.h"
#import "SPLeftMenuViewController.h"
#import "SVProgressHUD.h"
#import "SPMainViewController.h"
#import "QAConstants.h"



@interface RegionListViewController ()

@end

@implementation RegionListViewController

@synthesize clientRegionListTableView;
@synthesize clientRegionListArray;

BOOL isSearchMode= false;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //For proper showing of SearcBar under Navigationbar in all iOS versions.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    // LABLE TO DISPLAY TEXT INSIDE THE TABLE VIEW
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UILabel *searchTextlabel = [[UILabel alloc]initWithFrame:CGRectMake((screenWidth/2)-80, (screenHeight/2)-50, 160, 50)];
    [searchTextlabel setBackgroundColor:[UIColor clearColor]];
    [searchTextlabel setTextColor:[UIColor grayColor]];
    searchTextlabel.textAlignment = NSTextAlignmentCenter;
    [searchTextlabel setFont:[UIFont fontWithName: @"HelveticaNeue-Thin" size:17.0f]];
    [searchTextlabel setText:@"Enter Search Criteria"];
    [clientRegionListTableView addSubview:searchTextlabel];

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void) viewDidAppear:(BOOL)animated{
//    [SVProgressHUD showWithStatus:@"Loading ..."];
//}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [QAConstants QARedColor];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
        return [clientRegionListArray count];
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *cellIdentifier=@"regionList";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }

    // REGIONS IN THE TABLE CELL
    NSMutableDictionary *regions = nil;
        regions = [clientRegionListArray objectAtIndex:indexPath.row];
    cell.textLabel.text=[regions valueForKey:@"description"];
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica Neue Thin" size:20];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSMutableDictionary *regions = nil;
        if (isSearchMode) {
            regions = [searchResults objectAtIndex:indexPath.row];
        }else{
            regions =  [clientRegionListArray objectAtIndex:indexPath.row];
        }

    if ([regions valueForKey:@"clientPassword"]&& ![[regions valueForKey:@"clientPassword"]isEqualToString:@""]  )
    {
        
    [self.view endEditing:YES];
    NSString * message = [NSString stringWithFormat:@"Do you want to login this Region."];
    UIAlertView * RegionPasswordView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        RegionPasswordView.tag = indexPath.row;
    self.clientRegionPasswordView = RegionPasswordView;
    RegionPasswordView.alertViewStyle =  UIAlertViewStyleSecureTextInput;
    UITextField * regionIDTextField = [self.clientRegionPasswordView textFieldAtIndex:0];
    regionIDTextField.placeholder = @"Password";
    [RegionPasswordView show];
    }else{
         [self becomeClientForRegionID:[regions valueForKey:@"regionID"] withPassword:@"in"];
    }
}


#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSMutableDictionary *regions = nil;
    if(buttonIndex == 1){
        if (isSearchMode) {
            regions = [searchResults objectAtIndex:alertView.tag];
        }else{
            regions =  [clientRegionListArray objectAtIndex:alertView.tag];
        }
        
        UITextField * passwordTextField = [alertView textFieldAtIndex:0];
        
        if([[regions valueForKey:@"clientPassword"]isEqualToString:passwordTextField.text ] &&[regions valueForKey:@"regionID"]){
            NSString * password = passwordTextField.text;

            
            [self becomeClientForRegionID:[regions valueForKey:@"regionID"] withPassword:password];
            
        }else{
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            // SHOW INVALID PASSWORD ALERT
            [[[UIAlertView alloc]initWithTitle:nil message:@"Invalid Password" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show ];
            
        }
    }
    
}

//.................................
//CLIENT OR GUARDIAN REGION LOGGED INN
-(void) becomeClientForRegionID:(NSNumber *) regionID withPassword:(NSString *) password {
    [SVProgressHUD showWithStatus:@"Logging in .."];
    if ([SPMainViewController getActiveInstance].tryToLogin != LOGGED_GUARDIAN){
        [SPMainViewController getActiveInstance].loginStatus = LOGGED_CLIENT;
    }else{
            [SPMainViewController getActiveInstance].loginStatus = LOGGED_GUARDIAN;
        }
    ClientEmergencyController * clientEC = [ClientEmergencyController sharedInstance];
    [self addPassword:password forRegion:regionID];
    [clientEC connectToServerForMapClientRegionID:regionID withPassword:(NSString *) password  callback:^(NSError *error) {
        [SVProgressHUD dismiss];
        if(error){
            UIAlertView * failedView = [[UIAlertView alloc] initWithTitle:@"Connection failed." message:@"Your password is not correct. Try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [failedView show];
            //RESET THE LOGIN STATUS
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            [SPMainViewController getActiveInstance].loginStatus=(int)[prefs integerForKey:@"LOGINMODE"];
            
        }else{
            if(regionID && password)
                [self updateLoginStatus:[SPMainViewController getActiveInstance].tryToLogin];
            [SPMainViewController getActiveInstance].loginStatus = [SPMainViewController getActiveInstance].tryToLogin;
           
            [self updateRegion];
            [self openHomePage];
        }
        
    }];
}
-(void)addPassword:(NSString *)password forRegion :(NSNumber *)regionID{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray * regionPasswords = [[prefs arrayForKey:kClientRegionPasswords] mutableCopy];
    if(!regionPasswords) regionPasswords = [NSMutableArray array];
    BOOL updated = NO;
    for(int i=0; i< [regionPasswords count]; i++){
        NSMutableDictionary * regionPassword = [regionPasswords[i] mutableCopy];
        if([regionPassword[@"regionID"] isEqualToNumber:regionID]){
            regionPassword[@"password"] = password;
            [regionPasswords replaceObjectAtIndex:i withObject:regionPassword];
            updated = YES;
            break;
        }
    }
    if(!updated){
        [regionPasswords addObject:@{@"regionID":regionID, @"password":password}];
    }
    [prefs setObject:regionPasswords forKey:kClientRegionPasswords];
    
}
-(void) updateLoginStatus:(int)loginMode{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:loginMode forKey:kLOGINMODE];
    [prefs synchronize];
}

-(void)updateRegion{
     NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
        if([prefs stringForKey:kClientID]){
           
             [[ClientEmergencyController sharedInstance]updateRegions: (SPLeftMenuViewController *)[SPMainViewController getActiveInstance].leftMenu];
        }
        else{
            [self performSelector:@selector(updateRegion) withObject:self afterDelay:1.0 ];
        }
    }
       else if([SPMainViewController getActiveInstance].loginStatus == LOGGED_GUARDIAN){
            if([prefs stringForKey:kGuardianID]){
                
                [[ClientEmergencyController sharedInstance]updateRegions: (SPLeftMenuViewController *)[SPMainViewController getActiveInstance].leftMenu];
            }
            else{
                [self performSelector:@selector(updateRegion) withObject:self afterDelay:1.0 ];
            }
        }
}

//LOADING HOME PAGE AFTER CLIENT REGION LOGGED INN.
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



//SEARCH DATA FILTERING DELEGATE

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    NSString *URL;
    if ([SPMainViewController getActiveInstance].tryToLogin != LOGGED_GUARDIAN)
        URL =[NSString stringWithFormat:@"http://%@%@=%@",BaseURL,CLientRegionListURL,searchString];
    else
        URL =[NSString stringWithFormat:@"http://%@%@=%@",BaseURL,GuardianRegionURL,searchString];
    
    
    //CALLING API TO DISPLAY CLIENT OR GUARDIAN REGION LIST FROM SERVER
    
    ConnectionRegionListController *connectionRegionList=[[ConnectionRegionListController alloc]init];
    [connectionRegionList GetGlobalWebserviceConnectivityWithResponseValue:nil baseUrl:URL Completion:^(NSMutableDictionary *iData){

        clientRegionListArray = [[NSMutableArray alloc]init];
        clientRegionListArray = [iData valueForKey:@"regions"];
        //[SVProgressHUD showWithStatus:@"Loading ..."];

        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [SVProgressHUD dismiss];
    }];
    
    return YES;

}

@end
