//
//  SHPAuth.m
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import "SHPAuth.h"
#import "HelloUser.h"
#import "SHPApplicationContext.h"

@implementation SHPAuth

static NSString *SIGNED_USER_USERNAME = @"username";
static NSString *SIGNED_USER_USERID = @"userid";
static NSString *SIGNED_USER_PASSWORD = @"password";
static NSString *SIGNED_USER_FIRSTNAME = @"firstname";
static NSString *SIGNED_USER_LASTNAME = @"lastname";
static NSString *SIGNED_USER_FULLNAME = @"fullname";
static NSString *SIGNED_USER_EMAIL = @"email";

+(HelloUser *)restoreSavedUser {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    HelloUser *user = [[HelloUser alloc] init];
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
}

+(void)saveLoggedUser:(HelloUser *)user {
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
}


@end
