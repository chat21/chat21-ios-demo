//
//  DocAuthTVC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 19/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface DocAuthTVC : UITableViewController


//@property (strong, nonatomic) SHPApplicationContext *app;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginAction:(id)sender;

+(void)repositoryReSignin:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))callback;
//+(void)firebaseAuth:(NSString *)username completion:(void (^)(NSError *))callback;
//+(void)initChat;

@end
