//
//  AlfrescoUsersDC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 24/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SHPUser;
@class AlfrescoRequest;

@interface AlfrescoUsersDC : NSObject

-(AlfrescoRequest *)usersByText:(NSString *)text completion:(void (^)(NSArray<SHPUser *> *))callback;
-(AlfrescoRequest *)userById:(NSString *)userId completion:(void (^)(SHPUser *))callback;

@end
