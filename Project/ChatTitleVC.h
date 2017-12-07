//
//  ChatTitleVC.h
//  Chat21
//
//  Created by Andrea Sponziello on 20/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface ChatTitleVC : UIViewController

//@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
