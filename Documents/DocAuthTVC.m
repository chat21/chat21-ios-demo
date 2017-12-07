//
//  DocAuthTVC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 19/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocAuthTVC.h"
#import "AlfrescoRepositorySession.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "FirebaseAuth.h"
#import "MBProgressHUD.h"
#import "SHPApplicationContext.h"
#import "AlfrescoUsersDC.h"
#import "SHPAppDelegate.h"
#import "ChatUser.h"
#import "ChatManager.h"
#import "DocChatUtil.h"
@import Firebase;

@interface DocAuthTVC () {
    MBProgressHUD *HUD;
}
@end

@implementation DocAuthTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.app = [SHPApplicationContext getSharedInstance];
    //    [self.app signout];
    [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextLabel addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)textFieldDidChange :(UITextField *) textField {
    NSString *text = textField.text;
    if (textField == self.usernameTextField) {
        //        NSLog(@"UsernameText di change %@", textField.text);
        if (text.length > 0) {
            [self animateView:self.usernameLabel hidden:NO];
            //            self.usernameLabel.hidden = NO;
        } else {
            [self animateView:self.usernameLabel hidden:YES];
            //            self.usernameLabel.hidden = YES;
        }
    }
    
    
    if (textField == self.passwordTextLabel) {
        //        NSLog(@"PasswordText di change %@", textField.text);
        if (text.length > 0) {
            [self animateView:self.passwordLabel hidden:NO];
            //            self.passwordLabel.hidden = NO;
        } else {
            [self animateView:self.passwordLabel hidden:YES];
            //            self.passwordLabel.hidden = YES;
        }
    }
}

-(void)animateView:(UIView *)view hidden:(BOOL)hidden {
    [UIView transitionWithView:view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.hidden = hidden;
                    }
                    completion:NULL];
}

-(void)viewWillAppear:(BOOL)animated {
    self.loginButton.enabled = true;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *stored_username = [userPreferences stringForKey:@"stored_username"];
    NSString *stored_password = [userPreferences stringForKey:@"stored_password"];
    
    NSLog(@"%@ %@", stored_username, stored_password);
    if (![stored_username isEqualToString:@""] && ![stored_password isEqualToString:@""]) {
        self.usernameTextField.text = stored_username;
        self.passwordTextLabel.text = stored_password;
    }
    //    self.usernameTextField.text = @"test.monitoraggio";
    //    self.passwordTextLabel.text = @"123456";
}

-(void)showWaiting:(NSString *)label {
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:HUD];
    }
    HUD.center = self.view.center;
    HUD.labelText = label;
    HUD.animationType = MBProgressHUDAnimationZoom;
    [HUD show:YES];
}

-(void)hideWaiting {
    [HUD hide:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender {
    NSString *email = self.usernameTextField.text;
    NSString *password = self.passwordTextLabel.text;
    
    NSString *trimmed_email= [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmed_password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed_password isEqualToString:@""] || [trimmed_email isEqualToString:@""]) {
        return;
    }
    
    self.loginButton.enabled = false;
    [self showWaiting:@"Autenticazione..."];
    [self firebaseLogin:email password:password];
}

-(void)firebaseLogin:(NSString *)email password:(NSString *)password {
    
    SHPApplicationContext *context = [SHPApplicationContext getSharedInstance];
    
    __weak DocAuthTVC *weakSelf = self;
    
    [DocChatUtil firebaseAuthEmail:email password:password completion:^(FIRUser *fir_user, NSError *error) {
        [weakSelf hideWaiting];
        if (error) {
            NSLog(@"Firebase auth error: %@", error);
            weakSelf.loginButton.enabled = true;
            [weakSelf hideWaiting];
        }
        else {
            NSLog(@"Firebase auth ok.");
            
            SHPUser *signedUser = [[SHPUser alloc] init];
            signedUser.userid = fir_user.uid;
            signedUser.username = fir_user.uid;
            signedUser.email = email;
            signedUser.password = password;
            [context signin:signedUser];
            
            // store user info for next login
            NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
            [userPreferences setObject:password forKey:@"stored_password"];
            [userPreferences setObject:email forKey:@"stored_username"];
            [userPreferences synchronize];
            
            
            [DocChatUtil initChat];
            
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
                [app startPushNotifications];
            }];
        }
    }];
    
