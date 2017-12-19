//
//  SHPApplicationContext.m
//  Shopper
//
//  Created by andrea sponziello on 08/08/12.
//
//

#import "SHPApplicationContext.h"
#import "HelloAuth.h"
#import "HelloUser.h"
#import "SHPAppDelegate.h"
#import "ChatConversationHandler.h"
#import "ChatConversationsVC.h"

@implementation SHPApplicationContext

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
    return self.properties;
}

- (void)signout {
    [HelloAuth deleteLoggedUser];
    self.loggedUser = nil;
}

//-(void)unregisterDeviceAndUserFromProvider {
//    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
//    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString *devToken = appDelegate.deviceToken;
//    if (devToken) {
//        [tokenDC removeToken:devToken withUser:self.loggedUser completionHandler:^(NSError *error) {
//            if (!error) {
//                NSLog(@"Successfully UN-Registered DEVICE to Provider FOR USER %@", self.loggedUser);
//                //                appDelegate.registeredToProvider = YES;
//            }
//            else {
//                NSLog(@"Error while registering devToken to Provider!");
//            }
//        }];
//    }
//}

-(void)signin:(HelloUser *)user {
    // save the user
    //KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];
    //pod 'KeychainItemWrapper'
    
    [HelloAuth deleteLoggedUser];
    [HelloAuth saveLoggedUser:user];
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

//-(void)saveOnDiskData {
//    [SHPCaching saveDictionary:self.onDiskData inFile:SHPCONST_LAST_DATA_FILE_NAME];
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

@end

