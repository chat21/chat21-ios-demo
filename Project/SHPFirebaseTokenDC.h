//
//  SHPFirebaseTokenDC.h
//  Soleto
//
//  Created by Andrea Sponziello on 20/11/14.
//
//

#import <Foundation/Foundation.h>
#import "SHPFirebaseTokenDelegate.h"

@class SHPUser;

@interface SHPFirebaseTokenDC : NSObject

@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (assign, nonatomic) NSInteger statusCode;
@property (assign, nonatomic) id<SHPFirebaseTokenDelegate> delegate;
-(void)getTokenWithParameters:(NSDictionary *)parametersDict withUser:(SHPUser *)__user;

@end
