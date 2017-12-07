//
//  SHPApplicationContext.m
//  Shopper
//
//  Created by andrea sponziello on 08/08/12.
//
//

#import "SHPApplicationContext.h"
#import "SHPCaching.h"
#import "SHPAuth.h"
#import "SHPUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SHPConstants.h"
#import "SHPSendTokenDC.h"
#import "SHPAppDelegate.h"
//#import "SHPProfileViewController.h"
//#import "SHPNotificationsViewController.h"
//#import "SHPUserMenuViewController.h"
//#import "SHPShop.h"
#import "Firebase/Firebase.h"
#import "ChatConversationHandler.h"
#import "ChatConversationsVC.h"
//#import "SHPSwitchVC.h"

@implementation SHPApplicationContext

@synthesize onDiskLastUsedShops;
@synthesize onDiskLastProductForm;
@synthesize onDiskData;
@synthesize productDetailImageCache;
@synthesize mainListImageCache;
@synthesize smallImagesCache;
@synthesize categoryIconsCache;
@synthesize settings;
@synthesize properties;
@synthesize loggedUser;
@synthesize lastLocation;
@synthesize connectionsController;
@synthesize facebookConnections;
@synthesize objectsCache;
@synthesize backgroundConnections;

static SHPApplicationContext *sharedInstance = nil;

+(SHPApplicationContext *)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        self.properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setVariable:(NSString *)key withValue:(NSObject *)value {
    [self.properties setObject:value forKey:key];
}

-(NSObject *)getVariable:(NSString *)key {
    return [self.properties objectForKey:key];
}

-(void)removeVariable:(NSString *)key {
    [self.properties removeObjectForKey:key];
}

-(NSDictionary *)variablesDictionary {
    return properties;
}

static NSString *LOCATION_LAT_KEY = @"searchLocationLat";
static NSString *LOCATION_LON_KEY = @"searchLocationLon";
static NSString *LOCATION_NAME_KEY = @"searchLocationName";
static NSString *PHONE_KEY = @"lastPhone";
static NSString *EMAIL_KEY = @"lastEmail";
static NSString *PERSISTENT_WIZARD_POI_KEY = @"saved_shop_dictionary";
static NSString *PERSISTENT_WIZARD_POI_OID_KEY = @"wizard_poi_oid";
static NSString *PERSISTENT_WIZARD_POI_NAME_KEY = @"wizard_poi_name";
static NSString *PERSISTENT_WIZARD_POI_ADDRESS_KEY = @"wizard_poi_address";
static NSString *PERSISTENT_WIZARD_POI_SOURCE_KEY = @"wizard_poi_source";
static NSString *PERSISTENT_WIZARD_POI_GOOGLE_PALACES_REFERENCE_KEY = @"wizard_poi_google_places_reference";

+(void)saveSearchLocation:(CLLocation *)location {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    // Store the location
    [userPreferences setDouble:location.coordinate.latitude forKey:LOCATION_LAT_KEY];
    [userPreferences setDouble:location.coordinate.longitude forKey:LOCATION_LON_KEY];
    [userPreferences synchronize];
}

+(CLLocation *)restoreSearchLocation {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees lat = [userPreferences doubleForKey:LOCATION_LAT_KEY];
    CLLocationDegrees lng = [userPreferences doubleForKey:LOCATION_LON_KEY];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    return location;
}

+(void)saveLastPhone:(NSString *)phone {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:phone forKey:PHONE_KEY];
    [userPreferences synchronize];
}

+(void)saveLastEmail:(NSString *)email {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:email forKey:EMAIL_KEY];
    [userPreferences synchronize];
}

+(NSString *)restoreLastPhone {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *phone = (NSString *)[userPreferences objectForKey:PHONE_KEY];
    return phone;
}

+(NSString *)restoreLastEmail {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *email = (NSString *)[userPreferences objectForKey:EMAIL_KEY];
    return email;
}


+(void)saveSearchLocationName:(NSString *)searchLocationName {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:searchLocationName forKey:LOCATION_NAME_KEY];
    [userPreferences synchronize];
    //    NSLog(@"SSSSSSSSSSS ------------ SAVED VALUE: %@", [userPreferences objectForKey:LOCATION_NAME_KEY]);
}

