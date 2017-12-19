//
//  HelloAuthTVC.h
//  tilechat
//
//  Created by Andrea Sponziello on 19/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HelloAuthTVC.h"
//#import "AlfrescoRepositorySession.h"
#import "SHPApplicationContext.h"
#import "HelloUser.h"
//#import "FirebaseAuth.h"
#import "MBProgressHUD.h"
//#import "AlfrescoUsersDC.h"
#import "SHPAppDelegate.h"
#import "ChatUser.h"
#import "ChatManager.h"
#import "HelloChatUtil.h"
@import Firebase;

@interface HelloAuthTVC () {
    MBProgressHUD *HUD;
}
@end

@implementation HelloAuthTVC

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

- (IBAction)registerAction:(id)sender {
    NSLog(@"Register");
}

-(void)firebaseLogin:(NSString *)email password:(NSString *)password {
    
    SHPApplicationContext *context = [SHPApplicationContext getSharedInstance];
    
    __weak HelloAuthTVC *weakSelf = self;
    
    [HelloChatUtil firebaseAuthEmail:email password:password completion:^(FIRUser *fir_user, NSError *error) {
        [weakSelf hideWaiting];
        if (error) {
            NSLog(@"Firebase auth error: %@", error);
            weakSelf.loginButton.enabled = true;
            [weakSelf hideWaiting];
        }
        else {
            NSLog(@"Firebase auth ok.");
            
            HelloUser *signedUser = [[HelloUser alloc] init];
            signedUser.userid = fir_user.uid;
            signedUser.username = fir_user.email;
            signedUser.email = email;
            signedUser.password = password;
            [context signin:signedUser];
            
            // store user info for next login.
            // REMOVE ON PRODUCTION. HERE UST TO ACCELERATE DEVELOPMENT
            NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
            [userPreferences setObject:password forKey:@"stored_password"];
            [userPreferences setObject:email forKey:@"stored_username"];
            [userPreferences synchronize];
            
            [HelloChatUtil initChat];
            ChatManager *chat = [ChatManager getInstance];
            [chat createContactFor:chat.loggedUser withCompletionBlock:^(NSError *error) {
                if (error) {
                    NSLog(@"Error in contact creation after login. User: %@, Error: %@", chat.loggedUser.fullname, error);
                }
                else {
                    NSLog(@"Successfully created contact: %@", chat.loggedUser.fullname);
                }
            }];
            
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
                [app startPushNotifications];
            }];
        }
    }];
}

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

