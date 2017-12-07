//
//  SHPUser.h
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import <Foundation/Foundation.h>

@interface SHPUser : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *facebookAccessToken;
@property (strong, nonatomic) NSString *httpBase64Auth;

+(NSString *)photoUrlByUsername:(NSString *)username;
-(NSString *)photoUrl;
-(NSString *)displayName;

@end
