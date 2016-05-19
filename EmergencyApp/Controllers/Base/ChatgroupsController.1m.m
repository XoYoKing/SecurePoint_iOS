//
//  ChatgroupsController.m
//  EmergencyApp
//
//  Created by Mzalih on 04/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ChatgroupsController.h"
#import "ClientEmergencyController.h"
#import "SPTabBarController.h"
#import "SPMainViewController.h"

// Replace with your OpenTok API key
static NSString *const kApiKey = @"45093062";

@interface ChatgroupsController (){
    
@protected
    UIView * _videoView;
    
    BOOL _publishAudio;
    BOOL _publishVideo;
    BOOL _receiveAudio;
    BOOL _receiveVideo;
    
}
@end
@implementation ChatgroupsController


- (instancetype) init{
    self = [super init];
    _chatRooms = [NSMutableArray array];
    _users = [NSMutableDictionary dictionary];
    
    NSLog(@"__________CHATROOOMS INITIT ___________");
    
    return self;
}

+ (instancetype) sharedInstance{
    static ChatgroupsController * sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(NSDictionary *) getUserForUserID:(NSString *) userID{
    return self.users[userID];
}

-(NSMutableDictionary *) getOrCreateChatRoomWithID:(NSString *) chatRoomID{
    NSMutableDictionary* chatRoomToFind = nil;
    for(NSMutableDictionary * chatRoom in self.chatRooms){
        if([chatRoom[@"_id"] isEqualToString:chatRoomID]){
            chatRoomToFind = chatRoom;
        }
    }
    
    if(!chatRoomToFind){
        chatRoomToFind = [NSMutableDictionary dictionary];
        chatRoomToFind[@"_id"] = chatRoomID;
        chatRoomToFind[@"messages"] = [NSMutableArray array];
        chatRoomToFind[@"typingMessages"] = [NSMutableArray array];
        chatRoomToFind[@"users"] = [NSMutableArray array];
        [self.chatRooms addObject:chatRoomToFind];
        
    }
    return chatRoomToFind;
}
- (void) updateMode:(NSString *) mode forChatRoomID:(NSString *) chatRoomID{
    NSMutableDictionary * chatRoom = [self getOrCreateChatRoomWithID:chatRoomID];
    if(![chatRoom[@"mode"] isEqualToString:mode]){
        chatRoom[@"mode"] = mode;
        if([chatRoomID isEqualToString:self.openedChatRoomID]){
            
         //   [[SPTabBarController getActiveInstance]setSelectedIndex:2];
            [[SPTabBarController getActiveInstance] switchToMode:mode];
            
        }
    }
}
- (void) usersJoined:(NSArray *) users chatRoomID:(NSString *) chatRoomID{
    
    
    NSMutableDictionary* chatRoomToUpdate = [self getOrCreateChatRoomWithID:chatRoomID];
    
    NSMutableArray * updatedUsers = [NSMutableArray arrayWithCapacity:[users count]];
    
    for(NSDictionary * user in users){
        [updatedUsers addObject:[self updateUsersWithUser:user]];
    }
    [chatRoomToUpdate[@"users"] addObjectsFromArray:updatedUsers];
    

}
-(void) emergencyResolvedForChatRoomRow:(NSInteger) row{
    
    NSDictionary * chatRoom = self.chatRooms[row];
    
  //  [ emergencyResolvedForChatRoomID:chatRoom[@"_id"]];
    [self emergencyResolvedForChatRoomID:chatRoom[@"_id"]];
    
}

-(void) updateUser:(NSDictionary *)user{
// UPDATE THE COUNT ,USER TABLE IN THE CURRENT CHAT MODE ETC
}

-(NSMutableDictionary *) updateUsersWithUser:(NSDictionary *) user{
    if(self.users[user[@"_id"]]){
        [self.users[user[@"_id"]] addEntriesFromDictionary:user];
    }else{
        [self.users setObject:[user mutableCopy] forKey:user[@"_id"]];
    }
    return self.users[user[@"_id"]];
}


-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID{
  
    
    for(int i = 0; i < [self.chatRooms count]; i++){
        NSDictionary * chatRoom = self.chatRooms[i];
        if([chatRoom[@"_id"] isEqualToString:chatRoomID]){
            [self.chatRooms removeObjectAtIndex:i];
            
            // remove users if they are not in different chatrooms
            for(NSDictionary * user in chatRoom[@"users"]){
                if(![self isUserInAnyChatRoom:user]){
                    [self.users removeObjectForKey:user[@"_id"]];
                }
            }
    //UPDATE TABLE HERE
            
            break;
        }
    }
    if([chatRoomID isEqualToString:self.openedChatRoomID]){
        self.openedChatRoomID=nil;
        
      [self.chatVC emergencyResolved];
    }
}

- (NSArray*) getChatRooms{
    return self.chatRooms;
}



-(void) addMessages:(NSArray *)messages typingMessages:(NSArray *) typingMessages toChatRoomID:(NSString *)chatRoomID{
    
    NSMutableDictionary * chatRoomToUpdate = [self getOrCreateChatRoomWithID:chatRoomID];
    
    
    if([typingMessages count]){
        NSMutableArray * oldTypingMessages = chatRoomToUpdate[@"typingMessages"];
        
        for(NSDictionary * message in typingMessages){
            BOOL updated = NO;
            for(int i = 0; i < [oldTypingMessages count]; i++){
                NSDictionary * oldMessage = oldTypingMessages[i];
                if([oldMessage[@"fromID"]  isEqualToString:message[@"fromID"]]){
                    [oldTypingMessages replaceObjectAtIndex:i withObject:message];
                    updated = YES;
                }
            }
            if(!updated){
                [chatRoomToUpdate[@"typingMessages"] addObject:message];
            }
        }
    }
    
    if([messages count]){
        NSMutableArray * oldMessages = chatRoomToUpdate[@"messages"];
        
        [oldMessages addObjectsFromArray:messages];
    }
    
    
    if([chatRoomID isEqualToString:self.openedChatRoomID]){
        
        [self.chatVC addMessages:messages typingMessages:typingMessages];
    }
    
}


- (void) addChatRooms:(NSArray *) chatRooms{
    for(NSDictionary * chatRoom in chatRooms){
        NSMutableDictionary * newChatRoom = [chatRoom mutableCopy];
        if(chatRoom[@"messages"]){
            newChatRoom[@"messages"] = [chatRoom[@"messages"] mutableCopy];
        }else{
            newChatRoom[@"messages"] = [NSMutableArray array];
        }
        [_chatRooms addObject:newChatRoom];
    }
}

- (void) currentLocationUpdated{
   // [self.tableView reloadData];
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
-(void) getOTTokencallback:(void(^)(NSString * sessionID, NSString * token))callbackToView {
    
    [[ClientEmergencyController sharedInstance] OTTokenForChatRoomID:self.openedChatRoomID callback:^(NSString *sessionID, NSString *token) {
        
        NSLog(@"getOTToken callback with sessionID:%@, token:%@",sessionID, token);
        self.sessionID = sessionID;
        self.token     = token;
        callbackToView(sessionID,token);
       
    }];
}








#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect{
 }

-(void)doDisconnect
{
    
}



/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{   _publishAudio =TRUE;
    _publishVideo = ![SPMainViewController getActiveInstance].isOperrator;
   
}

- (void)doUnpublish{
    
}
/**
 * Cleans the subscriber from the view hierarchy, if any.
 */
- (void)doUnsubscribe
{}


-(void) updateSubScriber{
   
}

@end

