//
//  HelloApplicationContext.m
//
//  Created by andrea sponziello on 08/08/17.
//
//

#import "HelloApplicationContext.h"
#import "HelloAuth.h"
#import "HelloUser.h"
#import "HelloAppDelegate.h"
#import "ChatConversationHandler.h"
#import "ChatConversationsVC.h"

@implementation HelloApplicationContext

static HelloApplicationContext *sharedInstance = nil;

+(HelloApplicationContext *)getSharedInstance {
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
    HelloAppDelegate *appDelegate = (HelloAppDelegate *)[[UIApplication sharedApplication] delegate];
    HelloApplicationContext *context = appDelegate.applicationContext;
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

