//
//  HelloAuth.h
//
//  Created by andrea sponziello on 10/09/17.
//

#import <Foundation/Foundation.h>

@class SHPApplicationContext;
@class HelloUser;

@interface HelloAuth : NSObject

+(HelloUser *)restoreSavedUser;
+(void)saveLoggedUser:(HelloUser *)user;
+(void)deleteLoggedUser;

@end
