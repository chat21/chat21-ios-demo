//
//  HelloAppDelegate.m
//
//  Created by andrea sponziello on 24/05/17.
//

#import "HelloAppDelegate.h"
#import "HelloApplicationContext.h"
#import "SHPCaching.h"
#import "HelloUser.h"
#import "HelloAuth.h"
#import "ChatManager.h"
#import "ChatUtil.h"
#import "ChatConversationsVC.h"
#import "ChatUtil.h"
#import "HelloAuthTVC.h"
#import "ChatContactsSynchronizer.h"
#import "ChatUser.h"
#import "HelloChatUtil.h"
#import "ChatUIManager.h"

#import <sys/utsname.h>
@import Firebase;

@implementation HelloAppDelegate

static NSString *NOTIFICATION_TYPE_KEY = @"t"; //type
static NSString *NOTIFICATION_TYPE_CHAT_KEY = @"chat";


static NSString *NOTIFICATION_ALERT_KEY = @"alert";
static NSString *NOTIFICATION_CATEGORY_KEY = @"category";
static NSString *NOTIFICATION_APS_KEY = @"aps";
static NSString *NOTIFICATION_BADGE_KEY = @"badge";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions...");
    
    HelloApplicationContext *context = [HelloApplicationContext getSharedInstance];
    self.applicationContext = context;
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    self.applicationContext.plistDictionary=plistDictionary;
        
    // chat config
    NSString *tenant = [plistDictionary objectForKey:@"chat-app-id"];
//    NSString *tenant = [settings_config objectForKey:@"tenantName"];
//    self.applicationContext.tenant = tenant;
    [self initUser];
    NSLog(@"SAVED LOGGED USER: %@", self.applicationContext.loggedUser);
    
    NSLog(@"initialize chat on tenant: %@", tenant);
    [FIRApp configure];
//    [ChatManager configureWithAppId:tenant]; // user:loggedUser];
    [ChatManager configure];
    // initial chat signin
    if ((context.loggedUser)) {
        [HelloChatUtil initChat]; // initialize logged user so I can get chat-history from DB, regardless of a real Firebase successfull authentication/connection
        // always authenticates on firebase
        [HelloChatUtil firebaseAuthEmail:context.loggedUser.email password:context.loggedUser.password completion:^(FIRUser *fir_user, NSError *error) {
            if (error) {
                NSLog(@"Firebase authentication error. %@", error);
            }
            else {
                NSLog(@"Firebase authentication success.");
            }
        }];
    }
    
//    [self buildTabBar];
//    [self configTabBar];
//
    // adding chat controller
    int chat_tab_index = 1; //[HelloApplicationContext tabIndexByName:@"ChatController"];
    
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSMutableArray *controllers = [[tabController viewControllers] mutableCopy];
        UINavigationController *conversationsNC = [[ChatUIManager getInstance] conversationsViewController];
        controllers[1] = conversationsNC;
        [tabController setViewControllers:controllers];
        ChatConversationsVC *conversationsVC = conversationsNC.viewControllers[0];
        [conversationsVC loadViewIfNeeded];
        
        // setting icon & name of the chat's tabbar item
        UITabBar *tabBar = tabController.tabBar;
        UITabBarItem *tabChat = tabBar.items[chat_tab_index];
