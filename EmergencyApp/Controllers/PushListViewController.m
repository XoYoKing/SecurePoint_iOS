//
//  PushListViewController.m
//  EmergencyApp
//
//  Created by Muhammed Salih on 09/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "PushListViewController.h"
#import "ComposePushViewController.h"
#import "PushTableViewCell.h"
#import "ClientEmergencyController.h"
#import "SVProgressHUD.h"
#import "NSDate+ISODate.h"
#import "QAConstants.h"
#import "SPMainViewController.h"

@interface PushListViewController ()

@end

@implementation PushListViewController

static NSMutableArray *_pushedMesseges;

- (void)viewDidLoad {
    [super viewDidLoad];
    [_pushedMesseges removeAllObjects];
    [self fetchPushedMessages];
    
    if ([SPMainViewController getActiveInstance].loginStatus !=LOGGED_OPERATOR && [SPMainViewController getActiveInstance].loginStatus !=LOGGED_CLIENT) {
        self.composeButton.hidden = YES;
    }else{
        self.composeButton.hidden = NO;
    }

    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

-(void)fetchPushedMessages{
    if(!_pushedMesseges){
        _pushedMesseges =[[NSMutableArray alloc]init];
        
    }
    if(_pushedMesseges.count <=0){
    [self fetchNextHistory];
    }

}
- (IBAction)clickedNext:(id)sender {
    [self fetchNextHistory];
}

-(void)addMessage:(NSMutableDictionary *)data onTop:(BOOL)onTop{
    if(!_pushedMesseges){
        _pushedMesseges =[[NSMutableArray alloc]init];
    }
    if(onTop){
        [_pushedMesseges insertObject:data atIndex:0];
    }else{
    [_pushedMesseges addObject:data];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pushedMesseges.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PushTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushTableViewCell"];
    [cell.data setText:[NSString stringWithFormat:@"%@",[[_pushedMesseges objectAtIndex:indexPath.row] objectForKey:@"message"]]];
    @try {
        NSMutableArray *regions =  [[_pushedMesseges objectAtIndex:indexPath.row] valueForKey:@"regionNames"] ;
         [cell.users setText:[NSString stringWithFormat:@"%@",[regions componentsJoinedByString:@", "]]];
    }
    @catch (NSException *exception) {
        
    }
    [cell.title setText:[NSString stringWithFormat:@"%@",[[_pushedMesseges objectAtIndex:indexPath.row] objectForKey:@"title"]]];
    [cell.time setText:[NSString stringWithFormat:@"%@",[[_pushedMesseges objectAtIndex:indexPath.row] objectForKey:@"sendTime"]]];
    @try {
     NSDate *date =[NSDate QAdateFromISODate:cell.time.text];
        [cell.time setText:[NSString stringWithFormat:@"%@",[QAConstants getCurrentTime:date inFormat:nil]]];
    }
    @catch (NSException *exception) {
        
    }
    
    if(indexPath.row%2 == 0){
        cell.contentView.backgroundColor =[UIColor whiteColor];
    }else{
        cell.contentView.backgroundColor =[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * message=[NSString stringWithFormat:@"%@",[[_pushedMesseges objectAtIndex:indexPath.row] objectForKey:@"message"]];
    
    
    PushTableViewCell *cell = (PushTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    UIFont *yourFont=[UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
    CGSize sizeOfText=[cell.data.text sizeWithFont:yourFont constrainedToSize:CGSizeMake(cell.data.frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    if (message.length >78 || sizeOfText.height>45) {
        
               //UIVIEW FOR PUSHMESSAGE
        _MessageView = [[UIView alloc] initWithFrame:CGRectMake(0,65, self.view.frame.size.width, self.view.frame.size.height-70)];
        _MessageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_MessageView];
        //UIBUTTON INSIDE UIVIEW TO CLOSE UIVIEW
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(closeView)forControlEvents:UIControlEventTouchUpInside];
        UIImage *buttonImage = [UIImage imageNamed:@"close.png"];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(_MessageView.frame.size.width-60, 0, 45, 45.0);
        [_MessageView addSubview:button];
        
        
        //UITEXTVIEW INSIDE UIVIEW FOR PUSHMESSAGE
        UITextView *newTextView = [[UITextView alloc]initWithFrame:CGRectMake(20,45,_MessageView.frame.size.width-40, _MessageView.frame.size.height-90)];
        newTextView.editable=false;
        newTextView.text = [NSString stringWithFormat:@"%@",[[_pushedMesseges objectAtIndex:indexPath.row] objectForKey:@"message"]];
        [_MessageView addSubview:newTextView];
 
    }
    
  }

//IBACTION METHOD FOR DISMISSING _MESSAGEVIEW
- (void)closeView{
    [_MessageView removeFromSuperview];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    ComposePushViewController *dest =[segue destinationViewController];
    dest.pushListController =self;

    
    // Pass the selected object to the new view controller.
}
-(void)fetchNextHistory{
    
    [SVProgressHUD showInfoWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    _nextLabelText.text=@"Loading Notifications...";
    _nextButton.hidden =true;
    
    //PUSHNOTIFICATION COUNT, IF REMINDER VALUES CAME ON DIVIDING.
    int pushMessageCount;
    float mode=_pushedMesseges.count % 2;
    if (mode) {
        //IF REMINDER COMES
        pushMessageCount= (int)(_pushedMesseges.count/2)+1;
    }else{
        //IF NO REMINDER
        pushMessageCount=(int)_pushedMesseges.count/2;
    }
    
    [[ClientEmergencyController sharedInstance]fetchPushHistory:[NSString stringWithFormat:@"%ld",(unsigned long)pushMessageCount] andoncompltion:^(id args) {
     [SVProgressHUD dismiss];
        
     NSMutableDictionary *messages = [args objectForKey:@"data"];
        
//        //////
//        if ([[NSString stringWithFormat:@"%@",[args objectForKey:@"data"]] isEqualToString:@"<null>"])
//            return ;
//        //////

            if(messages && messages.count>0){
        //if(messages ){
            
            for (NSMutableDictionary *data in messages) {
                [self addMessage:data onTop:false];
            }
           
            [_tableView reloadData];

            _nextButton.hidden =false;
            
            _nextLabelText.text=@"Load more...";
        }else{
            _nextLabelText.text=@"No more Notifications.";
//            if(_pushedMesseges.count == 0){
//               _nextLabelText.text=@"No Notifications to display...";
//                [SVProgressHUD dismiss];
//            }
        }

        
    }  ];
}

- (IBAction)clickedCompose:(id)sender {
}
@end
