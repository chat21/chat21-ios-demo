//
//  ChatParsePushService.m
//  Chat21
//
//  Created by Andrea Sponziello on 12/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "ChatParsePushService.h"
#import "ParseChatNotification.h"
//#import <Parse/Parse.h>

@implementation ChatParsePushService

-(void)sendNotification:(ParseChatNotification *)notification {
    NSLog(@"Sending notification: %@", notification);
    NSLog(@"Sending notification sender: %@", notification.senderUser);
    NSLog(@"Sending notification sender fullname: %@", notification.senderUserFullname);
    NSLog(@"Sending notification to user: %@", notification.toUser);
    NSLog(@"Sending notification alert: %@", notification.alert);
    NSLog(@"Sending notification badge: %@", notification.badge);
    NSLog(@"Sending notification convId: %@", notification.conversationId);
    NSString *_badge = notification.badge; // [NSString stringWithFormat: @"%ld", (long)notification.badge];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:notification.senderUser forKey:@"sender"];
    [parameters setObject:notification.toUser forKey:@"to"];
    [parameters setObject:notification.alert forKey:@"alert"];
    [parameters setObject:_badge forKey:@"badge"];
    [parameters setObject:notification.conversationId forKey:@"conversationId"];
    [parameters setObject:@"chat" forKey:@"type"];
    
    if (notification.senderUserFullname) {
        [parameters setObject:notification.senderUserFullname forKey:@"senderFullname"];
    }
    
//    [PFCloud callFunctionInBackground:@"messagesent"
//                       withParameters:parameters
//                                block:^(NSArray *results, NSError *error) {
//                                    if (!error) {
//                                        // update ui with "notification sent" (as FB Messanger)
//                                        NSLog(@"results: %@", results);
//                                    } else {
//                                        NSLog(@"error %@", error);
//                                    }
//                                }
//     ];
}

@end
