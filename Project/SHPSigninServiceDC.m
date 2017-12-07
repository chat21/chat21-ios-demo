//
//  SHPSigninServiceDC.m
//  Shopper
//
//  Created by andrea sponziello on 16/09/12.
//
//

#import "SHPSigninServiceDC.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"

@implementation SHPSigninServiceDC

@synthesize receivedData;
@synthesize delegate;
//@synthesize serviceUrl;
//@synthesize serviceId;
@synthesize statusCode;
@synthesize user;

-(void)signinWith:(SHPUser *)_user andPassword:(NSString *)password {
    self.user = _user;
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.signin"];
//    self.serviceId = serviceUrl;
    
    NSLog(@"self.serviceUrl: %@", serviceUrl);
    
    NSString *_url = [[NSString alloc] initWithFormat:@"%@?username=%@&password=%@", serviceUrl, [SHPStringUtil urlParamEncode:self.user.username], [SHPStringUtil urlParamEncode:password]];
    NSLog(@"Signin URL: %@", _url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.currentConnection = conn;
    if (conn) {
        self.receivedData = [[NSMutableData alloc] init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//        NSLog(@"Connection successfull!");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Connection failed!");
    }
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
    
    // Create and return the custom domain error.
//    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey: @"connection error",
//    NSUnderlyingErrorKey: error, NSFilePathErrorKey: nil };
//    // Create the underlying error.
//    NSError *anError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:nil];
    [self.delegate signinServiceDCSignedIn:nil error:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.statusCode < 400) {
        NSLog(@"signed ok!");
        [self jsonToUser:self.receivedData]; // decode base64UsernamePassword
        NSLog(@"user with base64 %@", self.user);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate signinServiceDCSignedIn:self.user error:nil];
    } else {
        NSLog(@"signin error");
        // Create and return the custom domain error.
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
        // Create the error.
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate signinServiceDCSignedIn:nil error:theError];
    }
}

- (void)jsonToUser:(NSData *)jsonData {
    // Example response: {"status":"success", "basicAuth":"YWF6ejphYXp6"}
    // NSDictionary *response = [SHPStringUtil parseJSON:jsonString];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    NSLog(@"jsonToUser %@",objects);
    NSString *username = [objects valueForKey:@"username"];
    NSString *basicAuth64 = [objects valueForKey:@"basicAuth"];
    self.user.username = username;
    self.user.httpBase64Auth = basicAuth64;
}

@end
