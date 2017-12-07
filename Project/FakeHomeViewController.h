//
//  FakeHomeViewController.h
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;

@interface FakeHomeViewController : UIViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UITextField *textToSend;
@property (weak, nonatomic) IBOutlet UITextField *userToSend;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendAction:(id)sender;

@end
