//
//  SHPPushNotificationService.m
//  Smart21
//
//  Created by Andrea Sponziello on 22/01/15.
//
//

#import "SHPPushNotificationService.h"
#import "SHPPushNotification.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"

@implementation SHPPushNotificationService

-(void)sendNotification:(SHPPushNotification *)notification completionHandler:(SHPNotificationHandler)handler withUser:(SHPUser *)user {
    
    // Create the request.
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.notifications.usersend"];
    NSLog(@"notifications-service-url: %@", serviceUrl);
    
    self.handler = handler;
    self.activeDownload = [NSMutableData data];
    self.notification = notification;
    
    NSString *type_enc = [notification.notificationType stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *message_enc = [notification.message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *json_enc = [[notification propertiesAsJSON] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *to_enc = [notification.toUser stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"type=%@&to=%@&message=%@&json=%@", type_enc, to_enc, message_enc, json_enc];
    if (notification.badge) {
        queryString = [[NSString alloc] initWithFormat:@"%@&badge=%lu", queryString, (unsigned long)notification.badge];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    if (user) {
        NSLog(@"Operation with User %@", user.username);
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", user.httpBase64Auth];
        [request setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        // log header's fields
        //        NSDictionary* headers = [request allHTTPHeaderFields];
        //        for (NSString *key in headers) {
        //            NSLog(@"req field: %@ value: %@", key, [headers objectForKey:key]);
        //        }
    } else {
        NSLog(@"Operation without User");
    }
    
    NSString *postString = queryString;
    NSLog(@"POST Query: %@", postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = conn;
    if (conn) {
        self.activeDownload = [[NSMutableData alloc] init];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
}

////- (void)cancelDownload
////{
////    [self.imageConnection cancel];
////    self.imageConnection = nil;
////    self.activeDownload = nil;
////}
//
//#pragma mark -
//#pragma mark Download support (NSURLConnectionDelegate)
//
//-(NSURLRequest *)connection:(NSURLConnection *)connection
//            willSendRequest:(NSURLRequest *)request
//           redirectResponse:(NSURLResponse *)redirectResponse
//{
//    NSURLRequest *newRequest = request;
//    return newRequest;
//}
//
//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//    NSInteger statusCode_ = [httpResponse statusCode];
////    if (statusCode_ >= 200) {
////        self.expectedDataSize = (int)[httpResponse expectedContentLength];
////    }
//}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //    NSLog(@"received %d / %d",self.activeDownload.length, self.expectedDataSize);
//    if (self.progressView) {
//        if (self.expectedDataSize > 0) {
//            float progress = (float)self.activeDownload.length / (float)self.expectedDataSize;
//            if (progress < 0.1) progress = 0.1;
//            self.progressView.progress = progress;
//        }
//    }
    [self.activeDownload appendData:data];
}

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
    long code = [(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.activeDownload setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"image download failed! %@", [NSString stringWithFormat:@"%@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]]);
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.connection = nil;
    
    // Create the error.
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    self.handler(self.notification, theError);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:self.activeDownload encoding:NSISOLatin1StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    if (self.statusCode >= 400 && self.statusCode <500) {
        NSLog(@"HTTP Error %lu", (unsigned long)self.statusCode);
        NSString *code_s = [[NSString alloc] initWithFormat:@"Network error while getting token. HTTP STATUS CODE: %lu", (unsigned long)self.statusCode];
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: code_s};
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        self.handler(self.notification, theError);
    } else {
        self.handler(self.notification, nil);
    }
}

@end
