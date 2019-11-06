//
//  HelloSelectUserViewController.m
//  chat21
//
//  Created by Andrea Sponziello on 04/11/2019.
//  Copyright © 2019 Frontiere21. All rights reserved.
//

#import "HelloSelectUserViewController.h"
#import "ChatUser.h"

@interface HelloSelectUserViewController ()

@end

@implementation HelloSelectUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)selectUserAction:(id)sender {
    ChatUser *selectedUser = [[ChatUser alloc] init];
    selectedUser.userId = @"5aaa99024c3b110014b478f0";
    selectedUser.firstname = @"Andrea";
    selectedUser.lastname = @"Leo";
    if (self.completionCallback) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.completionCallback(selectedUser, NO);
        }];
    }
}

- (IBAction)cancelAction:(id)sender {
    if (self.completionCallback) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.completionCallback(nil, YES);
        }];
    }
}


@end