//    [AlfrescoRepositorySession connectWithUrl:url username:username password:password
//                              completionBlock:^(id<AlfrescoSession> session, NSError *error) {
//                                  if (nil == session || error)
//                                  {
//                                      NSLog(@"Error connecting to repository: %@", error);
//                                      [weakSelf showAlert:@"Accesso non autorizzato"];
//                                      //                                      [weakSelf.refreshControl endRefreshing];
//                                      weakSelf.loginButton.enabled = true;
//                                      [weakSelf hideWaiting];
//                                  }
//                                  else
//                                  {
//                                      context.docSession = session;
//                                      NSLog(@"Authenticated successfully.");
//
//                                      // get repository info
//                                      context.docInfo = context.docSession.repositoryInfo;
//
//                                      NSLog(@"RepositoryInfo:");
//                                      NSLog(@"%@",context.docInfo.name);
//                                      NSLog(@"%@",context.docInfo.edition);
//                                      NSLog(@"%@",context.docInfo.buildNumber);
//                                      NSLog(@"%@",context.docInfo.version);
//                                      context.docStartFolder = context.docSession.rootFolder;
    
//                                      SHPUser *signedUser = [[SHPUser alloc] init];
//                                      signedUser.username = username;
//                                      signedUser.password = password;
//                                      // store user info for next login
//                                      NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//                                      NSLog(@"*************** SAVE USER: %@ ***************",password);
//                                      [userPreferences setObject:password forKey:@"stored_password"];
//                                      [userPreferences setObject:username forKey:@"stored_username"];
//                                      [userPreferences synchronize];
    
//                                      // recupero le info addizionali dell'utente
//                                      AlfrescoUsersDC *service = [[AlfrescoUsersDC alloc] init];
//                                      [service userById:username completion:^(SHPUser *complete_alfresco_user) {
//                                          NSLog(@"ALFRESCO USER INFO LOADED! %@/%@", complete_alfresco_user, complete_alfresco_user.fullName);
//
//                                          if (complete_alfresco_user) {
//                                              signedUser.fullName = complete_alfresco_user.fullName ? complete_alfresco_user.fullName : @"";
//                                              signedUser.firstName = complete_alfresco_user.firstName ? complete_alfresco_user.firstName : @"";
//                                              signedUser.lastName = complete_alfresco_user.lastName ? complete_alfresco_user.lastName : @"";
//                                              signedUser.email = complete_alfresco_user.email ? complete_alfresco_user.email : @"";
//                                          }
    
//                                          [context signin:signedUser];
//                                          [DocChatUtil firebaseAuth:email password:password completion:^(NSError *error) {
//                                              [weakSelf hideWaiting];
//                                              if (error) {
//                                                  NSLog(@"Firebase auth error: %@", error);
//                                                  weakSelf.loginButton.enabled = true;
//                                                  [weakSelf hideWaiting];
//                                              }
//                                              else {
//                                                  NSLog(@"Firebase auth ok.");
//
//                                                  SHPUser *signedUser = [[SHPUser alloc] init];
//                                                  signedUser.username = email;
//                                                  signedUser.password = password;
//                                                  // store user info for next login
//                                                  NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//                                                  [userPreferences setObject:password forKey:@"stored_password"];
//                                                  [userPreferences setObject:email forKey:@"stored_username"];
//                                                  [userPreferences synchronize];
//                                                  [context signin:signedUser];
//
//                                                  [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//                                              }
//                                          }];
//                                      }];
//                                  }
//                              }];
}

//+(NSString *)firebaseUserID:(NSString *)username {
//    NSString *normalizedUsername = [username stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//    NSString *firebase_UID = normalizedUsername; //[[NSString alloc] initWithFormat:@"%@-%@", app.tenant, normalizedUsername];
//    return firebase_UID;
//}
//
//+(void)firebaseAuth:(NSString *)username completion:(void (^)(NSError *))callback {
//    FirebaseAuth *auth = [[FirebaseAuth alloc] init];
//    NSString *firebase_UserID = [DocAuthTVC firebaseUserID:username];
//    NSLog(@"Creating Custom Token for username: %@", firebase_UserID);
//    [auth generateToken:firebase_UserID completion:^(NSString *token) {
//        NSLog(@"Token received: %@", token);
//        if (!token) {
//            NSLog(@"Token is nil. Firebase Authentication failed.");
//            return;
//        }
//        [[FIRAuth auth] signInWithCustomToken:token completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
//                                       if (error) {
//                                           NSLog(@"Firebase signin error: %@", error);
//                                           callback(error);
//                                       }
//                                       else {
//                                           NSLog(@"Firebase successufully logged in.");
//                                           SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
//                                           [app startPushNotifications];
//                                           [DocAuthTVC initChat];
//                                           callback(nil);
//                                       }
//                                   }];
//    }];
//}