//        UITabBarItem *tab in tabBar.items
        [tabChat setImage:[[UIImage imageNamed:@"ic_linear_chat"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
        [tabChat setSelectedImage:[[UIImage imageNamed:@"ic_linear_chat"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
        tabChat.title = @"Chat";
    } else {
        NSLog(@"ChatController doesn't exist.");
    }
    
    // #notificationworkflow
    
    // Get remote push notifications on application startup
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"REMOTE NOTIFICATION STARTED THE APPLICATION!");
        [HelloChatUtil initChat];
        [self processRemoteNotification:userInfo];
    }
    
    // the chat app only asks notification permission when user is logged in
    if (self.applicationContext.loggedUser) {
        [self startPushNotifications];
    }
    
    return YES;
}

//-(void)testFirebase {
//
//    // TEST SCRITTURA FIREBASE
//    FIRDatabaseReference *_ref1 = [[FIRDatabase database] reference];
//    [[_ref1 child:@"apps/mobichat/users/andrea_leo/messages/A"] setValue:@{@"testo": @"successo scrittura"} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//        if (error) {
//            NSLog(@"Error saving testo: %@", error);
//        }
//        else {
//            NSLog(@"testo SAVED!");
//        }
//    }];
//
////    [[FIRAuth auth] createUserWithEmail:@"andrea.sponziello@frontiere21.it"
////                               password:@"123456"
////                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
////                                 NSLog(@"Utente creato: andrea.sponziello@gmail.com/pallino");
////                             }];
////
////    [[FIRAuth auth] signInWithEmail:@"andrea.sponziello@frontiere21.it"
////                           password:@"123456"
////                         completion:^(FIRUser *user, NSError *error) {
////                             NSLog(@"Autenticato: %@ - %@/emailverified: %d", error, user.email, user.emailVerified);
////                             if (!user.emailVerified) {
////                                 NSLog(@"Email non verificata. Invio email verifica...");
////                                 [user sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
////                                     NSLog(@"Email verifica inviata.");
////                                 }];
////                             }
////                             // TEST CONNECTION
////                             FIRDatabaseReference *_ref = [[FIRDatabase database] reference];
////                             //                             FIRUser *currentUser = [FIRAuth auth].currentUser;
////                             [[_ref child:@"yesmister3"] setValue:@"andrea" withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
////
////                                 NSLog(@"completato! %@", ref);
////
////                             }];
////
////                             [[_ref child:@"test"] setValue:@{@"username": @"Lampatu"}];
////                             [[_ref child:@"test2"] setValue:@{@"valore": @"Andrea"}];
////                             [[_ref child:@"NADAL"] setValue:@{@"Vince": @"Wimbledon"}];
////
////                             [[_ref child:@"test"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
////                                 NSLog(@"snapshot: %@", snapshot);
////                             } withCancelBlock:^(NSError * _Nonnull error) {
////                                 NSLog(@"error: %@", error.localizedDescription);
////                             }];
////
////                             [[_ref child:@"test10"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
////                                 NSLog(@"snapshot: %@", snapshot);
////                             } withCancelBlock:^(NSError * _Nonnull error) {
////                                 NSLog(@"error: %@", error.localizedDescription);
////                             }];
////
////                             [[_ref child:@"yesmister"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
////                                 NSLog(@"snapshot: %@", snapshot);
////                             } withCancelBlock:^(NSError * _Nonnull error) {
////                                 NSLog(@"error: %@", error.localizedDescription);
////                             }];
////
////                         }];
////
////    [[FIRAuth auth]
////     addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
////         NSLog(@"Firebase autenticatooooo! auth: %@ user: %@", auth, user);
////     }];
//}


-(ChatUser *)chatUserBy:(HelloUser *)hello_user {
    if (!hello_user) {
        return nil;
    }
    ChatUser *user = [[ChatUser alloc] init];
    user.userId = hello_user.username;
    user.fullname = hello_user.fullName;
    user.email = hello_user.email;
//    user.password = hello_user.password;
    return user;
}


-(void)startPushNotifications {
    
    // SE DA ATTIVARE ALLA PARTENZA COMMENTARE QUESTO CODICE
    //    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    //    NSString *advice = [userPreferences objectForKey:@"PUSH_ADVICE_SHOWN"];
    //    if (advice == nil) {
    //        return;
    //    }
    
    // START NOTIFICATION
    // ORIGINALE < IOS9
    //    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
    //                                                    UIUserNotificationTypeBadge |
    //                                                    UIUserNotificationTypeSound);
    //    UIUserNotificationSettings *user_settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
    //                                                                                  categories:nil];
    //    [application registerUserNotificationSettings:user_settings];
    //    [application registerForRemoteNotifications];
    
    // DA FIREBASE TUTORIAL
    // https://firebase.google.com/docs/cloud-messaging/ios/client
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
}

// #notificationsworkflow
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"REMOTE NOTIFICATION. didReceiveRemoteNotification: %@", userInfo);
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    NSLog(@"APPLICATION DID RECEIVE REMOTE NOTIFICATION IN STATE: %ld", state);
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        NSLog(@"APPLICATION WAS RUNNING IN BACKGROUND!");
        [self processRemoteNotification:userInfo];
    }
    else {
        NSLog(@"APPLICATION IS RUNNING IN FOREGROUND! IGNORED.");
    }
}

