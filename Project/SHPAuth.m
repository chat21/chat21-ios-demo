//
//  SHPAuth.m
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import "SHPAuth.h"
#import "SHPUser.h"
#import "SHPCaching.h"
#import "SHPApplicationContext.h"

@implementation SHPAuth

static NSString *SIGNED_USER_USERNAME = @"username";
static NSString *SIGNED_USER_USERID = @"userid";
static NSString *SIGNED_USER_PASSWORD = @"password";
static NSString *SIGNED_USER_FIRSTNAME = @"firstname";
static NSString *SIGNED_USER_LASTNAME = @"lastname";
static NSString *SIGNED_USER_FULLNAME = @"fullname";
static NSString *SIGNED_USER_EMAIL = @"email";

+(SHPUser *)restoreSavedUser {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    SHPUser *user = [[SHPUser alloc] init];
    NSString *userid = [userPreferences objectForKey:SIGNED_USER_USERID];
    if (userid) {
        user.userid = userid;
        user.username = [userPreferences objectForKey:SIGNED_USER_USERNAME];
        user.password = [userPreferences objectForKey:SIGNED_USER_PASSWORD];
        user.firstName = [userPreferences objectForKey:SIGNED_USER_FIRSTNAME];
        user.lastName = [userPreferences objectForKey:SIGNED_USER_LASTNAME];
        user.fullName = [userPreferences objectForKey:SIGNED_USER_FULLNAME];
        user.email = [userPreferences objectForKey:SIGNED_USER_EMAIL];
        return user;
    }
    
    return nil;
    
//    NSMutableDictionary *userDict = [SHPCaching restoreDictionaryFromFile:USER_LOGGED_FILE];
//    if (userDict) {
//        SHPUser *user = [userDict objectForKey:USER_LOGGED_KEY];
//        return user;
//    }
//    return nil;
}

+(void)saveLoggedUser:(SHPUser *)user {
    // store user
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:user.username forKey:SIGNED_USER_USERNAME];
    [userPreferences setObject:user.userid forKey:SIGNED_USER_USERID];
    [userPreferences setObject:user.password forKey:SIGNED_USER_PASSWORD];
    [userPreferences setObject:user.firstName forKey:SIGNED_USER_FIRSTNAME];
    [userPreferences setObject:user.lastName forKey:SIGNED_USER_LASTNAME];
    [userPreferences setObject:user.fullName forKey:SIGNED_USER_FULLNAME];
    [userPreferences setObject:user.email forKey:SIGNED_USER_EMAIL];
    [userPreferences synchronize];
    
//    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
//    [userDict setObject:user forKey:USER_LOGGED_KEY];
//    [SHPCaching saveDictionary:userDict inFile:USER_LOGGED_FILE];
}

+(void)deleteLoggedUser {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences removeObjectForKey:SIGNED_USER_PASSWORD];
    [userPreferences removeObjectForKey:SIGNED_USER_USERID];
    [userPreferences removeObjectForKey:SIGNED_USER_USERNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_FIRSTNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_LASTNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_FULLNAME];
    [userPreferences synchronize];
//    [SHPCaching deleteFile:USER_LOGGED_FILE];
}

//+(void)signout:(SHPApplicationContext *)applicationContext {
//    applicationContext.loggedUser = nil;
//    [SHPCaching deleteFile:USER_LOGGED_FILE];
//    
//}

@end
