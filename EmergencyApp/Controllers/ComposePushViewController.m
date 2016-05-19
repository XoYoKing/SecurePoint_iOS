 //
//  ComposePushViewController.m
//  EmergencyApp
//
//  Created by Muhammed Salih on 09/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ComposePushViewController.h"
#import "ClientEmergencyController.h"
#import "QAConstants.h"
#import "SPMainViewController.h"
#import <AFNetworking.h>
#import "AFHTTPSessionManager.h"
#import "ConnectionRegionListController.h"
#import "ClientEmergencyController.h"
#import "SVProgressHUD.h"


@interface ComposePushViewController ()

@end

@implementation ComposePushViewController
bool sendButtonFlag = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectionStates = [[NSMutableArray alloc] init];
    
        //GET ALL AVAILABLE REGIONS
        availableRegions = [SPMainViewController getActiveInstance].regionArray;
    
   if ([SPMainViewController getActiveInstance].loginStatus != LOGGED_OPERATOR){
        //FILETR FOR ALL ALLOWED REGIONS
       //clientNotification
       NSPredicate *pred =[NSPredicate predicateWithFormat:@"(clientNotification ==  %i)", 1 ];
;
      availableRegions = [[NSMutableArray alloc]initWithArray:[availableRegions filteredArrayUsingPredicate:pred]];
    }
    if([availableRegions count]<= 0){
        [[[UIAlertView alloc]initWithTitle:nil message:@"You are not allowed to send any push notifications" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil]show];
        [self cancelPush:self];
    }
    

    // add a TOOLBAR with CANCEL & DONE button
    toolBar =[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-pickerView.frame.size.height+50, self.view.frame.size.width,50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor  whiteColor]];

    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];

    
    //Init PICKER and add it to view
pickerView = [[ALPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-pickerView.frame.size.height, self.view.frame.size.width, 0)];
    pickerView.delegate = self;
    _users.inputView =pickerView;
    _users.inputAccessoryView=toolBar;
    
    
     // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    //CANCEL button acton.
- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [_users resignFirstResponder];
}

    //DONE button acion.
- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the PICKER VIEW
    [_users resignFirstResponder];
    
    // perform some ACTION for adding selected regions to textfield.
    NSString * result = [[selectionStates valueForKey:@"description"] componentsJoinedByString:@", "];
    _users.text=result ;
}


#pragma mark -
#pragma mark ALPickerView delegate methods

- (NSInteger)numberOfRowsForPickerView:(ALPickerView *)pickerView {
    return [availableRegions count];
}

- (NSString *)pickerView:(ALPickerView *)pickerView textForRow:(NSInteger)row {
    return [[availableRegions objectAtIndex:row]objectForKey:@"description"];
}

- (BOOL)pickerView:(ALPickerView *)pickerView selectionStateForRow:(NSInteger)row {
    
    if([selectionStates containsObject:[availableRegions objectAtIndex:row]]){
        return true;
    }
    return false;
}

- (void)pickerView:(ALPickerView *)pickerView didCheckRow:(NSInteger)row {
    // To select all the rows
    if(row == -1){
        selectionStates = [[NSMutableArray alloc]initWithArray:availableRegions];
        return;
    }
    // Check whether all rows are selected or only one
    if(![selectionStates containsObject:[availableRegions objectAtIndex:row]]){
        [selectionStates addObject:[availableRegions objectAtIndex:row]];
    }
}

- (void)pickerView:(ALPickerView *)pickerView didUncheckRow:(NSInteger)row {
    // To uncheck all the rows
    if(row == -1){
        [selectionStates removeAllObjects];
        return;
    }
    // Check whether all rows are unchecked or only one
    if([selectionStates containsObject:[availableRegions objectAtIndex:row]]){
        [selectionStates removeObject:[availableRegions objectAtIndex:row]];
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
/*
- (IBAction)sendPush:(id)sender {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"text"]=_message.text;
    data[@"regionsID"]=regionIDArray;
    NSLog(@"%@", regionIDArray);
    [[ClientEmergencyController sharedInstance] sendPushNotification:data andoncompltion:^(id args) {
        
        NSMutableDictionary *messages = [args objectForKey:@"data"];
        if(messages){
           // for (NSMutableDictionary *data in messages) {
                [_pushListController addMessage:messages onTop:true];
                
           // }
            [_pushListController.tableView reloadData];
            //[_tableView reloadData];
        }
        
        [self cancelPush:sender];
    } ];
    
    
//    NSMutableDictionary *message = [NSMutableDictionary dictionary];
//    message[@"message"]=_message.text;
//    message[@"title"]=_message.text;
//    message[@"users"]=_message.text;
//    message[@"time"]=[QAConstants getCurrentTime:nil inFormat:nil];
//    
   // [_pushListController addMessage:message];
   // [_pushListController.tableView reloadData];
  //  [self cancelPush:sender];
    
}
 */

//IBACTION FOR SEND PUSHNOTIFICATION ALONG WITH BUTTON TAP COUNT EVENT.
-(IBAction)sendPush:(id)sender event:(UIEvent *)event{
    
    //BUTTON TAP COUNT
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.tapCount == 1 && !sendButtonFlag) {
        sendButtonFlag = YES;
      //PREPARING DATA TO SEND
    NSMutableDictionary *data = [NSMutableDictionary dictionary]; 
    data[@"message"]=_message.text;
    // To add REGIONID to the array for passing along with sendPush.
    data[@"mapRegionIDs"]=[[NSMutableArray alloc]initWithObjects:[selectionStates valueForKey:@"regionID"], nil];
    //[selectionStates valueForKey:@"regionID"];
    //[[NSMutableArray alloc]initWithObjects:[selectionStates valueForKey:@"regionID"], nil];
        NSString * modeId =@"gardianID";
        
        if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
            modeId =@"operatorID";
        }else if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
            modeId =@"clientID";
        }
        data[modeId]=[[ClientEmergencyController sharedInstance]getUserID];
    
    //CALLING API TO POST DATA TO THE SERVER.
    ConnectionRegionListController *connectionRegionList=[[ConnectionRegionListController alloc]init];
    
    [connectionRegionList PostGlobalWebserviceConnectivityWithResponseValue:data baseUrl:[NSString stringWithFormat:@"http://%@%@",BaseURL,PushNotificationURL] Completion:^(NSMutableDictionary *iData){
        
        sendButtonFlag = NO;
        NSMutableDictionary *data = [iData objectForKey:@"result"];
       

        if([data count]){
            
           //  for (NSMutableDictionary *data in iData) {
            [_pushListController addMessage:data onTop:true];
            
            }
            [_pushListController.tableView reloadData];
            //[_tableView reloadData];

        //}
        
        [self cancelPush:sender];
        
    }];
    }
}

- (IBAction)cancelPush:(id)sender {
    [[self navigationController]popViewControllerAnimated:YES];
}
@end
