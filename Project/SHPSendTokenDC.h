//
//  SHPSendTokenDC.h
//  Ciaotrip
//
//  Created by andrea sponziello on 15/01/14.
//
//

#import <Foundation/Foundation.h>

typedef void (^SHPSendTokenDCCompletionHandler)(NSError *error);

@class SHPApplicationContext;
@class SHPUser;

@interface SHPSendTokenDC : NSObject

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, copy) SHPSendTokenDCCompletionHandler completionHandler;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

-(void)sendToken:(NSString *)devToken lang:(NSString *)langID completionHandler:(SHPSendTokenDCCompletionHandler)handler;

-(void)sendToken:(NSString *)devToken withUser:(SHPUser *)user lang:(NSString *)langID completionHandler:(SHPSendTokenDCCompletionHandler)handler;

-(void)removeToken:(NSString *)devToken withUser:(SHPUser *)user completionHandler:(SHPSendTokenDCCompletionHandler)handler;

@end
