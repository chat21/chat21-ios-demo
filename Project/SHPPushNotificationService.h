//
//  SHPPushNotificationService.h
//  Smart21
//
//  Created by Andrea Sponziello on 22/01/15.
//
//

#import <Foundation/Foundation.h>

@class SHPPushNotification;
@class SHPUser;

typedef void (^SHPNotificationHandler)(SHPPushNotification *notification, NSError *error);

@interface SHPPushNotificationService : NSObject

@property (nonatomic, strong) SHPPushNotification *notification;
@property (nonatomic, copy) SHPNotificationHandler handler;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) long statusCode;

-(void)sendNotification:(SHPPushNotification *)notification completionHandler:(SHPNotificationHandler)handler withUser:(SHPUser *)user;
/*
 [service sendNotification: @"http://..." completionHandler: ^(SHPNotification *notification, NSError *error) {
    if (!error) {
        NSLog(@"Notification successfully sent.");
    }
 }
 */


@end
