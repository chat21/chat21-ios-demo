//
//  ChatTitleVC.m
//  Chat21
//
//  Created by Andrea Sponziello on 20/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatTitleVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"

@implementation ChatTitleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ChatTitleVC loaded.");
//    if(!self.applicationContext){
//        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
//        self.applicationContext = appDelegate.applicationContext;
//    }
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"DEALLOCATING CHAT_TITLE_VC");
}

@end
