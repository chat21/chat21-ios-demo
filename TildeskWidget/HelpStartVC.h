//
//  HelpStartVC.h
//  chat21
//
//  Created by Andrea Sponziello on 05/06/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HelpDepartment;
@class HelpAction;

@interface HelpStartVC : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) HelpAction *helpAction;
//@property (strong, nonatomic) NSMutableDictionary *context;
@property (strong, nonatomic) NSArray<HelpDepartment *> *departments;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
- (IBAction)cancelAction:(id)sender;
//@property (nonatomic, copy) void (^pushProfileCallback)(ChatUser *user, ChatMessagesVC *vc);

@end