+(NSString *)restoreSearchLocationName {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *name = [userPreferences stringForKey:LOCATION_NAME_KEY];
    //    NSLog(@"TESTING:::::::: %@", name);
    return name;
}

// Removes all persistent info about the static search location
+(void)deleteSearchLocationInfo {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences removeObjectForKey:LOCATION_NAME_KEY];
    [userPreferences removeObjectForKey:LOCATION_LAT_KEY];
    [userPreferences removeObjectForKey:LOCATION_LON_KEY];
}

//+(void)saveLastWizardShop:(SHPShop *)shop {
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//
//    // save the last shop
//    NSMutableDictionary *shop_dictionary = [[NSMutableDictionary alloc] init];
//    [shop_dictionary setObject:shop.oid forKey:PERSISTENT_WIZARD_POI_OID_KEY];
//    [shop_dictionary setObject:shop.name forKey:PERSISTENT_WIZARD_POI_NAME_KEY];
//    [shop_dictionary setObject:shop.formattedAddress forKey:PERSISTENT_WIZARD_POI_ADDRESS_KEY];
//    [shop_dictionary setObject:shop.source forKey:PERSISTENT_WIZARD_POI_SOURCE_KEY];
//    [shop_dictionary setObject:shop.googlePlacesReference forKey:PERSISTENT_WIZARD_POI_GOOGLE_PALACES_REFERENCE_KEY];
//
//    NSLog(@"name %@", [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_SOURCE_KEY]);
//
//    [userPreferences setObject:shop_dictionary forKey:PERSISTENT_WIZARD_POI_KEY];
//    [userPreferences synchronize];
//}

//+(SHPShop *)restoreLastWizardShop {
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *shop_dictionary = [userPreferences objectForKey:PERSISTENT_WIZARD_POI_KEY];
//
//    SHPShop *shop = nil;
//    NSString *shop_oid = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_OID_KEY];
//    if (shop_oid) {
//        shop = [[SHPShop alloc] init];
//        shop.oid = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_OID_KEY];
//        shop.name = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_NAME_KEY];
//        shop.formattedAddress = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_ADDRESS_KEY];
//        shop.source = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_SOURCE_KEY];
//        shop.googlePlacesReference = [shop_dictionary objectForKey:PERSISTENT_WIZARD_POI_GOOGLE_PALACES_REFERENCE_KEY];
//
//        NSLog(@">SHOP OID---------------> %@", shop.oid);
//        NSLog(@">SHOP NAME---------------> %@", shop.name);
//        NSLog(@">SHOP ADDRESS---------------> %@", shop.formattedAddress);
//        NSLog(@">SHOP SOURCE---------------> %@", shop.source);
//        NSLog(@">SHOP GOOGLE REF---------------> %@", shop.googlePlacesReference);
//    }
//    return shop;
//}

//    NSString *stringValue= [userPreferences stringForKey:@"stringKey"];
//    NSLog(@"=============================================");
//    NSLog(@"GOT StringKey %@", stringValue);
//    BOOL boolValue = [userPreferences boolForKey:@"boolKey"];
//    NSLog(@"GOT BoolKey %d", boolValue);
//
//    if (!stringValue) {
//        NSLog(@"NO PREFERENCES. SETTING NOW TEST PREFERENCES.");
//        [userPreferences setBool:YES forKey:@"boolKey"];
//        [userPreferences setObject:@"TESTVALUE" forKey:@"stringKey"];
//    }
//    else {
//        NSLog(@"PREFERENCES ALREADY SET.");
//        NSLog(@"StringKey %@", stringValue);
//        NSLog(@"BoolKey %d", boolValue);
//    }

- (void)signout {
    [SHPAuth deleteLoggedUser];
    self.loggedUser = nil;
}

-(void)unregisterDeviceAndUserFromProvider {
    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *devToken = appDelegate.deviceToken;
    if (devToken) {
        [tokenDC removeToken:devToken withUser:self.loggedUser completionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Successfully UN-Registered DEVICE to Provider FOR USER %@", self.loggedUser);
                //                appDelegate.registeredToProvider = YES;
            }
            else {
                NSLog(@"Error while registering devToken to Provider!");
            }
        }];
    }
}

