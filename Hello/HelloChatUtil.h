//
//  HelloAuthTVC.h
//  tilechat
//
//  Created by Andrea Sponziello on 17/10/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@class ChatUser;

@interface HelloChatUtil : NSObject

+(void)initChat;
+(void)firebaseAuthEmail:(NSString *)email password:(NSString *)password completion:(void (^)(FIRUser *fir_user, NSError *))callback;
+(NSInteger)chatTabBarIndex;
//+(void)moveToConversationViewWithUser:(ChatUser *)user;
//+(void)moveToConversationViewWithUser:(ChatUser *)user sendMessage:(NSString *)message;
//+(void)moveToConversationViewWithGroup:(NSString *)groupid;
//+(void)moveToConversationViewWithGroup:(NSString *)groupid sendMessage:(NSString *)message;
//+(void)moveToConversationViewWithUser:(ChatUser *)user orGroup:(NSString *)groupid sendMessage:(NSString *)message attributes:(NSDictionary *)attributes;

@end
