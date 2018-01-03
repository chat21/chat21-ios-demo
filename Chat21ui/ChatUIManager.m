//
//  ChatUIManager.m
//  tilechat
//
//  Created by Andrea Sponziello on 06/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "ChatUIManager.h"
#import "ChatConversationsVC.h"

static ChatUIManager *sharedInstance = nil;

@implementation ChatUIManager

+(ChatUIManager *)getInstance {
    if (!sharedInstance) {
        sharedInstance = [[ChatUIManager alloc] init];
    }
    return sharedInstance;
}

-(void)openConversationsViewAsModal:(UIViewController *)vc withCompletionBlock:(void (^)())completionBlock {
    UINavigationController * nc = [self conversationViewController];
    ChatConversationsVC *conversationsVc = (ChatConversationsVC *)[[nc viewControllers] objectAtIndex:0];
    conversationsVc.isModal = YES;
    conversationsVc.dismissModalCallback = completionBlock;
    [vc presentViewController:nc animated:YES completion:^{
        //
    }];
}

-(UINavigationController *)conversationViewController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    UINavigationController *chatNC = [sb instantiateViewControllerWithIdentifier:@"ChatNavigationController"];
    return chatNC;
}

@end
