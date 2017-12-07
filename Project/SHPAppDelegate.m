//
//  SHPAppDelegate.m
//  Shopper
//
//  Created by andrea sponziello on 24/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPApplicationSettings.h"
#import "SHPCaching.h"
#import "SHPConstants.h"
#import "SHPUser.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "SHPAuth.h"
#import "SHPConnectionsController.h"
#import "SHPObjectCache.h"
#import "SHPStringUtil.h"
#import "SHPSendTokenDC.h"
#import "MBProgressHUD.h"
#import "SHPImageUtil.h"
#import "ChatManager.h"
#import "ChatUtil.h"
#import "ChatConversationsVC.h"
#import "ChatRootNC.h"
#import "ChatUtil.h"
#import <DropboxSDK/DropboxSDK.h>
#import <DBChooser/DBChooser.h>
#import <UserNotifications/UserNotifications.h>
#import "DocAuthTVC.h"
#import "ChatContactsSynchronizer.h"
#import "ChatUser.h"
#import "DocChatUtil.h"

#import <sys/utsname.h>
@import Firebase;

@implementation SHPAppDelegate

NSString *const BFTaskMultipleExceptionsException = @"BFMultipleExceptionsException";

@synthesize window = _window;
@synthesize applicationContext;

static NSString *NOTIFICATION_TYPE_KEY = @"t"; //type
static NSString *NOTIFICATION_TYPE_CHAT_KEY = @"chat";


static NSString *NOTIFICATION_ALERT_KEY = @"alert";
static NSString *NOTIFICATION_CATEGORY_KEY = @"category";
static NSString *NOTIFICATION_APS_KEY = @"aps";
static NSString *NOTIFICATION_BADGE_KEY = @"badge";

//int TAB_NOTIFICATIONS_INDEX;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Initializing...");
    
    SHPApplicationContext *context = [SHPApplicationContext getSharedInstance];
    self.applicationContext = context;
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    self.applicationContext.plistDictionary=plistDictionary;
    
    // Dropbox config
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"shde1onequju17t"
                            appSecret:@"088r90aufcja66q"
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
//    [FBLoginView class];
//    [FBProfilePictureView class];
    
    // chat config
    // ChatManager *chat = [ChatManager getSharedInstance];
    NSDictionary *settings_config = [plistDictionary objectForKey:@"Config"];
    NSString *tenant = [settings_config objectForKey:@"tenantName"];
    self.applicationContext.tenant = tenant;
    [self initUser];
    NSLog(@"SAVED LOGGED USER: %@", self.applicationContext.loggedUser);
    
    NSLog(@"initialize chat on tenant: %@", tenant);
    [FIRApp configure];
    [ChatManager configureWithAppId:tenant]; // user:loggedUser];
//    [ChatManager configure];
//    [ChatManager getSharedInstance].groupsMode = YES;
    // end chat config
    // initial chat signin
    if ((context.loggedUser)) {
        [DocChatUtil initChat]; // initialize logged user so I can get chat-history from DB, regardless of a real Firebase successfull authentication/connection
        
//        // updates user's email and password
//        [DocChatUtil firebaseAuth:context.loggedUser.username password:context.loggedUser.password completion:^(NSError *error) {
//            NSLog(@"Successfully Firebase signedin on didiFinishWithOptions.");
//            // updates user password
//            [[FIRAuth auth].currentUser updatePassword:@"123456" completion:^(NSError * _Nullable error) {
//                NSLog(@"password updated. error: %@", error);
//            }];
//        }];
//        // updates user email
//        [[FIRAuth auth].currentUser updateEmail:@"walter.cavalcante@mobilesoft.it" completion:^(NSError *_Nullable error) {
//            NSLog(@"updated email. error: %@", error);
//        }];
        
        // initial document auth
//        [DocAuthTVC repositoryReSignin:context.loggedUser.username password:context.loggedUser.password completion:^(NSError *error) {
//            if (error) {
//                NSLog(@"Error connecting to repository: %@", error);
//            }
//            else {
//                NSLog(@"Successfully connected to repository");
//            }
//        }];
//        [self startPushNotifications];
    }
    
    //    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Settings"];
    //    if([settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"]){
    //        TAB_NOTIFICATIONS_INDEX = [[settingsDictionary valueForKey:@"TAB_NOTIFICATIONS_INDEX"] intValue];
    //    } else {
    //        TAB_NOTIFICATIONS_INDEX = -1;
    //    }
    
    //    SHPImageCache *smallImagesCache = [[SHPImageCache alloc] init];
    //    smallImagesCache.maxSize = self.applicationContext.settings.smallImagesCacheSize;
    //    context.smallImagesCache = smallImagesCache;
    
