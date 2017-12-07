//
//  SHPFirebaseTokenDC.m
//  Soleto
//
//  Created by Andrea Sponziello on 20/11/14.
//
//

#import "SHPFirebaseTokenDC.h"
#import "SHPUser.h"
#import "SHPStringUtil.h"
#import "SHPServiceUtil.h"

@implementation SHPFirebaseTokenDC

-(void)getTokenWithParameters:(NSDictionary *)parametersDict withUser:(SHPUser *)__user {
     //NSLog(@"parametersDict = %@",parametersDict);
    if (!__user) {
        NSLog(@"ERROR: (Firebase) getTokenWithParameters with user = nil!");
        return;
    }
    
    NSString *queryString = @"";
    BOOL firstParam = YES;
    if (parametersDict) {
        for(id key in parametersDict) {
            NSLog(@"key=%@ value=%@", key, [parametersDict objectForKey:key]);
            NSString *keyValuePair = [[NSString alloc] initWithFormat:@"%@%@", [SHPStringUtil urlParamEncode:key], [SHPStringUtil urlParamEncode:[parametersDict objectForKey:key]]];
            if (firstParam) {
                keyValuePair = [keyValuePair initWithFormat:@"?%@", keyValuePair];
            } else {
                keyValuePair = [keyValuePair initWithFormat:@"&%@", keyValuePair];
            }
            queryString = [queryString stringByAppendingString:keyValuePair];
            firstParam = NO;
        }
    }
    
    // Create the request.
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.firebaseToken"];
    
    NSLog(@"serviceUrl: %@", serviceUrl);
    
    NSString *_url = serviceUrl;
    NSLog(@"FIREBASE TOKEN URL: %@", _url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"Operation with User %@", __user.username);
    NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
    [request setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    // log header's fields
    //        NSDictionary* headers = [request allHTTPHeaderFields];
    //        for (NSString *key in headers) {
    //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
    //        }
    
    
    NSString *postString = queryString;
    NSLog(@"POST Query: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.currentConnection = conn;
    if (conn) {
        self.receivedData = [[NSMutableData alloc] init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

- (void)cancelConnection {
    [self.currentConnection cancel];
    self.currentConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// CONNECTION DELEGATE

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    //    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //    for (NSString *key in headers) {
    //        NSLog(@"field: %@ value: %@", key, [headers objectForKey:key]);
    //    }
    int code = (int) [(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.delegate) {
        [self.delegate didFinishFirebaseAuthWithToken:nil error:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    
    //NSString* text;
    //text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding]; //NSUTF8StringEncoding];
    
    NSLog(@"Response: %@", responseString);
    
    if (self.statusCode >= 400 && self.statusCode <500) {
        NSLog(@"HTTP Error %d", (int) self.statusCode);
        NSString *code_s = [[NSString alloc] initWithFormat:@"Network error while getting token. HTTP STATUS CODE: %d", (int) self.statusCode];
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: code_s};
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        
        if (self.delegate) {
            [self.delegate didFinishFirebaseAuthWithToken:nil error:theError];
        }
        return;
    }
    if (self.delegate) {
        [self.delegate didFinishFirebaseAuthWithToken:responseString error:nil];
    }
}

@end