-(void)signin:(SHPUser *)user {
    // save the user
    //KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];
    //pod 'KeychainItemWrapper'
    
    [SHPAuth deleteLoggedUser];
    [SHPAuth saveLoggedUser:user];
    // update context
    self.loggedUser = user;
    NSLog(@"%@ signed in.", self.loggedUser.username);
}

-(void)setFirstLaunchDone {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:YES forKey:@"first_launch_done"];
    [userPreferences synchronize];
}

-(BOOL)isFirstLaunch {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    BOOL first_launch = [userPreferences boolForKey:@"first_launch_done"];
    NSLog(@"FIRST LAUNCH NSUSERDEFAULTS?? %d", first_launch);
    return !first_launch;
}

-(void)saveOnDiskData {
    [SHPCaching saveDictionary:self.onDiskData inFile:SHPCONST_LAST_DATA_FILE_NAME];
    
    // read/write example:
    //    NSLog(@"Saving last selected category!");
    //    [self.applicationContext.onDiskData setObject:self.selectedCategory forKey:LAST_SELECTED_CATEGORY_KEY];
    //    NSLog(@"selectedCategory %@", [self.applicationContext.onDiskData objectForKey:LAST_SELECTED_CATEGORY_KEY]);
    //    [self.applicationContext saveOnDiskData];
}

//- (void)switchToSignedInTabs {
//    NSLog(@"SWITCH TABBAR LOG-IN");
//    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
////    [controllers removeObjectAtIndex:4];
////    [controllers insertObject:[self getVariable:@"profile-on"] atIndex:4];
//    [controllers removeObjectAtIndex:TAB_NOTIFICATIONS_INDEX];
//    [controllers insertObject:[self getVariable:@"notifications-on"] atIndex:TAB_NOTIFICATIONS_INDEX];
//    //controllers.tabBarItem.title = NSLocalizedString(@"NotificationsLKey", nil);
//    [self.tabBarController setViewControllers:controllers];
//
//    UINavigationController *navController = (UINavigationController *) [self getVariable:@"notifications-on"];
////    SHPNotificationsViewController *notificationController = (SHPNotificationsViewController *) [[navController viewControllers] objectAtIndex:0];
////    [notificationController initialize];
//
//    navController = (UINavigationController *) [controllers objectAtIndex:TAB_MENU_INDEX];
//    NSLog(@"navController %@",navController);
//    NSLog(@"viewControllers %@", [[navController viewControllers] objectAtIndex:0]);
//    SHPUserMenuViewController *userMenuController = (SHPUserMenuViewController *) [[navController viewControllers] objectAtIndex:0];
//    [userMenuController initialize];
//
//    // TODO. must be prerendered before call "initialize". viewDidLoad is called just before display the first time).
////    UINavigationController * notificationsNavController = (UINavigationController *) [self getVariable:@"notifications-on"];
////    SHPNotificationsViewController *notificationsController = (SHPNotificationsViewController *) [[notificationsNavController viewControllers] objectAtIndex:0];
////    [notificationsController initialize];
//
//
//}
//
//- (void)switchToSignedOutTabs {
//    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
////    [controllers removeObjectAtIndex:4];
////    [controllers insertObject:[self getVariable:@"profile-off"] atIndex:4];
//    [controllers removeObjectAtIndex:2];
//    [controllers insertObject:[self getVariable:@"notifications-off"] atIndex:2];
//    [self.tabBarController setViewControllers:controllers];
//
//
//}

