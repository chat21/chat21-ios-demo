//
//  FakeHomeViewController.m
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "FakeHomeViewController.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "ChatConversationsVC.h"
#import "ChatRootNC.h"
#import "ChatUtil.h"

@interface FakeHomeViewController ()

@end

@implementation FakeHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"APPCONTEXT %@", self.applicationContext);
//    NSString *startupSelectedRecipient = (NSString *)[self.applicationContext getVariable:@"startupSelectedRecipient"];
//    NSLog(@"startupSelectedRecipient: %@", startupSelectedRecipient);
//    if (startupSelectedRecipient) {
//        [self moveToChatTab];
//    }
}

-(void)moveToChatTab {
    int messages_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController"];
    NSLog(@"_-messages_tab_index %d", messages_tab_index);
    // move to the converstations tab
    if (messages_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        tabController.selectedIndex = messages_tab_index;
    } else {
        NSLog(@"No Chat Tab configured");
    }
}

-(void)sendMessage:(NSString *)message toUser:(NSString *)user {
//    [ChatUtil moveToConversationViewWithUser:user orGroup:nil sendMessage:message];
//    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
//    // move to the converstations tab
//    if (chat_tab_index >= 0) {
//        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
//        NSArray *controllers = [tabController viewControllers];
//        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
//        [nc popToRootViewControllerAnimated:NO];
//        [nc openConversationWithRecipient:user sendText:message];
//        tabController.selectedIndex = chat_tab_index;
//    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendAction:(id)sender {
    NSString *text = self.textToSend.text;
    NSString *user = self.userToSend.text;
    [self sendMessage:text toUser:user];
}

@end
