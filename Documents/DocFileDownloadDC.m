//
//  DocFileDownloadDC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 01/10/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocFileDownloadDC.h"

@implementation DocFileDownloadDC

- (void)downloadFile:(NSString*)name from:(NSString*)stringURL in:(NSString*)path username:(NSString *)username password:(NSString *)password {
    NSURLSessionConfiguration *_config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    _config.HTTPAdditionalHeaders = @{@"Authorization": self.token};
    NSURLSession *_session = [NSURLSession sessionWithConfiguration:_config];
    
    NSURL *url = [NSURL URLWithString:stringURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    if (username && ![username isEqualToString:@""] && password && ![password isEqualToString:@""]) {
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
        NSLog(@"basicAuthCredentials: %@", basicAuthCredentials);
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(basicAuthCredentials)];
        NSLog(@"authValue: %@", authValue);
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        if (data) {
            
            // Your file writing code here
            NSLog(@"%@", data);
        }
    }];
    
    [task resume];
}

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@end
