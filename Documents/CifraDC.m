//
//  CifraDC.m
//  mobichat
//
//  Created by Andrea Sponziello on 21/11/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "CifraDC.h"

@implementation CifraDC

-(void)cifraString:(NSString *)stringaDaCifrare completion:(void (^)(NSString *stringaCifrata))callback  {
    // https://wsdecrypting.bpp.it/decrypting.asmx?op=Cifra
    
    NSString *__url = @"https://wsdecrypting.bpp.it/decrypting.asmx?op=Cifra";
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    // basic auth
    [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"http://tempuri.org/Cifra" forHTTPHeaderField:@"SOAPAction"];
    NSString *postString = [[NSString alloc] initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><Cifra xmlns=\"http://tempuri.org/\"><testoInChiaro>%@</testoInChiaro></Cifra></soap:Body></soap:Envelope>", stringaDaCifrare];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Menu response ERROR: %@", error);
            callback(nil);
        }
        else {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"response: %@", response);
//            callback(menu);
        }
    }];
    [task resume];
}

@end
