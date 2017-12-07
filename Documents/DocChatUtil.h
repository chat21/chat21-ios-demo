//
//  DocChatUtil.h
//  bppmobile
//
//  Created by Andrea Sponziello on 17/10/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface DocChatUtil : NSObject

+(void)initChat;
+(void)firebaseAuthEmail:(NSString *)email password:(NSString *)password completion:(void (^)(FIRUser *fir_user, NSError *))callback;
+(void)firebaseAuth:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))callback;
+(NSString *)firebaseUserID:(NSString *)username;

@end
