//
//  SHPAuthServiceDCDelegate.h
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import <Foundation/Foundation.h>

@class SHPUser;

@protocol SHPAuthServiceDCDelegate <NSObject>

@optional
-(void)authServiceDCFacebookUser:(SHPUser *)user found:(BOOL)found;
-(void)authServiceDCUser:(SHPUser *)user signedin:(BOOL)signedin;
-(void)authServiceDCUser:(SHPUser*)user registered:(BOOL)registered;

@required
-(void)authServiceDCErrorWithCode:(NSString *)code;

@end
