//
//  ChatUIManager.h
//  tilechat
//
//  Created by Andrea Sponziello on 06/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatUser;
@class ChatMessagesVC;

@interface ChatUIManager : NSObject

@property (nonatomic, copy) void (^pushProfileCallback)(ChatUser *user, ChatMessagesVC *vc);

+(ChatUIManager *)getInstance;
-(void)openConversationsViewAsModal:(UIViewController *)vc withCompletionBlock:(void (^)())completionBlock;
-(void)openConversationMessagesViewAsModalWith:(ChatUser *)recipient viewController:(UIViewController *)vc withCompletionBlock:(void (^)())completionBlock;
-(UINavigationController *)conversationsViewController;
-(UINavigationController *)messagesViewController;

@end