//- (void)switchToSignedTabs:(bool)stateLogged {
//    NSLog(@"SWITCH TABBAR LOG-IN-OUT: %d", stateLogged);
//    //LOGOUT
//    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
//    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
//    NSDictionary *creatureDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
//    NSArray *arrayTabbar = [creatureDictionary objectForKey:@"Tabbar"];
//    NSLog(@"creatureDictionary- %@", controllers);
//
//    for (NSDictionary *itemTab in arrayTabbar){
//        NSString *labelTabTag=[NSString stringWithFormat:@"%@",itemTab[@"tag"]];
//        if([self getVariable:labelTabTag]){
//            NSLog(@"carico controller nome:%@ controller:%@ ",labelTabTag, [self getVariable:labelTabTag]);
//            [controllers insertObject:[self getVariable:labelTabTag] atIndex:[itemTab[@"tag"] intValue]-2];
//            [self.properties removeObjectForKey:labelTabTag];
//        }
//    }
//
//    // UITabBarController *tabController=[[UITabBarController alloc]init];
//    //tabController.viewControllers = controllers;
//    self.tabBarController.viewControllers = controllers;
//    UITabBar *tabBar = self.tabBarController.tabBar;
//
//    UIImage *imageSelect;
//    //BOOL stateLogged=YES;
//    int i=0;
//    for(UITabBarItem *tab in tabBar.items) {
//        NSLog(@"tab.tag: %ld item: %@", (long)tab.tag, tab);
//        bool setItem = NO;
//        for (NSDictionary *itemTab in arrayTabbar){
//            if(tab.tag == [itemTab[@"tag"] intValue]){
//                NSLog(@"tab.tag: %ld - itemTab[tag]: %@ logged: %@", (long)tab.tag, itemTab[@"tag"], itemTab[@"stateLogged"]);
//                if(stateLogged==[itemTab[@"stateLogged"] boolValue] || [itemTab[@"stateLogged"] isEqualToString:@""] || itemTab[@"stateLogged"]==nil){
//                    imageSelect = [UIImage imageNamed:itemTab[@"icon"]];
//                    imageSelect = [imageSelect imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//                    tab.title = itemTab[@"title"];
//                    [tab setSelectedImage:imageSelect];
//                    setItem=YES;
//                    break;
//                }
//            }
//        }
//        if(setItem==NO){
//            NSLog(@"rimuovo controller: %d ", i);
//            NSString *labelTabTag=[NSString stringWithFormat:@"%ld",(long)tab.tag];
//            NSLog(@"salvo controller nome:%@ controller:%@ ",labelTabTag, [controllers objectAtIndex:i]);
//            [self setVariable:labelTabTag withValue:[controllers objectAtIndex:i]];
//            [controllers removeObjectAtIndex:i];
//            i--;
//        }
//        i++;
//    }
//    [self.tabBarController setViewControllers:controllers];
//    //[tabController setViewControllers:controllers];
//    NSLog(@"tabController: %@ ", controllers);
//
//
//}

+(int)tabIndexByName:(NSString *)tab_name {
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    SHPApplicationContext *context = appDelegate.applicationContext;
    NSDictionary *tabBarDictionary = [context.plistDictionary objectForKey:@"TabBar"];
    NSArray *tabBarMenuItems = [tabBarDictionary objectForKey:@"Menu"];
    
    int tab_index = -1;
    int index = 0;
    for (NSDictionary *tabBarConfig in tabBarMenuItems) {
        NSString *StoryboardControllerID = [tabBarConfig objectForKey:@"StoryboardControllerID"];
        if ([StoryboardControllerID isEqualToString:tab_name]) {
            //NSLog(@"ChatController found!");
            tab_index = index;
            break;
        }
        index++;
    }
    // move to the converstations tab
    return tab_index;
}

//+(void)openConversationViewWith:(NSString *)userid context:(SHPApplicationContext *)context {
//    int messages_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:context];
//
//    NSLog(@"--messages_tab_index %d", messages_tab_index);
//    // move to the converstations tab
//    if (messages_tab_index >= 0) {
//        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
//        NSArray *controllers = [tabController viewControllers];
//        UINavigationController *nc = [controllers objectAtIndex:messages_tab_index];
//
//        SHPSwitchVC *switchVC = [[nc viewControllers] objectAtIndex:0];
//        NSLog(@"..switchVC %@", switchVC);
////        switchVC.selectedRecipient = userid;
//        tabController.selectedIndex = messages_tab_index;
//        [switchVC popToRootVCAndSelectRecipient:userid];
//    }
//}


@end

