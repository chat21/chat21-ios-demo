//
//  SHPSendTokenDC.m
//  Ciaotrip
//
//  Created by andrea sponziello on 15/01/14.
//
//

#import "SHPSendTokenDC.h"
#import "SHPUser.h"
#import "SHPServiceUtil.h"

@implementation SHPSendTokenDC

- (void)sendToken:(NSString *)devToken lang:(NSString *)langID completionHandler:(SHPSendTokenDCCompletionHandler)handler {
    
    self.completionHandler = handler;
    
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.notifications.registerdevice"];
    
    NSString *__url = [NSString stringWithFormat:@"%@?source=%@&regId=%@&lang=%@", serviceUrl, @"ios", devToken, langID];
    //    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"token send url: %@", __url);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    // eventually cancel the current running connection
    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    // create the connection with the request
    // and start loading the data
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connecion failed!");
        NSError *error = [[NSError alloc] init];
        [self connectionFailed:error];
    }
}

- (void)sendToken:(NSString *)devToken withUser:(SHPUser *)__user lang:(NSString *)langID completionHandler:(SHPSendTokenDCCompletionHandler)handler {
    
    self.completionHandler = handler;
    
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.notifications.register"];
    
//    NSString *username;
//    if (__user) {
//        username = [__user.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    else {
//        username = @"";
//    }
    
    NSString *__url = [NSString stringWithFormat:@"%@?source=%@&regId=%@&lang=%@", serviceUrl, @"ios", devToken, langID];
//    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"token send url: %@", __url);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        //        NSLog(@"NO USER");
    }
    
    // eventually cancel the current running connection
    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    // create the connection with the request
    // and start loading the data
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connecion failed!");
        NSError *error = [[NSError alloc] init];
        [self connectionFailed:error];
    }
}

- (void)removeToken:(NSString *)devToken withUser:(SHPUser *)__user completionHandler:(SHPSendTokenDCCompletionHandler)handler {
    
    self.completionHandler = handler;
    
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.notifications.unregister"];
    
    NSString *__url = [NSString stringWithFormat:@"%@?source=%@&regId=%@", serviceUrl, @"ios", devToken];
    //    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"token send url: %@", __url);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
        //        NSLog(@"NO USER");
    }
    
    // eventually cancel the current running connection
    if(self.theConnection != nil) {
        [self.theConnection cancel];
    }
    // create the connection with the request
    // and start loading the data
    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connecion failed!");
        NSError *error = [[NSError alloc] init];
        [self connectionFailed:error];
    }
}

- (void)cancelDownload
{
    NSLog(@"(SHPSendTokenDC) Canceling current connection: %@", self.theConnection);
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
}

-(void)connectionFailed:(NSError *)error {
    NSLog(@"(SHPSendTokenDC) Connection Error!");
    [self.theConnection cancel];
    self.theConnection = nil;
    self.receivedData = nil;
    self.completionHandler(error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self connectionFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSLog(@"(SHPSendTokenDC) dev token successfully sent");
    self.theConnection = nil;
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@">>>>>>>>>>>> TOKEN TO PROVIDER response: %@", responseString);
    self.completionHandler(nil);
}

@end
