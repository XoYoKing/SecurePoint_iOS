//
//  ChatsKindViewController.h
//  EmergencyApp
//
//  Created by Muhammed Salih on 06/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoomsViewCell.h"

@interface ChatsKindViewController : UITableViewController<SWTableViewCellDelegate>
@property(nonatomic) NSMutableArray         *chatRooms;
-(void) emergencyResolvedForChatRoomRow:(NSInteger) row;
- (IBAction)backClick:(id)sender;
-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID;

+ (instancetype) sharedInstance;

@end