// #notificationsworkflow
-(void)processRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"REMOTE NOTIFICATION: %@", userInfo);
    NSDictionary *aps = [userInfo objectForKey:NOTIFICATION_APS_KEY];
    NSLog(@"aps: %@", aps);
    NSString *alert = [aps objectForKey:NOTIFICATION_ALERT_KEY];
    NSLog(@"alert: %@", alert);
    NSString *category = [aps objectForKey:NOTIFICATION_CATEGORY_KEY];
    NSLog(@"category: %@", category);
    
    if ([category isEqualToString:@"OPEN_MESSAGE_LIST_ACTIVITY"]) {
        NSString *senderid = [userInfo objectForKey:@"sender"];
        NSString *sender_fullname = [userInfo objectForKey:@"sender_fullname"];
        NSString *groupid = [userInfo objectForKey:@"group_id"];
//        NSString *conversationid = [userInfo objectForKey:@"conversationId"];
        NSString *badge = [[userInfo objectForKey:NOTIFICATION_APS_KEY] objectForKey:NOTIFICATION_BADGE_KEY];
        NSLog(@"==>Sender: %@", senderid);
//        NSLog(@"==>ConversationId: %@", conversationid);
        NSLog(@"==>Badge: %@", badge);
        NSLog(@"==>group_id: %@", groupid);
        
        if (groupid) {
//            [DocChatUtil firebaseAuth:self.applicationContext.loggedUser.username password:self.applicationContext.loggedUser.password completion:^(NSError *error) {
                [ChatUIManager moveToConversationViewWithGroup:groupid];
//            }];
        }
        else {
            NSString *trimmedSender = [senderid stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceCharacterSet]];
            if (trimmedSender.length > 0) {
                // DIRECT
                ChatUser *user = [[ChatUser alloc] init];
                user.userId = senderid;
                user.fullname = sender_fullname;
                [ChatUIManager moveToConversationViewWithUser:user];
            }
        }
    }
}

// #notificationsworkflow
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSLog(@"Application successfully registered to APN with devToken %@", devToken);
    //    [[FIRInstanceID instanceID] setAPNSToken:devToken type:FIRMessagingAPNSTokenTypeProd];
    //    NSString *FCMToken = [FIRMessaging messaging].FCMToken;
    //    NSLog(@"[FIRMessaging messaging].FCMToken: %@", [FIRMessaging messaging].FCMToken);
    //    NSString *FCMToken = [FIRInstanceID instanceID].token;
    NSString *FCMToken = [FIRMessaging messaging].FCMToken;
    NSLog(@"FCMToken: %@", FCMToken);
    [FIRMessaging messaging].APNSToken = devToken;
    NSLog(@"[FIRMessaging messaging].APNSToken: %@", [FIRMessaging messaging].APNSToken);
    ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
    if (loggedUser) {
        NSString *user_path = [ChatUtil userPath:loggedUser.userId];
        NSLog(@"Writing instanceId (FCMToken) %@ on path: %@", FCMToken, user_path);
        [[[[[FIRDatabase database] reference] child:user_path] child:@"instanceId"] setValue:FCMToken withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Error saving instanceId (FCMToken) on user_path %@: %@", error, user_path);
            }
            else {
                NSLog(@"instanceId (FCMToken) %@ saved", FCMToken);
            }
        }];
    }
    else {
        NSLog(@"No user is signed in for push notifications token.");
    }
}

// #notificationsworkflow
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@">>>>>>> Error in APN registration: %@", err);
}

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    //    [self connectToFcm];
    
    // TODO: If necessary send token to appliation server.
}
// [END refresh_token]

//-(void)buildTabBar {
//    NSLog(@"Building tabbar...");
//    NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"TabBar"];
//    NSArray *tabBarMenuItems = [tabBarDictionary objectForKey:@"Menu"];
//    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
//    // Adding tabbar controllers (using StoryboardID)
//    NSMutableArray *controllers = [[NSMutableArray alloc] init];
//    UIStoryboard *storyboard;// = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
//    UIViewController *vc = [[UIViewController alloc] init];
//    for (NSDictionary *tabBarConfig in tabBarMenuItems) {
//        NSString *StoryboardControllerID = [tabBarConfig objectForKey:@"StoryboardControllerID"];
//        NSString *sbname = [tabBarConfig objectForKey:@"StoryboardName"];
//        NSLog(@"found storyboard: %@", sbname);
//        if(sbname) {
//            storyboard = [UIStoryboard storyboardWithName:sbname bundle: nil];
//        }
//        else {
//            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
//        }
//        vc = [storyboard instantiateViewControllerWithIdentifier:StoryboardControllerID];
//        NSLog(@"Adding controller %@:%@", StoryboardControllerID, vc);
//        [controllers addObject:vc];
//    }
//    [tabController setViewControllers:controllers];
//
//    // configuring tabbar buttons
//    UITabBar *tabBar = tabController.tabBar;
//    int i=0;
//    for(UITabBarItem *tab in tabBar.items) {
//        NSDictionary *tabBarItemConfig = [tabBarMenuItems objectAtIndex:i];
//        //        NSLog(@"tabBarItemConfig %@, %@", tabBarItemConfig[@"title"], tabBarItemConfig[@"StoryboardControllerID"]);
//        NSString *title = tabBarItemConfig[@"title"];
//        tab.title = NSLocalizedString(title, nil);
//        //        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaLTStd-Roman" size:10.0f], NSFontAttributeName,  [UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
//
//        [tab setImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];//UIImageRenderingModeAlwaysOriginal
//        [tab setSelectedImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
//        //UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
//        i++;
//    }
//}

