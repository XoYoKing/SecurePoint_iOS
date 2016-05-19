//
//  ChatTypeViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 04/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatTypeViewController.h"
#import "ChatgroupsController.h"
#import "QAConstants.h"
#import "SPMainViewController.h"
#import "SPLeftMenuViewController.h"
#import "PortChecking.h"

@interface ChatTypeViewController ()

@end

@implementation ChatTypeViewController

static ChatTypeViewController *this;

- (void)viewDidLoad {
    [super viewDidLoad];
    this = self;
    [self openActiveChat];
     self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self setArts];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    // Do any additional setup after loading the view.
}
+(instancetype)getActiveInstance{
    if(this){
        return this;
    }else{
    return nil;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    

     self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTranslucent:false];
    [self updateCount];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openchatInitialy{
    @try {
        
    ChatgroupsController *chatgroup =[ChatgroupsController sharedInstance];
    if(chatgroup.openedChatRoomID!=nil && ![chatgroup.openedChatRoomID isEqualToString:@""]){
    //    NSDictionary * chatRoom =
        [chatgroup getOrCreateChatRoomWithID:chatgroup.openedChatRoomID];
        UIViewController *targetViewController = [self.storyboard instantiateViewControllerWithIdentifier:opCHATPAGE];
        if (self.navigationController) {
            [self.navigationController pushViewController:targetViewController animated:NO];
        }
    }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)openActiveChat{
    
    ChatgroupsController *chatgroup =[ChatgroupsController sharedInstance];
    if(chatgroup.openedChatRoomID!=nil && ![chatgroup.openedChatRoomID isEqualToString:@""]){
        
        NSDictionary * chatRoom = [chatgroup getOrCreateChatRoomWithID:chatgroup.openedChatRoomID];
        [self openChatForChatRoom:chatRoom];
        
    }
}

- (void) openChatForChatRoom:(NSDictionary *)chatRoom{
    
    while([self.navigationController topViewController] != self){
        [self.navigationController popViewControllerAnimated:NO];
    }
      [self performSegueWithIdentifier:opCHATPAGE sender:self];
    // Do any additional setup after loading the view.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSString *ident = [segue identifier];
    
    if([ident isEqualToString:opCHATLIST]){
        [ChatgroupsController sharedInstance].chatMode = CHATMODETEXT;
    }else if([ident isEqualToString:opVIDLIST]){
        [ChatgroupsController sharedInstance].chatMode = CHATMODEVIDEO;
    }else if([ident isEqualToString:opAUDLIST]){
       [ChatgroupsController sharedInstance].chatMode = CHATMODEAUDIO;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
-(int)getCount:(int)mode{
    if(mode == CHATMODETEXT){
        return  (int)[[[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode != 'video' && mode != 'audio')"]]count];
        
    }
    else if(mode == CHATMODEVIDEO){
        return  (int)[[[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode == 'video')"]]count];
    }
    else if(mode == CHATMODEAUDIO){
        return  (int)[[[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode == 'audio')"]]count];
    }
    else{
        return 0;
    }
}
-(void)updateCount{
    _chatCount.text =[NSString stringWithFormat:@"%i",[self getCount:CHATMODETEXT]];
     _vidCount.text =[NSString stringWithFormat:@"%i",[self getCount:CHATMODEVIDEO]];
     _audioCount.text =[NSString stringWithFormat:@"%i",[self getCount:CHATMODEAUDIO]];
    
}
-(void )setArts{
    
    
    //self.title =cAPPNAME;
    
    // BUTTON CUST ART
    self.chatButton.backgroundColor =[UIColor clearColor];
    self.audioButton.backgroundColor =[UIColor clearColor];
    self.vidButton.backgroundColor =[UIColor clearColor];
    
//     self.chatButton.layer.cornerRadius = 10;
//     self.audioButton.layer.cornerRadius = 10;
//     self.vidButton.layer.cornerRadius = 10;
    
    self.chatCount.layer.masksToBounds = YES;
     self.chatCount.layer.cornerRadius = 18;
    
    self.vidCount.layer.masksToBounds = YES;
     self.vidCount.layer.cornerRadius = 18;
    
    self.audioCount.layer.masksToBounds = YES;
     self.audioCount.layer.cornerRadius = 18;
    }

@end
