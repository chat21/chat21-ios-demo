//
//  SHPPushNotification.h
//  Smart21
//
//  Created by Andrea Sponziello on 22/01/15.
//
//

#import <Foundation/Foundation.h>

@interface SHPPushNotification : NSObject

@property(strong, nonatomic) NSString *notificationType;
@property(strong, nonatomic) NSString *message;
@property(strong, nonatomic) NSString *toUser;
@property(strong, nonatomic) NSDictionary *properties;
@property(nonatomic, assign) NSInteger badge;

-(NSString *)propertiesAsJSON;

@end
