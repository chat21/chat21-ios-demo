//
//  SHPAuthServiceDC.h
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPAuthServiceDCDelegate.h"

@class SHPUser;

@interface SHPAuthServiceDC : NSObject

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) id <SHPAuthServiceDCDelegate> authServiceDelegate;
@property (nonatomic, strong) NSString *serviceUrl;
@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) SHPUser *user;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

-(void)findFacebookUser:(SHPUser *)user;
-(void)cancelConnection;

@end
