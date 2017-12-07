//
//  NotConnectedVC.h
//  Chat21
//
//  Created by Andrea Sponziello on 30/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface NotConnectedVC : UIViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

- (IBAction)actionLogin:(id)sender;

@end
