//
//  SHPModifyProfileTVC.h
//  Mercatino
//
//  Created by Dario De Pascalis on 26/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"

@class SHPApplicationContext;
@class SHPUser;
@class MBProgressHUD;

@interface SHPModifyProfileTVC : UITableViewController {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, assign) NSInteger statusCode;

@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) NSString *modifyType;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *changed_password;
@property (nonatomic, strong) NSString *old_password;

@property (weak, nonatomic) IBOutlet UILabel *labelHeaderMessage;
@property (weak, nonatomic) IBOutlet UITextField *textFullName;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveName;
@property (weak, nonatomic) IBOutlet UITextField *textPasswordOld;

@property (weak, nonatomic) IBOutlet UITextField *textPasswordNew;
@property (weak, nonatomic) IBOutlet UITextField *textPasswordNewConfirm;
@property (weak, nonatomic) IBOutlet UIButton *buttonSavePassword;
- (IBAction)actionSavePassword:(id)sender;
- (IBAction)actionSaveFullName:(id)sender;

@end
