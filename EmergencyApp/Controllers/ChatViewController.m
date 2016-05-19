//
//  ChatViewController.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatViewCell.h"
#import "EmergencyController.h"
#import "ClientEmergencyController.h"
#import "ChatgroupsController.h"
#import "SPMainViewController.h"
//#import "CommunicationViewController.h"
#import "NSDate+ISODate.h"
#import "QAConstants.h"
#import "Constants.h"
#import "PortChecking.h"

static  NSString * kTypingMessageSuffix = @"...";
CGRect orginalFrame ;
BOOL keyBoardShown =false;
@interface ChatViewController ()
{
    BOOL hideFooter;
}
@property(nonatomic) NSString * currentUserMessage;
@property(nonatomic) NSMutableArray * messages;
@property(nonatomic) NSMutableArray * typingMessages;
@property(nonatomic) NSMutableDictionary * heightsForCells;


@end

@implementation ChatViewController

- (void) clearMessages{
    [self.typingMessages removeAllObjects];
    [self.messages removeAllObjects];
    [self.tableView reloadData];
}


-(void) addMessages:(NSArray *)messages typingMessages:(NSArray *) typingMessages{
    
    if([typingMessages count]){
        if(!self.typingMessages)
            self.typingMessages = [NSMutableArray array];
        for(NSDictionary * newMessage in typingMessages){
            NSString * fromID = newMessage[@"fromID"];
            BOOL updated = NO;
            for(int i=0; i < [self.typingMessages count]; i++){
                NSDictionary * oldMessage = self.typingMessages[i];
                if([oldMessage[@"fromID"] isEqualToString:fromID]){
                    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.messages count]+i inSection:0];
                    
                    if([newMessage[@"text"] length] != 0){
                        [self.typingMessages replaceObjectAtIndex:i withObject:newMessage];
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }else{
                        [self.typingMessages removeObjectAtIndex:i];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        
                    }
                    updated = YES;
                    break;
                }
            }
            
            if(!updated){
                if([newMessage[@"text"] length] == 0)
                    break;
                
                if([fromID isEqualToString:self.commonEC.userID]){
                    [self.typingMessages addObject:newMessage];
                    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:([self.messages count]+[self.typingMessages count]-1) inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                }else{
                    [self.typingMessages insertObject:newMessage atIndex:0];
                    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:([self.messages count]) inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
    }
    
    // messages
    
    if([messages count]){
        if(self.messages)
            [self.messages addObjectsFromArray:messages];
        else
            self.messages = [messages mutableCopy];
        
        NSMutableArray * insertPaths = [NSMutableArray arrayWithCapacity:[messages count]];
        for(long i = [self.messages count]-[messages count]; i < [self.messages count];i++ ){
            [insertPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    [self scrollToBottom];
    //[self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"Chat";
    self.automaticallyAdjustsScrollViewInsets = YES;
    if([SPMainViewController getActiveInstance].loginStatus == LOGGED_CLIENT){
        [self.navigationItem setHidesBackButton:YES];
    }
    self.commonEC =[ClientEmergencyController sharedInstance];
    [ChatgroupsController sharedInstance].chatVC= self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   // self.tableView.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1];
    self.tableView.backgroundColor = [UIColor  clearColor];
    //self.view.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1];
    
    _heightsForCells = [NSMutableDictionary dictionary];
    
    self.messages = [NSMutableArray array];
    self.typingMessages = [NSMutableArray array];
    NSDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    [self addMessages:chatRoom[@"messages"] typingMessages:chatRoom[@"typingMessages"]];
    
    hideFooter = NO;
    //UINib * nib =  [UINib nibWithNibName:@"ChatViewCells" bundle:nil];
    
    [self.tableView registerClass:[ChatViewCell class] forCellReuseIdentifier:@"ChatViewCells"];
    //self.tableView.allowsSelection = NO;
    //self.tableView.keyboardDismissMode = UIScrollViewKeyboard;
    
    //[self becomeFirstResponder];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showHideKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    /* [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(keyboardDidShown:)
     name:UIKeyboardDidShowNotification object:nil];
     
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self resignFirstResponder];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self art];
    
}

-(void)art{
    _inputField.layer.cornerRadius=5;
    _sendButton.layer.cornerRadius=5;
}
# pragma mark Overwrites UIViewerController



# pragma  mark Keyboard handling
-(BOOL) canBecomeFirstResponder{
    
    return hideFooter;
}


- (void)keyboardWillShown:(NSNotification*)aNotification
{
 
    if(!keyBoardShown)
    {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    orginalFrame =self.view.frame;
    
    CGRect frame = self.view.frame;
    frame.size.height =self.view.frame.size.height -kbSize.height+50;
    self.view.frame =frame;
    self.tableView.frame =frame;
    
    [self scrollToBottom];
        
    }
    keyBoardShown= TRUE;
}

-(void) scrollToBottomWithOffset:(float) offset{
    CGPoint bottomOffset = CGPointMake(0,(self.tableView.contentSize.height+offset) - (self.tableView.bounds.size.height - self.tableView.contentInset.bottom));
    
    [self.tableView setContentOffset:bottomOffset animated:YES];
    
}

-(void) scrollToBottom{
    // its executed after gui updated (content size is updated)
    [self performSelector:@selector(_scrollToBottom) withObject:nil afterDelay:0];
    
}

-(void) _scrollToBottom{
    if(self.tableView.contentSize.height > (self.tableView.bounds.size.height - self.tableView.contentInset.bottom)){
        CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - (self.tableView.bounds.size.height - self.tableView.contentInset.bottom));
        [self.tableView setContentOffset:bottomOffset animated:YES];
        
    }
    
}

