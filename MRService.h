//
//  MRService.h
//  misterlupo
//
//  Created by Andrea Sponziello on 08/10/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPApplicationContext;
@class SHPUser;

@interface MRService : NSObject

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

-(void)sendCV:(NSDictionary *)cv completion:(void (^)(NSDictionary *))callback;
-(void)sendSearchRequest:(NSDictionary *)request completion:(void (^)(NSDictionary *))callback;
-(void)subscribeToJobSearching:(NSString *)userid lat:(NSString *)lat lon:(NSString *)lon category:(NSString *)category completion:(void (^)(NSDictionary *))callback;
-(void)queryProfessionalsInCategory:(NSString *)category lat:(NSString *)lat lon:(NSString *)lon completion:(void (^)(NSDictionary *))callback;

@end
