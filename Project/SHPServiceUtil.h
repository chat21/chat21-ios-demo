//
//  SHPStringUtils.h
//  BirdWatching
//
//  Created by andrea sponziello on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPServiceUtil : NSObject

+(NSString *)serviceTenant;
+(NSString *)serviceCategoriesTenant;
+(NSString *)serviceHost;
+(NSString *)serviceUrl:(NSString *)serviceName;

@end
