//
//  SHPSigninServiceDC.h
//  Shopper
//
//  Created by andrea sponziello on 16/09/12.
//
//

#import <Foundation/Foundation.h>
//#import "SHPSigninServiceDCDelegate.h"

@class SHPUser;

@protocol SHPSigninServiceDCDelegate <NSObject>

@required
-(void)signinServiceDCSignedIn:(SHPUser *)user error:(NSError *) error;

@end

@interface SHPSigninServiceDC : NSObject

@property (nonatomic, assign) id <SHPSigninServiceDCDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
//@property (nonatomic, strong) NSString *serviceUrl;
//@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) SHPUser *user;

-(void)signinWith:(SHPUser *)_user andPassword:(NSString *)password;

@end
