//
//  ChatgroupsController.h
//  EmergencyApp
//
//  Created by Mzalih on 04/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>
#import "ChatViewController.h"

@interface ChatgroupsController : NSObject<OTPublisherDelegate, OTSessionDelegate, OTSubscriberDelegate>


@property(nonatomic) NSString               *openedChatRoomID;
@property(nonatomic) NSMutableArray         *chatRooms;

@property(nonatomic) NSMutableDictionary    *users;

//OPEN TOK INSTANCE

@property(nonatomic) NSString               *sessionID;
@property(nonatomic) NSString               *token;

@property(nonatomic)int  chatMode ;


+ (instancetype) sharedInstance;

-(NSMutableDictionary *) getOrCreateChatRoomWithID:(NSString *) chatRoomID;
-(NSDictionary *) getUserForUserID:(NSString *) userID;

-(void) addMessages:(NSArray *)messages typingMessages:(NSArray *) typingMessages toChatRoomID:(NSString *)chatRoomID;
- (void) updateMode:(NSString *) mode forChatRoomID:(NSString *) chatRoomID;
- (void) updateAvailableModes:(BOOL )chat with:(BOOL )audio and :(BOOL )video forChatRoomID:(NSString *) chatRoomID;

-(void) emergencyResolvedForChatRoomID:(NSString *) chatRoomID;
-(void) updateUser:(NSDictionary *)user;
-(void)joinToChat:(NSString *)chatRoom;
-(void)setMicButton:(id)mic andSound:(id)sound;

- (void) usersJoined:(NSArray *) users chatRoomID:(NSString *) chatRoomID;
-(void) getOTTokencallback:(void(^)(NSString * sessionID, NSString * token))callbackToView;

- (NSArray*) getChatRooms;

-(void)switchCam;
-(BOOL)micOff;
-(BOOL)soundOff;
-(void)changeVideoFrame:(CGRect)height;

-(void)doConnect;
-(void)doDisconnect;

-(void)stopStreaming;
-(void)stopStreamingSiri;
-(void)resetStreamning;

-(void)activateAudio:(BOOL)audioStatus andVideo :(BOOL)videoStatus;

@property(nonatomic) ChatViewController * chatVC;
@property(nonatomic) SPViewController * currentView;

@end
static const int CHATMODETEXT  = 1 ;
static const int CHATMODEVIDEO = 2 ;
static const int CHATMODEAUDIO = 3 ;