//    SHPConnectionsController *connectionsController = [[SHPConnectionsController alloc] init];
//    self.applicationContext.connectionsController = connectionsController;
    
    
    //    if (![context isFirstLaunch]) {
    //    }
//    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
//    self.applicationContext.tabBarController = tabController;
    
    [self buildTabBar];
    [self configTabBar];
    
    // preloading chat controllers
    NSLog(@"Preloading ChatRootNC");
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController"];
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        [nc loadViewIfNeeded]; // preload navigation controller
        [nc.topViewController loadViewIfNeeded]; // preload conversations' view
        NSLog(@"ChatRootNC loaded.");
    } else {
        NSLog(@"ChatRootNC does'n exist.");
    }
    
    // #notificationworkflow
    
    // Get remote push notifications on application startup
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"REMOTE NOTIFICATION STARTED THE APPLICATION!");
        [DocChatUtil initChat];
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


-(ChatUser *)chatUserBy:(SHPUser *)shp_user {
    if (!shp_user) {
        return nil;
    }
    ChatUser *user = [[ChatUser alloc] init];
    user.userId = shp_user.username;
    user.fullname = shp_user.fullName;
    user.email = shp_user.email;
    user.password = shp_user.password;
    return user;
}

//-(BOOL) checkPushNotificationsActive {


//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
//                                                                                         | UIUserNotificationTypeBadge
//                                                                                         | UIUserNotificationTypeSound) categories:nil];
//    if (settings.types & UIUserNotificationTypeAlert) {
//        return YES;
//    }
//    return NO;


//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//    {
//        return ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
//    }
//    else
//    {
//        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//        return (types & UIRemoteNotificationTypeAlert);
//    }

//}


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
    
    if ([category isEqualToString:@"OPEN_MESSAGE_LIST_ACTIVITY"]) {
        NSString *senderid = [userInfo objectForKey:@"sender"];
        NSString *sender_fullname = [userInfo objectForKey:@"sender_fullname"];
        NSString *groupid = [userInfo objectForKey:@"group_id"];
        NSString *conversationid = [userInfo objectForKey:@"conversationId"];
        NSString *badge = [[userInfo objectForKey:NOTIFICATION_APS_KEY] objectForKey:NOTIFICATION_BADGE_KEY];
        NSLog(@"==>Sender: %@", senderid);
        NSLog(@"==>ConversationId: %@", conversationid);
        NSLog(@"==>Badge: %@", badge);
        NSLog(@"==>group_id: %@", groupid);
        
        if (groupid) {
//            [DocChatUtil firebaseAuth:self.applicationContext.loggedUser.username password:self.applicationContext.loggedUser.password completion:^(NSError *error) {
                [ChatUtil moveToConversationViewWithGroup:groupid];
//            }];
        }
        else {
            NSString *trimmedSender = [senderid stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceCharacterSet]];
            if (trimmedSender.length > 0) {
                // DIRECT
                ChatUser *recipient = [[ChatUser alloc] init];
                recipient.userId = senderid;
                recipient.fullname = sender_fullname;
                [ChatUtil moveToConversationViewWithRecipient:recipient];
            }
        }
    }
}

