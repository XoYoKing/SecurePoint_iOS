//
//  PushListViewController.h
//  EmergencyApp
//
//  Created by Muhammed Salih on 09/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPViewController.h"

@interface PushListViewController : SPViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)clickedCompose:(id)sender;
- (IBAction)clickedNext:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nextLabelText;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *composeButton;
@property (strong, nonatomic)UIView * MessageView;

-(void)addMessage:(NSMutableDictionary *)data  onTop:(BOOL)onTop;

@end
