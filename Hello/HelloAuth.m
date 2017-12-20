//
//  HelloAuth.m
//
//  Created by andrea sponziello on 10/09/17.
//

#import "HelloAuth.h"
#import "HelloUser.h"
#import "HelloApplicationContext.h"
#import "KeychainItemWrapper.h"

@implementation HelloAuth

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
//        user.username = [userPreferences objectForKey:SIGNED_USER_USERNAME];
        user.firstName = [userPreferences objectForKey:SIGNED_USER_FIRSTNAME];
        user.lastName = [userPreferences objectForKey:SIGNED_USER_LASTNAME];
        user.fullName = [userPreferences objectForKey:SIGNED_USER_FULLNAME];
        user.email = [userPreferences objectForKey:SIGNED_USER_EMAIL];
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
        NSString *password = [wrapper objectForKey:(__bridge NSString *)kSecValueData];
        NSString *username = [wrapper objectForKey:(__bridge NSString *)kSecAttrAccount];
        user.password = password;
        user.username = username;
        return user;
    }
    return nil;
}

+(void)saveLoggedUser:(HelloUser *)user {
    // store user
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    [userPreferences setObject:user.username forKey:SIGNED_USER_USERNAME];
    [userPreferences setObject:user.userid forKey:SIGNED_USER_USERID];
    [userPreferences setObject:user.firstName forKey:SIGNED_USER_FIRSTNAME];
    [userPreferences setObject:user.lastName forKey:SIGNED_USER_LASTNAME];
    [userPreferences setObject:user.fullName forKey:SIGNED_USER_FULLNAME];
    [userPreferences setObject:user.email forKey:SIGNED_USER_EMAIL];
    [userPreferences synchronize];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    [wrapper setObject:user.password forKey:(__bridge NSString *)kSecValueData];
    [wrapper setObject:user.username forKey:(__bridge NSString *)kSecAttrAccount];
}

+(void)deleteLoggedUser {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences removeObjectForKey:SIGNED_USER_USERID];
//    [userPreferences removeObjectForKey:SIGNED_USER_USERNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_FIRSTNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_LASTNAME];
    [userPreferences removeObjectForKey:SIGNED_USER_FULLNAME];
    [userPreferences synchronize];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    [wrapper resetKeychainItem];
}


@end