//-(void)configTabBar {
//    //----------------------------------------------------------------------------//
//    //CONFIG TABBAR
//    //----------------------------------------------------------------------------//
//    // http://stackoverflow.com/questions/18795117/change-tab-bar-tint-color-ios-7
//    //http://www.appcoda.com/ios-programming-how-to-customize-tab-bar-background-appearance/
//
//    if ([[UITabBar class] respondsToSelector:@selector(appearance)]) {
//        NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"TabBar"];
//        UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
//        [[UITabBar appearance] setTintColor: tintColor]; //set button active
//
//        UIColor *barTintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"barTintColor"]];
//        [[UITabBar appearance] setBarTintColor:barTintColor]; //set background tabbar
//        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : tintColor }
//                                                 forState:UIControlStateSelected];
//    }
//}

//-(NSDictionary *)checkItemTabTagIn:(NSArray *)arrayTabbar itemTabTag:(int)tag{
//    for (NSDictionary *itemTab in arrayTabbar){
//        if(tag == [itemTab[@"tag"] intValue]){
//            return itemTab;
//        }
//    }
//    return nil;
//}

// #notificationworkflow
//-(void)sendDeviceTokenToProvider:(NSString *)devToken {
//    NSLog(@"Registering Token to Provider");
//    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    if (self.applicationContext.loggedUser) {
//        [tokenDC sendToken:devToken withUser:self.applicationContext.loggedUser lang:langID completionHandler:^(NSError *error) {
//            if (!error) {
//                NSLog(@"Successfully registered DEVICE to Provider WITH USER.");
//                //                self.registeredToProvider = YES;
//            }
//            else {
//                NSLog(@"Error while registering devToken to Provider!");
//                // If there is an error in registration it is not a big issue.
//                // This method is always called every time the application goes in background
//                // and newly became active (see: ApplicationDidBecomeActive)
//            }
//        }];
//    }
//    else {
//        [tokenDC sendToken:devToken lang:langID completionHandler:^(NSError *error) {
//            if (!error) {
//                NSLog(@"Successfully registered DEVICE to Provider WITHOUT USER.");
//                //                self.registeredToProvider = YES;
//            }
//            else {
//                NSLog(@"Error while registering devToken to Provider!");
//            }
//        }];
//    }
//
//}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"Tab selected.");
}

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    NSLog(@"VIEW CONTROLLER: %@", viewController);
//    NSLog(@"SELECTED VIEW CONTROLLER:%@", tabBarController.selectedViewController);
//    NSLog(@"SELECTED INDEX: %d", (int)tabBarController.selectedIndex);
//
//    //return viewController != tabBarController.selectedViewController;
//    if(TAB_NOTIFICATIONS_INDEX>=0){
//        UIViewController *notificationsViewController = [tabBarController.viewControllers objectAtIndex:TAB_NOTIFICATIONS_INDEX];
//        if ( (viewController == notificationsViewController) &&  (viewController == tabBarController.selectedViewController) ) {
//            return false;
//        }
//    }
//    return true;
//}

-(void)initUser {
    HelloUser *user = [HelloAuth restoreSavedUser];
    if (user) {
        self.applicationContext.loggedUser = user;
    } else {
        self.applicationContext.loggedUser = nil;
    }
}

// **** APP DELEGATES ****

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"App >> applicationWillResignActive...");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App >> applicationDidEnterBackground...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"App >> applicationWillEnterForeground...");
    //    NSLog(@"notifications are active? %d", [self checkPushNotificationsActive]);
    //    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"App >> applicationDidBecomeActive...");
    application.applicationIconBadgeNumber = 0;
    
    if (self.applicationContext.loggedUser) {
        NSLog(@"Registering for remote notifications...");
        [application registerForRemoteNotifications];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"App >> applicationWillTerminate...");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"App >> applicationDidReceiveMemoryWarning. Caches empting...");
}

//-(BOOL)application:(UIApplication *)application
//           openURL:(NSURL *)url
// sourceApplication:(NSString *)sourceApplication
//        annotation:(id)annotation{
//    NSLog(@"AppDelegate openURL");
//    //    if ([[DBSession sharedSession] handleOpenURL:url]) {
//    //        if ([[DBSession sharedSession] isLinked]) {
//    //            NSLog(@"App linked successfully!");
//    //            // At this point you can start making API calls
//    //        }
//    //        return YES;
//    //    }
//    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
//        // This was a Chooser response and handleOpenURL automatically ran the
//        // completion block
//        NSLog(@"DBChooser openURL");
//        return YES;
//    }
//    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
//}

@end