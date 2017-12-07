//
//  ChatSettingsTVC.h
//  Chat21
//
//  Created by Andrea Sponziello on 30/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface ChatSettingsTVC : UITableViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeFullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *changePasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

- (IBAction)unwindToChatSettingsTVC:(UIStoryboardSegue*)sender;

@end
