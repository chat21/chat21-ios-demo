//
//  FirebaseAuth.m
//  bppmobile
//
//  Created by Andrea Sponziello on 21/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "FirebaseAuth.h"
#import "SHPApplicationContext.h"

@implementation FirebaseAuth

-(void)generateToken:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *))callback {
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString* _username = [username stringByAddingPercentEncodingWithAllowedCharacters:set];
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    NSString *repoAuthURL = app.plistDictionary[@"repoAuthURL"];
    //NSString *__url = [NSString stringWithFormat:@"https://bppmobile.bpp.it/fauth/verifyToken?username=%@", _username];
    NSString *__url = [NSString stringWithFormat:repoAuthURL, _username, password];
    NSLog(@"CUSTOM AUTH URL: %@", __url);
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"firebase auth ERROR: %@", error);
            callback(nil);
        }
        else {
            NSString *token = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"token response: %@", token);
            callback(token);
        }
    }];
    [task resume];
}

@end

