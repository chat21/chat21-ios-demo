//
//  HelloAuthTVC.h
//  tilechat
//
//  Created by Andrea Sponziello on 17/10/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HelloChatUtil.h"
#import "ChatUser.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatManager.h"
//#import "FirebaseAuth.h"
#import "ChatUIManager.h"
#import "SHPHomeProfileTVC.h"
#import "ChatMessagesVC.h"

@import Firebase;

@implementation HelloChatUtil

+(void)initChat {
    SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
    ChatUser *loggedUser = [[ChatUser alloc] init];
    loggedUser.userId = app.applicationContext.loggedUser.userid;
    loggedUser.firstname = app.applicationContext.loggedUser.firstName;
    loggedUser.lastname = app.applicationContext.loggedUser.lastName;
    loggedUser.email = app.applicationContext.loggedUser.email;
    ChatManager *chat = [ChatManager getInstance];
    [chat startWithUser:loggedUser];
    [chat createContactFor:loggedUser withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error in contact creation after login. User: %@, Error: %@", loggedUser.fullname, error);
        }
        else {
            NSLog(@"Successfully created contact: %@", loggedUser.fullname);
        }
    }];
    [chat getContactLocalDB:loggedUser.userId withCompletion:^(ChatUser *user) {
        loggedUser.firstname = user.firstname;
        loggedUser.lastname = user.lastname;
        app.applicationContext.loggedUser.firstName = user.firstname;
        app.applicationContext.loggedUser.lastName = user.lastname;
        [app.applicationContext signin:app.applicationContext.loggedUser];
    }];
    // plug the profile view
    [ChatUIManager getInstance].pushProfileCallback = ^(ChatUser *user, ChatMessagesVC *vc) {
        UIStoryboard *profileSB = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        UINavigationController *profileNC = [profileSB instantiateViewControllerWithIdentifier:@"navigationProfile"];
        SHPHomeProfileTVC *profileVC = (SHPHomeProfileTVC *)[[profileNC viewControllers] objectAtIndex:0];
        profileVC.otherUser = user;
        NSLog(@"self.profileVC.otherUser %@ fullname: %@", profileVC.otherUser.userId, profileVC.otherUser.fullname);
        [vc.navigationController pushViewController:profileVC animated:YES];
    };
    // plug the contact selection view
    // plug the create group view
    // plug the groups' list view
    // plug the browser view
    // plug the show image view
}

//+(NSString *)firebaseUserID:(NSString *)username {
//    NSString *normalizedUsername = [username stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//    NSString *firebase_UID = normalizedUsername; //[[NSString alloc] initWithFormat:@"%@-%@", app.tenant, normalizedUsername];
//    return firebase_UID;
//}

+(void)firebaseAuthEmail:(NSString *)email password:(NSString *)password completion:(void (^)(FIRUser *fir_user, NSError *))callback {
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser *user, NSError *error) {
        if (error) {
            NSLog(@"Firebase Auth error for email %@/%@: %@", email, password, error);
            callback(nil, error);
        }
        else {
            NSLog(@"Firebase Auth success. email: %@, emailverified: %d, userid: %@", user.email, user.emailVerified, user.uid);
            callback(user, nil);
        }
//        if (!user.emailVerified) {
//            NSLog(@"Email non verificata. Invio email verifica...");
//                [user sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
//                NSLog(@"Email verifica inviata.");
//        }
    }];
}

//+(void)firebaseAuth:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))callback {
//    FirebaseAuth *auth = [[FirebaseAuth alloc] init];
//    NSString *firebase_UserID = [DocChatUtil firebaseUserID:username];
//    NSLog(@"Creating Custom Token for username: %@", firebase_UserID);
//    [auth generateToken:firebase_UserID password:password completion:^(NSString *token) {
//        NSLog(@"Token received: %@", token);
//        if (!token) {
//            NSLog(@"Token is nil. Firebase Authentication failed.");
//            return;
//        }
//        [[FIRAuth auth] signInWithCustomToken:token completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
//            if (error) {
//                NSLog(@"Firebase signin error: %@", error);
//                callback(error);
//            }
//            else {
//                NSLog(@"Firebase successufully logged in.");
//                SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
//                [app startPushNotifications];
//                [DocChatUtil initChat];
//                callback(nil);
//            }
//        }];
//    }];
//}

@end
