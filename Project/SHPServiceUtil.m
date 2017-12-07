//
//  SHPStringUtils.m
//  BirdWatching
//
//  Created by andrea sponziello on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPServiceUtil.h"

@implementation SHPServiceUtil

+(NSString *)serviceHost {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
    NSString *tenantName=[configDictionary objectForKey:@"tenantName"];
    NSString *serviceDomain=[configDictionary objectForKey:@"serviceDomain"];
    NSString *serviceHost = [NSString stringWithFormat:@"http://%@.%@", tenantName, serviceDomain];
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    NSString *serviceHost = [thisBundle localizedStringForKey:@"service.host" value:@"KEY NOT FOUND" table:@"services"];
    return serviceHost;
}

+(NSString *)serviceTenant {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
    NSString *serviceHost=[configDictionary objectForKey:@"serviceTenant"];
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    NSString *serviceHost = [thisBundle localizedStringForKey:@"service.tenant" value:@"KEY NOT FOUND" table:@"services"];
    return serviceHost;
}

+(NSString *)serviceCategoriesTenant {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
    NSString *serviceHost=[configDictionary objectForKey:@"serviceCategoriesTenant"];
    
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    NSString *serviceHost = [thisBundle localizedStringForKey:@"service.categories.tenant" value:@"KEY NOT FOUND" table:@"services"];
    return serviceHost;
}

+(NSString *)serviceUrl:(NSString *)serviceName {
    // TODO Refactoring with some sort of singleton?
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
    NSString *tenantName=[configDictionary objectForKey:@"tenantName"];
    NSString *serviceDomain=[configDictionary objectForKey:@"serviceDomain"];
    NSString *serviceHost = [NSString stringWithFormat:@"http://%@.%@", tenantName, serviceDomain];
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    //NSString *serviceHost = [thisBundle localizedStringForKey:@"service.host" value:@"KEY NOT FOUND" table:@"services"];
    NSString *serviceBase = [thisBundle localizedStringForKey:@"service.base" value:@"KEY NOT FOUND" table:@"services"];
    NSString *servicePartialUrl = [thisBundle localizedStringForKey:serviceName value:@"KEY NOT FOUND" table:@"services"];
    NSString *url = nil;
//    if(![serviceName isEqualToString:@"service.images"]) { // TODO remove after image-service will collapse into "/service"
    url = [NSString stringWithFormat:@"%@%@%@", serviceHost, serviceBase, servicePartialUrl];
//    } else {
//        url = [NSString stringWithFormat:@"%@%@", serviceHost, servicePartialUrl];
//    }
    return url;
}

@end