+(void)repositoryReSignin:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))callback {
    SHPApplicationContext *context = [SHPApplicationContext getSharedInstance];
    NSString *host = context.plistDictionary[@"repoURL"];
    NSURL *url = [NSURL URLWithString:host];
    //    [DocAuthTVC initChat];
    [AlfrescoRepositorySession connectWithUrl:url username:username password:password
                              completionBlock:^(id<AlfrescoSession> session, NSError *error) {
                                  if (nil == session || error)
                                  {
                                      callback(error);
                                  }
                                  else
                                  {
                                      context.docSession = session;
                                      NSLog(@"Authenticated successfully.");
                                      // get repository info
                                      context.docInfo = context.docSession.repositoryInfo;
                                      NSLog(@"RepositoryInfo:");
                                      NSLog(@"%@",context.docInfo.name);
                                      NSLog(@"%@",context.docInfo.edition);
                                      NSLog(@"%@",context.docInfo.buildNumber);
                                      NSLog(@"%@",context.docInfo.version);
                                      context.docStartFolder = context.docSession.rootFolder;
                                      
                                      AlfrescoUsersDC *service = [[AlfrescoUsersDC alloc] init];
                                      [service userById:username completion:^(SHPUser *user) {
                                          NSLog(@"ALFRESCO USER DATA (FULL NAME) LOADED!");
                                          if (user && user.fullName) {
                                              context.loggedUser.fullName = user.fullName;
                                          }
                                          else {
                                              context.loggedUser.fullName = @"";
                                          }
                                          callback(nil);
                                      }];
                                      
                                      //                                      FirebaseAuth *auth = [[FirebaseAuth alloc] init];
                                      //                                      NSString *firebase_UID = [DocAuthTVC firebaseUID:username];
                                      //                                      NSLog(@"Creating Custom Token for username: %@", firebase_UID);
                                      //                                      [auth generateToken:firebase_UID completion:^(NSString *token) {
                                      //                                          NSLog(@"Received Token: %@", token);
                                      //                                          [[FIRAuth auth] signInWithCustomToken:token completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                      //                                             if (error) {
                                      //                                                 NSLog(@"Error signin with Firebase: %@", error);
                                      //                                                 callback(error);
                                      //                                             }
                                      //                                             else {
                                      //                                                 NSLog(@"Firebase successufully logged in.");
                                      //                                                 NSLog(@"Registro per notifiche push. Auth.currentUser: %@ User: %@", [FIRAuth auth].currentUser, user);
                                      //                                                 SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
                                      //                                                 [app startPushNotifications];
                                      //                                                 callback(nil);
                                      //                                             }
                                      //                                          }];
                                      //                                      }];
                                      
                                      
                                  }
                              }];
}

//+(void)initChat {
//    SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
//    ChatUser *loggedUser = [[ChatUser alloc] init];
//    loggedUser.userId = [DocAuthTVC firebaseUserID:app.applicationContext.loggedUser.username];//[app.applicationContext.loggedUser.username stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//    loggedUser.firstname = app.applicationContext.loggedUser.firstName;
//    loggedUser.lastname = app.applicationContext.loggedUser.lastName;
//    [[ChatManager getSharedInstance] login:loggedUser];
//    [[ChatManager getSharedInstance] createContactFor:loggedUser withCompletionBlock:^(NSError *error) {
//        if (error) {
//            NSLog(@"Error in contact creation after login. User: %@, Error: %@", loggedUser.fullname, error);
//        }
//        else {
//            NSLog(@"Successfully created contact: %@", loggedUser.fullname);
//        }
//    }];
//}

-(void)showAlert:(NSString *)msg {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"action canceled");
                             }];
    [view addAction:cancel];
    // for ipad
    view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:view animated:YES completion:nil];
}

@end

