//
//  ChatsKindViewController.m
//  EmergencyApp
//
//  Created by Muhammed Salih on 06/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatsKindViewController.h"
#import "ChatgroupsController.h"
#import "ClientEmergencyController.h"
#import "QAConstants.h"
@interface ChatsKindViewController ()

@end

@implementation ChatsKindViewController

- (instancetype) init{
    
    self = [super init];
    return self;
}

+ (instancetype) sharedInstance{
    static ChatsKindViewController * sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)loadData{
    if( [ChatgroupsController sharedInstance].chatMode == CHATMODEAUDIO){
    self.navigationController.navigationBar.barTintColor =[QAConstants QAOrangeColor];
        self.chatRooms =[[NSMutableArray alloc]initWithArray:
        [[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode == 'audio')"]]]; //@"mode"
         self.title =@"Audio";
    }
    else  if( [ChatgroupsController sharedInstance].chatMode == CHATMODEVIDEO){
        self.chatRooms =[[NSMutableArray alloc]initWithArray:
                         [[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode == 'video')"]]]; //@"mode"
         self.title  =@"Video ";
        self.navigationController.navigationBar.barTintColor =[QAConstants QARedColor];
 }
    else if( [ChatgroupsController sharedInstance].chatMode == CHATMODETEXT){
        self.chatRooms =[ChatgroupsController sharedInstance].chatRooms;
        self.chatRooms =[[NSMutableArray alloc]initWithArray:
                         [[ChatgroupsController sharedInstance].chatRooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(mode != 'audio' && mode != 'video')"]]]; //@"mode"
        self.title =@"Chat";
        self.navigationController.navigationBar.barTintColor =[QAConstants QAYellowColor];
   
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.chatRooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomsViewCell" forIndexPath:indexPath];
    
    NSDictionary * chatRoom = self.chatRooms[indexPath.row];
    NSMutableString * usersList = [NSMutableString string];
    
    NSArray * users = chatRoom[@"users"];
    NSArray * clients = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(role == 'client')"]];
    NSArray * operators = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(role == 'operator')"]];
    
    for(NSDictionary * client in clients){
        if([usersList length]!=0){
            [usersList appendString:@", "];
        }
        [usersList appendString:client[@"userName"]];
    }
    
    BOOL involved = NO;
    for(NSDictionary * operator in operators){
        if([usersList length] != 0){
            [usersList appendString:@", "];
        }
        if([[ClientEmergencyController sharedInstance] .userID isEqualToString:operator[@"_id"]]){
            involved = YES;
        }
        [usersList appendString:operator[@"userName"]];
    }
    if(involved){
        cell.name.textColor = [UIColor blackColor];
        cell.icon.image =[UIImage imageNamed:@"tickGreen"];
    }else{
        cell.name.textColor = [UIColor grayColor];
        cell.icon.image =[UIImage imageNamed:@"tickGray"];
    }
    cell.name.text = usersList;
    
    // distance
    NSArray * currentLocation = [[ClientEmergencyController sharedInstance] getCurrentLocation];
    if(currentLocation && [clients count] ){
        NSArray * clientLocation = clients[0][@"location"][@"coordinates"];
        if(clientLocation){
            CLLocation * clCurrentLocation = [[CLLocation alloc] initWithLatitude:[currentLocation[1] doubleValue] longitude:[currentLocation[0]doubleValue]];
            CLLocation * clClientLocation = [[CLLocation alloc] initWithLatitude:[clientLocation[1] doubleValue] longitude:[clientLocation[0] doubleValue]];
            CLLocationDistance distance = [clCurrentLocation distanceFromLocation:clClientLocation];
            double distanceFeets = distance * 3.2808399;
            double distanceMiles = distance * 0.000621371192;
            NSString * distanceText;
            if(distanceMiles > 1){
                distanceText = [NSString stringWithFormat:@"%.1f mi away", distanceMiles];
            }else{
                distanceText = [NSString stringWithFormat:@"%.0f ft away", distanceFeets];
            }
            
            cell.distance.text = distanceText;
        }
    }else{
        cell.distance.text = @"";
    }
    
    // underlying buttons (search for SWTableViewCell on github)
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    if(indexPath.row%2 == 0){
        cell.contentView.backgroundColor =[UIColor whiteColor];
    }else{
        cell.contentView.backgroundColor =[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
    }

    
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] title:@"Resolve"];
    
    return rightUtilityButtons;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    [self emergencyResolvedForChatRoomRow:indexPath.row];
    
}
-(void) emergencyResolvedForChatRoomRow:(NSInteger) row{
    NSDictionary * chatRoom = self.chatRooms[row];
    [[ClientEmergencyController sharedInstance] emergencyResolvedForChatRoomID:chatRoom[@"_id"]withAck:^(id argsData) {
         [self emergencyResolvedForChatRoomID:chatRoom[@"_id"]];
    }];
   // [self emergencyResolvedForChatRoomID:chatRoom[@"_id"]];
    
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID{
    
    for(int i = 0; i < [self.chatRooms count]; i++){
        NSDictionary * chatRoom = self.chatRooms[i];
        if([chatRoom[@"_id"] isEqualToString:chatRoomID]){
            [self.chatRooms removeObjectAtIndex:i];
            
            // remove users if they are not in different chatrooms
            for(NSDictionary * user in chatRoom[@"users"]){
                if(![self isUserInAnyChatRoom:user]){
                    [[ChatgroupsController sharedInstance].users removeObjectForKey:user[@"_id"]];
                }
            }
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    if([chatRoomID isEqualToString:[ChatgroupsController sharedInstance].openedChatRoomID]){
       
        [ChatgroupsController sharedInstance].openedChatRoomID=nil;
    }
}
#pragma mark Helpers
- (BOOL) isUserInAnyChatRoom:(NSDictionary *) user{
    BOOL found = NO;
    for(NSDictionary * chatRoom in self.chatRooms){
        if([chatRoom[@"users"] indexOfObjectIdenticalTo:user] != NSNotFound){
            found = YES;
            break;
        };
        
    }
    
    return found;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * chatRoom = self.chatRooms[indexPath.row];
    UINavigationController *controller  = self.navigationController;
    [self.navigationController popViewControllerAnimated:NO];
    [ChatgroupsController sharedInstance].openedChatRoomID = chatRoom[@"_id"];
    
    UIViewController *targetViewController = [self.storyboard instantiateViewControllerWithIdentifier:opCHATPAGE];
    if (controller) {
        [controller pushViewController:targetViewController animated:NO];
    }
}

@end
