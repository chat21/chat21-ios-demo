//
//  SHPAuth.h
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import <Foundation/Foundation.h>

@class SHPApplicationContext;
@class SHPUser;

@interface SHPAuth : NSObject

+(SHPUser *)restoreSavedUser;
+(void)saveLoggedUser:(SHPUser *)user;
+(void)deleteLoggedUser;
//+(void)signout:(SHPApplicationContext *)applicationContext;

@end