//-(void)TESTloadGroupTEST:(NSString *)group_id try:(NSInteger)tryCount {
//    [DocChatUtil firebaseAuth:self.applicationContext.loggedUser.username password:self.applicationContext.loggedUser.password completion:^(NSError *error) {
//        NSLog(@"Successfully Firebase signedin on didiFinishWithOptions.");
//        FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
//        NSString *groups_path = [ChatUtil groupsPath];
//        NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", groups_path, group_id];
//        NSLog(@"Load Group on path: %@", path);
//        FIRDatabaseReference *groupRef = [rootRef child:path];
//        NSLog(@"groupRef = %@", groupRef);
//        //        [[groupRef child:@"ATTONICOTTO-PRIMO-SCRITTO"] setValue:@"PAPERO" withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//        //            NSLog(@"DATA OK! error: %@, ref: %@", error, ref);
//
//        [groupRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//            NSLog(@"NEW GROUP SNAPSHOT::: %@ refStatic: %@", snapshot, groupRef);
//            if (snapshot.value == [NSNull null]) {
//                NSLog(@"group snapshot null.");
//                if (tryCount == 1) {
//                    NSLog(@"Trying second time.");
//                    [self TESTloadGroupTEST:group_id try:2];
//                }
//                else {
//                    NSLog(@"Second load also failed. Error loading group.");
//                }
//            }
//            else {
//                NSLog(@"group successfully loaded. %@", snapshot);
//            }
//        } withCancelBlock:^(NSError *error) {
//            NSLog(@"%@", error.description);
//        }];
//        //        }];
//    }];
//}

//-(void)TESTloadGroupTEST2:(NSString *)group_id {
//    [DocChatUtil firebaseAuth:self.applicationContext.loggedUser.username password:self.applicationContext.loggedUser.password completion:^(NSError *error) {
//        NSLog(@"Successfully Firebase signedin on didiFinishWithOptions.");
//        FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
//        NSString *groups_path = [ChatUtil groupsPath];
//        NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", groups_path, group_id];
//        NSLog(@"Load Group on path: %@", path);
//        path = @"/apps/bppintranet/users/andrea_sponziello/groups/-KygHDFpdmWY-pUU9RWW";
//        FIRDatabaseReference *groupRef = [rootRef child:path];
//        NSLog(@"groupRef = %@", groupRef);
////        [[groupRef child:@"ATTONICOTTO-PRIMO-SCRITTO"] setValue:@"PAPERO" withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
////            NSLog(@"DATA OK! error: %@, ref: %@", error, ref);
//            [groupRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//                NSLog(@"NEW GROUP SNAPSHOT: -Kyg9MjuhYVn_qszgVrA >>> %@ refStatic: %@", snapshot, groupRef);
//                if (snapshot.value == [NSNull null]) {
//                    NSLog(@"snapshot2 is null!");
//                }
//                [self TESTloadGroupTEST:group_id];
//            } withCancelBlock:^(NSError *error) {
//                NSLog(@"%@", error.description);
//            }];
////        }];
//    }];
//}

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

// [START connect_to_fcm]
//- (void)connectToFcm {
//    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Unable to connect to FCM. %@", error);
//        } else {
//            NSLog(@"Connected to FCM.");
//        }
//    }];
//}
// [END connect_to_fcm]

//// REMOVE
//-(void)downloadLoggedUserData {
//    // REMOVE
//    NSLog(@"Loading Logged User Data...");
//}

