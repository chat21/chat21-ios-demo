//
//  ChatRootNC.h
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@class ChatUser;

@interface ChatRootNC : UINavigationController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (assign, nonatomic) int loggedInConfiguration; // -1 = unset, 1 = chat, 2 = not logged
@property (strong, nonatomic) NSDictionary *chatConfig;
@property (assign, nonatomic) BOOL startupLogin;

-(void)openConversationWithRecipient:(ChatUser *)recipient;
-(void)openConversationWithRecipient:(ChatUser *)recipient sendMessage:(NSString *)message;
-(void)openConversationWithGroup:(NSString *)groupid;
-(void)openConversationWithGroup:(NSString *)groupid sendMessage:(NSString *)message;
-(void)openConversationWithRecipient:(ChatUser *)recipient orGroup:(NSString *)groupid sendMessage:(NSString *)text attributes:(NSDictionary *)attributes;

@end
