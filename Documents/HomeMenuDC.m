//
//  HomeMenuDC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 15/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HomeMenuDC.h"
#import "SHPUser.h"
#import "NSData+Additions.h"

@implementation HomeMenuDC


-(void)getMenuMap:(SHPUser *)user completion:(void (^)(NSDictionary *menu))callback  {
    // https://bppmobile.bpp.it/wsappintranetpre/me/applicazioni.map
//    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    
    NSString *__url = @"https://bppmobile.bpp.it/wsappintranetpre/me/applicazioni.map";
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    // basic auth
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
    //NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    //NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    NSString *encodedCredentials = [[authStr dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
    NSLog(@"auth string: %@", authStr);
    NSLog(@"basic auth: %@", encodedCredentials);
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodedCredentials];
    NSLog(@"authValue: %@", authValue);
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Menu response ERROR: %@", error);
            callback(nil);
        }
        else {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"response: %@", response);
            NSDictionary *menu = [self jsonToDictionary:data];
            NSLog(@"menu response: %@", menu);
            callback(menu);
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