- (void)keyboardDidShown:(NSNotification*)aNotification
{
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    keyBoardShown =false;
    self.view.frame =orginalFrame;
    self.tableView.frame=orginalFrame;
}


-(void)showHideKeyboard:(UIGestureRecognizer*)tapGestureRecognizer
{
    if(!hideFooter)
        hideFooter = YES;
    
    UIViewController *ct =self;
    NSLog(@"%@",ct.title);
    if([self isFirstResponder]){
        // hideFooter = NO;
        [self.tableView reloadData];
        
        [self resignFirstResponder];
    }
    else{
        //  hideFooter = YES;
        [self.tableView reloadData];
        
        [self becomeFirstResponder];
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIKeyInputProtocol

- (void)deleteBackward{
    if([self.currentUserMessage length]){
        self.currentUserMessage = [self.currentUserMessage substringToIndex:[self.currentUserMessage length]-1];
        
        NSDictionary * msg = [self createNewTyping:YES messageWithText:self.currentUserMessage];
        
        [[ChatgroupsController sharedInstance] addMessages:nil typingMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        [self.commonEC sendMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        
    }
}

- (BOOL)hasText{
    return YES;
}


- (NSDictionary *) createNewTyping:(BOOL) typing messageWithText:(NSString *) text{
    
    NSMutableDictionary * msg = [NSMutableDictionary dictionary];
    msg[@"text"] = text;
    msg[@"typing"] =[NSNumber numberWithBool:typing];
    msg[@"fromID"] = self.commonEC.userID;
    if(!typing){
        msg[@"dateCreated"] = [NSDate QAcurrentISODate];
    }
    return msg;
}

- (void)insertText:(NSString *)text{
    
    if(!self.currentUserMessage) self.currentUserMessage = [NSString string];
    
    if([text isEqualToString:@"\n"] && [self.currentUserMessage length] == 0){
        [self resignFirstResponder];
        return;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponder];
        NSDictionary * msg = [self createNewTyping:NO messageWithText:self.currentUserMessage];
        
        //[self.chatRoomsVC addMessages:@[msg] toChatRoomID:self.chatRoomID];
        
        self.currentUserMessage = [NSString string];
        NSDictionary * typingMsg = [self createNewTyping:YES messageWithText:self.currentUserMessage];
        
        [[ChatgroupsController sharedInstance] addMessages:@[msg] typingMessages:@[typingMsg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        //[self.chatRoomsVC addTypingMessages:@[typingMsg] toChatRoomID:self.chatRoomID];
        [self.commonEC sendMessages:@[typingMsg,msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        
    }else{
        self.currentUserMessage = [self.currentUserMessage stringByAppendingString:text];
        NSDictionary * msg = [self createNewTyping:YES messageWithText:self.currentUserMessage];
        
        //[self.chatRoomsVC addTypingMessages:@[msg] toChatRoomID:self.chatRoomID];
        [[ChatgroupsController sharedInstance] addMessages:nil typingMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        
        [self.commonEC sendMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        
    }
    NSLog(@"Insert text:%@",text);
    
}

#pragma mark - Helpers
- (CGFloat) heightForText:(NSString *) text{
    return [ChatViewCell height:text forWidth:self.view.frame.size.width];
}

- (NSAttributedString *) attributedTextForTypingText:(NSString *) text withColor:(UIColor *) color{
    
    long lastLettersCount = [text length] >= 3 ? 3 : [text length];
    NSString * threeLastLeters = [text substringFromIndex:[text length]-lastLettersCount];
    NSArray * components = [threeLastLeters componentsSeparatedByString:@" "];
    NSString * lastComponentWithoutSpaces = [components objectAtIndex:[components count]-1];
    
    NSString * trimmedText = [text substringToIndex:[text length]-[lastComponentWithoutSpaces length]];
    
    NSString * coloredText;
    if([lastComponentWithoutSpaces length]){
        coloredText = [NSString stringWithFormat:@"%@...",lastComponentWithoutSpaces];
        text = trimmedText;
    }
    else{
        coloredText = @"...";
    }
    NSMutableAttributedString * fancyText = [[NSMutableAttributedString alloc] initWithString:text];
    NSAttributedString * coloredTextAttributed = [[NSAttributedString alloc] initWithString:coloredText attributes:@{NSForegroundColorAttributeName:color}];
    
    [fancyText appendAttributedString:coloredTextAttributed];
    return fancyText;
    
}

#pragma mark - Table view delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    
    if(self.heightsForCells[indexPath]){
        NSNumber * keyPath = [NSNumber numberWithInt:(int) indexPath.row ];
        height =  [self.heightsForCells[keyPath] floatValue];
        // DDLogVerbose(@"cached height:%f",height);
    }else{
        if(indexPath.row < [self.messages count]){
            NSDictionary * message = self.messages[indexPath.row];
            NSNumber * keyPath = [NSNumber numberWithInt:(int) indexPath.row ];
            self.heightsForCells[keyPath] =[NSNumber numberWithFloat:[self heightForText:message[@"text"]]];
            height = [self.heightsForCells[keyPath] floatValue];
            // DDLogVerbose(@"text:%@,height:%f",message[@"text"],height);
            
        }else{
            long index =indexPath.row - [self.messages count];
            NSDictionary * message = self.typingMessages[index];
            NSString * text =message[@"text"];
            if(![text length]) text = @" "; // to handle empty typing message with correct height
            if(![message[@"fromID"] isEqualToString:self.commonEC.userID]){
                text = [text stringByAppendingString:kTypingMessageSuffix];
            }
            height =  [self heightForText:text];
            //DDLogVerbose(@"typing text:%@,height:%f",text,height);
            
        }
    }
    return height;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [self.messages count]+[self.typingMessages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ChatViewCell" forIndexPath:indexPath];
    
    NSDictionary * message;
    if(indexPath.row < [self.messages count])
        message = self.messages[indexPath.row];
    else
        message = self.typingMessages[indexPath.row - [self.messages count]];
    
    NSDictionary * user = [[ChatgroupsController sharedInstance]getUserForUserID:message[@"fromID"]];
    
    UIColor * cellColoring;
    BOOL sideBarLeft;
    if([message[@"fromID"] isEqualToString: self.commonEC.userID]){
        cellColoring = [UIColor blueColor];
        sideBarLeft = YES;
        
    }else{
        cellColoring = [UIColor greenColor];
        sideBarLeft = NO;
        
    }
    
    // time
    if([message[@"typing"] boolValue]){
        cell.timeText = @"typing";
    }else{
        NSDate * msgDate = [NSDate QAdateFromISODate:message[@"dateCreated"]];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        dateFormat.dateFormat = @"HH:mm";
        NSString * dateHourMinutes = [dateFormat stringFromDate:msgDate];
        cell.timeText = dateHourMinutes;
    }
    
    
    if([message[@"typing"] boolValue] && ![message[@"fromID"] isEqualToString:self.commonEC.userID]){
        cell.messageText = nil;
        cell.attributedMessageText = [self attributedTextForTypingText:message[@"text"] withColor:cellColoring];
    }else{
        cell.attributedMessageText = nil;
        cell.messageText = message[@"text"];
        
    }
    cell.nameAndSideBarColor = cellColoring;
    cell.sideBarLeft = sideBarLeft;
    cell.nameText = user[@"userName"];
    // Configure the cell...
    [cell layoutSubviews];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.tapToStartView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(hideFooter){
        return 0;
    }else{
        return 0;
        //return 120;
    }
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)initiateTextChat{
    
    NSMutableDictionary * chatRoom = [[ChatgroupsController sharedInstance] getOrCreateChatRoomWithID:[ChatgroupsController sharedInstance].openedChatRoomID];
    if(([chatRoom[@"mode"] isEqualToString:@"video"]||[chatRoom[@"mode"] isEqualToString:@"audio"])){
        [[ClientEmergencyController sharedInstance] updateMode:@"chat" forChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.title=@"Chat";
    
    [self initiateTextChat];
    [[UITabBar appearance] setTintColor:[QAConstants QAYellowColor]];
    self.navigationController.navigationBar.barTintColor =[QAConstants QAYellowColor];
    //  [[ChatgroupsController sharedInstance]stopStreaming];
        [[ChatgroupsController sharedInstance]activateAudio:FALSE andVideo:FALSE];
}



- (IBAction)textChanged:(id)sender {
    [self submitText:NO];
}
- (IBAction)endEditing:(id)sender {
    [_inputField resignFirstResponder];
    if(![_inputField.text isEqualToString:@""]){
        [self submitText:YES];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:textField];
    return YES;
}

-(void)submitText :(BOOL)isEnd{
    if (isEnd) {
        [self resignFirstResponder];
        NSDictionary * msg = [self createNewTyping:NO messageWithText:_inputField.text];
        self.currentUserMessage = [NSString string];
        NSDictionary * typingMsg = [self createNewTyping:YES messageWithText:self.currentUserMessage];
        
        [[ChatgroupsController sharedInstance] addMessages:@[msg] typingMessages:@[typingMsg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        //[self.chatRoomsVC addTypingMessages:@[typingMsg] toChatRoomID:self.chatRoomID];
        [self.commonEC sendMessages:@[typingMsg,msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        _inputField.text =@"";
        
    }else{
        self.currentUserMessage = _inputField.text;
        NSDictionary * msg = [self createNewTyping:YES messageWithText:self.currentUserMessage];
        //[self.chatRoomsVC addTypingMessages:@[msg] toChatRoomID:self.chatRoomID];
        [[ChatgroupsController sharedInstance] addMessages:nil typingMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
        
        [self.commonEC sendMessages:@[msg] toChatRoomID:[ChatgroupsController sharedInstance].openedChatRoomID];
    }
}
@end
