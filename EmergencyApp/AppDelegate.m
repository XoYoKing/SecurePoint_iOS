//
//  AppDelegate.m
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientEmergencyController.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "QAConstants.h"
#import "SPMainViewController.h"
#import "Constants.h"
#import "UpdateLocationManager.h"
#import "SVProgressHUD.h"
#import "SoundManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


UIAlertView * alertview;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // push notifications
    [self registerNotifications:application];
    [self temporarlyInitEmergencies];
   // [[UpdateLocationManager sharedInstance:self]startBackGroundUpdate];
    return YES;
}

-(void)registerNotifications:(UIApplication *)application{
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings * mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [application registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // START LOCATION UPDATE
    [[UpdateLocationManager sharedInstance:self]enterBackGround];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[UpdateLocationManager sharedInstance:self]enterForground];
    [[SoundManager sharedManager]stopMusic];

    [SVProgressHUD dismiss];
    
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
        [[ClientEmergencyController sharedInstance] reconnectServer];
        if([SPMainViewController getActiveInstance]){
            [[ClientEmergencyController sharedInstance]updateRegions: (SPLeftMenuViewController *)[SPMainViewController getActiveInstance].leftMenu];
        }
    }
    
    [self clearNotifications];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //[SoundManager sharedManager].allowsBackgroundMusic=true;
    //[[SoundManager sharedManager]playMusic:@"sound2"];

    NSLog(@"%@",[[userInfo objectForKey:@"aps"]valueForKey:@"alert"]);
    
    
    if([[[userInfo objectForKey:@"aps"]valueForKey:@"alert"]isEqualToString:@""]){
        [self clearNotifications];
        [self showLocalNotification];
        NSLog(@"%@",[[userInfo objectForKey:@"aps"]valueForKey:@"alert"]);
        
        if([SPMainViewController getActiveInstance].loginStatus !=LOGGED_NONE){
            [self performSelector:@selector(reconnectServer) withObject:nil];
        }
        return;
    }
    if(alertview){
        [alertview dismissWithClickedButtonIndex:1 animated:NO];
    }
    alertview =[[UIAlertView alloc]initWithTitle:@"Notification" message:[[userInfo objectForKey:@"aps"]valueForKey:@"alert"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    if([SPMainViewController getActiveInstance].loginStatus != LOGGED_OPERATOR && [SPMainViewController getActiveInstance].loginStatus !=LOGGED_NONE){
    [alertview show];
    }


    
}
-(void)showLocalNotification{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.alertBody = @"You have a emergency request to answer!";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
  
    NSLog(@"%@",[[userInfo objectForKey:@"aps"]valueForKey:@"alert"]);
    
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Device token not received : %@",error);
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Device token received: %@", token);
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:token forKey:kDeviceToken];
    [[ClientEmergencyController sharedInstance] sendDeviceTokenAndLocation];
    
}
-(void) temporarlyInitEmergencies{
    ClientEmergencyController * clientEC = [ClientEmergencyController sharedInstance];
    clientEC.serverAddress = BaseURL;
    clientEC.userProfile = @{@"userName":@""};
}
- (void) clearNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

/* APP WATCH HANDLING */
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"secureapp://contact"]];
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if([url host]&& [@"contact" isEqualToString:[url host]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"requireEmergency" object:nil];
    }
   
    NSLog(@"url recieved: %@", url);
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    
    // handle these things in your app here
    
    return YES;
}
@end
