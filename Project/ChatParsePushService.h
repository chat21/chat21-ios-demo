//
//  ChatParsePushService.h
//  Chat21
//
//  Created by Andrea Sponziello on 12/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParseChatNotification;

//typedef void (^ParseChatNotificationHandler)(ParseChatNotification *notification, NSError *error);

@interface ChatParsePushService : NSObject

@property (nonatomic, strong) ParseChatNotification *notification;
//@property (nonatomic, copy) ParseChatNotificationHandler handler;

-(void)sendNotification:(ParseChatNotification *)notification;

@end