-(void)buildTabBar {
    NSLog(@"Building tabbar...");
    NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"TabBar"];
    NSArray *tabBarMenuItems = [tabBarDictionary objectForKey:@"Menu"];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    // Adding tabbar controllers (using StoryboardID)
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    UIStoryboard *storyboard;// = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [[UIViewController alloc] init];
    for (NSDictionary *tabBarConfig in tabBarMenuItems) {
        NSString *StoryboardControllerID = [tabBarConfig objectForKey:@"StoryboardControllerID"];
        NSString *sbname = [tabBarConfig objectForKey:@"StoryboardName"];
        NSLog(@"found storyboard: %@", sbname);
        if(sbname){
            storyboard = [UIStoryboard storyboardWithName:sbname bundle: nil];
        }
        else{
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        }
        vc = [storyboard instantiateViewControllerWithIdentifier:StoryboardControllerID];
        NSLog(@"Adding controller %@:%@", StoryboardControllerID, vc);
        [controllers addObject:vc];
    }
    [tabController setViewControllers:controllers];
    
    // configuring tabbar buttons
    UITabBar *tabBar = tabController.tabBar;
    int i=0;
    for(UITabBarItem *tab in tabBar.items) {
        NSDictionary *tabBarItemConfig = [tabBarMenuItems objectAtIndex:i];
        //        NSLog(@"tabBarItemConfig %@, %@", tabBarItemConfig[@"title"], tabBarItemConfig[@"StoryboardControllerID"]);
        NSString *title = tabBarItemConfig[@"title"];
        tab.title = NSLocalizedString(title, nil);
        //        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaLTStd-Roman" size:10.0f], NSFontAttributeName,  [UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        
        [tab setImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];//UIImageRenderingModeAlwaysOriginal
        [tab setSelectedImage:[[UIImage imageNamed:tabBarItemConfig[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
        //UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
        i++;
    }
}

-(void)configTabBar{
    //----------------------------------------------------------------------------//
    //CONFIG TABBAR
    //----------------------------------------------------------------------------//
    // http://stackoverflow.com/questions/18795117/change-tab-bar-tint-color-ios-7
    //http://www.appcoda.com/ios-programming-how-to-customize-tab-bar-background-appearance/
    
    if ([[UITabBar class] respondsToSelector:@selector(appearance)]) {
        NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"TabBar"];
        UIColor *tintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"tintColor"]];
        [[UITabBar appearance] setTintColor: tintColor]; //set button active
        //[[UITabBar appearance] setSelectedImageTintColor:tintColor];
        
        UIColor *barTintColor = [SHPImageUtil colorWithHexString:[tabBarDictionary valueForKey:@"barTintColor"]];
        [[UITabBar appearance] setBarTintColor:barTintColor]; //set background tabbar
        
        
        // [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
        //                                        forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : tintColor }
                                                 forState:UIControlStateSelected];
        //[[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
        //                                                            NSForegroundColorAttributeName : [UIColor redColor]
        //                                                            } forState:UIControlStateNormal];
    }
}

-(NSDictionary *)checkItemTabTagIn:(NSArray *)arrayTabbar itemTabTag:(int)tag{
    for (NSDictionary *itemTab in arrayTabbar){
        if(tag == [itemTab[@"tag"] intValue]){
            return itemTab;
        }
    }
    return nil;
}

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
    SHPUser *user = [SHPAuth restoreSavedUser];
    if (user) {
        self.applicationContext.loggedUser = user;
        //        NSString *userKey = [[NSString alloc] initWithFormat:@"usrKey-%@", self.applicationContext.loggedUser.username];
        //        NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:userKey];
        //        user.email = [userData objectForKey:@"email"];
        //        user.fullName = [userData objectForKey:@"fullName"];
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
    
    // http://stackoverflow.com/questions/4443817/how-to-know-when-a-uiviewcontroller-view-is-shown-after-being-in-the-background
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navc = (UINavigationController *)[tabController selectedViewController];
    UIViewController *topvc = [navc topViewController];
    if ([topvc respondsToSelector:@selector(viewControllerDidBecomeActive)]) {
        [topvc performSelector:@selector(viewControllerDidBecomeActive)];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"App >> applicationWillTerminate...");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"App >> applicationDidReceiveMemoryWarning. Caches empting...");
    [self.applicationContext.productDetailImageCache empty];
    [self.applicationContext.mainListImageCache empty];
    [self.applicationContext.smallImagesCache empty];
    [self.applicationContext.categoryIconsCache empty];
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
