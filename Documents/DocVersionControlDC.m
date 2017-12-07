//
//  DocVersionControlDC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 21/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocVersionControlDC.h"

@implementation DocVersionControlDC

-(void)getVersionWithCompletion:(void (^)(BOOL newVersionAvailable, NSError *error))callback {
    NSString *__url = @"http://script.smart21.it/bpp/mobile-intranet/version.json";
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
//    // basic auth
//    NSString *authStr = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
//    //NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
//    //NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength]];
//    NSString *encodedCredentials = [[authStr dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
//    NSLog(@"auth string: %@", authStr);
//    NSLog(@"basic auth: %@", encodedCredentials);
//    NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodedCredentials];
//    NSLog(@"authValue: %@", authValue);
//    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Get Version ERROR: %@", error);
            callback(NO, error);
        }
        else {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"response: %@", response);
            NSDictionary *versions = [self jsonToDictionary:data];
            NSLog(@"versions response: %@", versions);
            NSString *ios_version = versions[@"ios"][@"version"];
            NSLog(@"ios version %@", ios_version);
            NSString *ios_build = versions[@"ios"][@"build"];
            NSLog(@"ios build %@", ios_build);
            NSString *fullVersion = [[NSString alloc] initWithFormat:@"%@.%@", ios_version, ios_build];
            NSLog(@"FULL VERSION: %@", fullVersion);
//            fullVersion = @"1.2.1.1.6";
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
            NSString *currentVersion = [[NSString alloc] initWithFormat:@"%@.%@", version, build];
            NSLog(@"CURRENT VERSION: %@", currentVersion);
            
            if ([fullVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                NSLog(@"currentVersion is lower than the requiredVersion");
                return callback(YES, nil);
            }
            else {
                return callback(NO, nil);
            }
        }
    }];
    [task resume];
}

- (NSDictionary *)jsonToDictionary:(NSData *)jsonData {
    // Example response: {"status":"success", "basicAuth":"YWF6ejphYXp6"}
    // NSDictionary *response = [SHPStringUtil parseJSON:jsonString];
    NSError* error;
    NSDictionary *dict = [NSJSONSerialization
                          JSONObjectWithData:jsonData
                          options:kNilOptions
                          error:&error];
    NSLog(@"jsonToUser %@",dict);
    //    NSString *username = [objects valueForKey:@"username"];
    return dict;
}

@end
