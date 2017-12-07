//
//  DocProfileTVC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 19/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocProfileTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)logoutAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
- (IBAction)helpAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableViewCell *helpCell;

@end

