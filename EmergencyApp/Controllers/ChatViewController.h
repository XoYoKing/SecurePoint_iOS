//
//  ChatViewController.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>

#import "EmergencyController.h"
#import "SPViewController.h"

@class ChatRoomsViewController;
//UIKeyInput
@interface ChatViewController : SPViewController <UITableViewDataSource, UITableViewDelegate>{
  
    
}

@property(nonatomic) IBOutlet UIView * tapToStartView;
@property(nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) IBOutlet UIView * messageInsertView;
@property(nonatomic) IBOutlet UITextField * inputField;

- (IBAction)textChanged:(id)sender;
- (IBAction)endEditing:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSString * userName;
@property(nonatomic) ChatRoomsViewController * chatRoomsVC;
@property(nonatomic) EmergencyController * commonEC;



-(void) clearMessages;

-(void) addMessages:(NSArray *)messages typingMessages:(NSArray *) typingMessages;





@end
