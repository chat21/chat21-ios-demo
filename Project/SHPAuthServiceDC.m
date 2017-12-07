//
//  SHPLoginDC.m
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import "SHPAuthServiceDC.h"
#import "SHPServiceUtil.h"
#import "SHPUser.h"
#import "SHPStringUtil.h"

@implementation SHPAuthServiceDC

@synthesize receivedData;
@synthesize authServiceDelegate;
@synthesize serviceUrl;
@synthesize serviceId;
@synthesize user;
@synthesize statusCode;

static NSString *SERVICE_CONNECTIONS_FIND = @"service.connections.find";

-(void)findFacebookUser:(SHPUser *)_user {
//    self.user = _user;
//    self.serviceUrl = [SHPServiceUtil serviceUrl:SERVICE_CONNECTIONS_FIND];
//    self.serviceId = self.serviceUrl;
//    
//    NSString *_url = [[NSString alloc] initWithFormat:@"%@?providerId=facebook&accessToken=%@",self.serviceUrl, [SHPStringUtil urlParamEncode:user.facebookAccessToken]];
//    NSLog(@" facebookAccessToken self.serviceUrl: %@", _url);
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                       timeoutInterval:10.0];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    self.currentConnection = conn;
//    if (conn) {
//        self.receivedData = [[NSMutableData alloc] init];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
////        NSLog(@"Connection successfull!");
//    } else {
//        // Inform the user that the connection failed.
//        NSLog(@"Connection failed!");
//    }
}

- (void)cancelConnection {
    [self.currentConnection cancel];
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.currentConnection = nil;
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
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"---");
    [self.authServiceDelegate authServiceDCErrorWithCode:@"900"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     NSLog(@"connectionDidFinishLoading");
    if([self.serviceId isEqualToString:[SHPServiceUtil serviceUrl:SERVICE_CONNECTIONS_FIND]]) {
        if([self.authServiceDelegate respondsToSelector:@selector(authServiceDCFacebookUser:found:)]) {
            if (self.statusCode < 400) {
                [self jsonToUser:self.receivedData]; // decode base64UsernamePassword
                [self.authServiceDelegate authServiceDCFacebookUser:self.user found:YES];
            } else {
                [self.authServiceDelegate authServiceDCFacebookUser:self.user found:NO];
            }
        } else {
            NSLog(@"Error: not responding to selector authServiceDCFacebookUser:found:");
        }
    }
//    else if([self.serviceName isEqualToString:SHPCONST_UNLIKE_COMMAND]) {
//        if([self.likeDelegate respondsToSelector:@selector(likeDCUnliked:)]) {
//            [self.likeDelegate likeDCUnliked:product];
//        } else {
//            NSLog(@"Error: not responding to selector unliked:");
//        }
//    }
}

- (void)jsonToUser:(NSData *)jsonData {
    
    //NSDictionary *objects = [SHPStringUtil parseJSON:jsonString];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    //    NSString *channel = [objects valueForKey:@"channel"];
    //    NSLog(@"Channel: %@", channel);
    //    NSString *date = [objects valueForKey:@"date"];
    
    NSArray *items = [objects valueForKey:@"items"];
    NSLog(@"Date ******************* : %@", items);
    for(NSDictionary *item in items) {
        NSString *username = [item valueForKey:@"username"];
        NSString *basicAuth64 = [item valueForKey:@"basicAuth"];
        self.user.username = username;
        self.user.httpBase64Auth = basicAuth64;
    }
}

@end
