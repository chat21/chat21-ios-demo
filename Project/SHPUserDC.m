//
//  SHPUserServiceDC.m
//  Shopper
//
//  Created by andrea sponziello on 19/09/12.
//
//

#import "SHPUserDC.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"
//#import "SHPProduct.h"

@implementation SHPUserDC

@synthesize receivedData;
@synthesize delegate;
@synthesize statusCode;

-(void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    NSString *_serviceUrl = [SHPServiceUtil serviceUrl:@"service.search.users"];
    
    NSString *textQuery = @"";
    if(text) {
        NSString *textEscaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        textQuery = [[NSString alloc] initWithFormat:@"&q=%@", textEscaped];
    }
    
    NSString *locationQuery = @"";
    if(location) {
        double lat = location.coordinate.latitude;
        double lon = location.coordinate.longitude;
        locationQuery = [[NSString alloc] initWithFormat:@"&lat=%f&lon=%f", lat, lon];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@%@", _serviceUrl, textQuery, locationQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    } else {
    }
    
    // create the connection with the request
    // and start loading the data
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.currentConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"(SHPUserDC) Connection not established!");
        // Create and return the custom domain error.
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
        // Create the error.
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        [self connectionFailed:theError];
    }
}

//-(void)likedTo:(SHPProduct *)product {
//    NSString *_serviceUrl = [SHPServiceUtil serviceUrl:@"service.likes"];
//    
//    NSString *__url = [NSString stringWithFormat:@"%@/%@", _serviceUrl, product.oid];
//    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"url: %@", __url_enc);
//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:60.0];
//    
//    // create the connection with the request
//    // and start loading the data
//    self.currentConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (self.currentConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        self.receivedData = [[NSMutableData alloc] init];
//    } else {
//        // Inform the user that the connection failed.
//        NSLog(@"(SHPUserDC) Connection not established!");
//        // Create and return the custom domain error.
//        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
//        // Create the error.
//        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
//        [self connectionFailed:theError];
//    }
//}

-(void)findByUsername:(NSString *)username {
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.people"];
    NSString *_url = [[NSString alloc] initWithFormat:@"%@/%@", serviceUrl, [SHPStringUtil urlParamEncode:username]];
    
    NSLog(@"Requesting %@", _url);
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
        NSLog(@"(SHPUserDC) Connection failed!");
    }
}

-(void)facebookConnect:(SHPUser *)user
{
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.connections.me"];
    NSString *url;
    NSString *nameService = [[NSString alloc] initWithFormat:@"connect"];
    if(user.facebookAccessToken) {
        url = [[NSString alloc] initWithFormat:@"%@/%@?accessToken=%@", serviceUrl, nameService, user.facebookAccessToken];
    }
    NSString *__url_enc = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    if (user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    }
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.currentConnection) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        [self connectionFailed:theError];
    }
}

-(void)facebookDisconnect:(SHPUser *)user
{
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.connections.me"];
    NSString *url;
    NSString *nameService = [[NSString alloc] initWithFormat:@"disconnect"];
    if(user.facebookAccessToken) {
        url = [[NSString alloc] initWithFormat:@"%@/%@?accessToken=%@", serviceUrl, nameService, user.facebookAccessToken];
    }
    NSString *__url_enc = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    if (user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    }
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (self.currentConnection) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        [self connectionFailed:theError];
    }
}

//-------------------------------------------------------------------------------------//
//START CONNECTION
//-------------------------------------------------------------------------------------//
- (void)cancelConnection {
    [self.currentConnection cancel];
    self.currentConnection = nil;
    self.receivedData = nil;
}

-(void)connectionFailed:(NSError *)error {
    NSLog(@"(SHPUserDC) Connection error!");
    self.receivedData = nil;
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(usersDidLoad:error:)]) {
            [self.delegate usersDidLoad:nil error:error];
        }
        else {
            NSLog(@"SHPUserDC: self.delegate -->> %@ <<-- does not respond to selector 'usersDidLoad:error:'!", self.delegate);
        }
    }
}

// CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    self.receivedData = nil;
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    [self connectionFailed:theError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(usersDidLoad:error:)]) {
        if (self.statusCode < 400) {
            NSArray *users = [self jsonToUsers:self.receivedData];
            if (users && users.count > 0) {
                [self.delegate usersDidLoad:users error:nil];
            } else {
                [self.delegate usersDidLoad:nil error:nil];
            }
        } else {
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
            NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
            [self.delegate usersDidLoad:nil error:theError];
        }
    } else {
        NSLog(@"SHPUserDC ERROR: delegate is nil or not responds to selector usersDidLoad:error: %@", self.delegate);
    }
}

- (NSArray *)jsonToUsers:(NSData *)jsonData {
   
    NSMutableArray *users = [[NSMutableArray alloc] init ];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
   
    NSArray *items = [objects valueForKey:@"items"];
    for(NSDictionary *item in items) {
        NSString *username = [item valueForKey:@"username"];
        NSString *fullName = [item valueForKey:@"fullName"];
        //        NSString *canUploadProducts_s = [item valueForKey:@"canUploadProducts"];
        //        BOOL canUploadProducts = (canUploadProducts && [canUploadProducts_s isEqualToString:@"YES"]) ? YES : NO;
        NSString *email = [item valueForKey:@"email"];
        NSString *photoUrl = [item valueForKey:@"photo"];
        //NSLog(@"photoUrl: %@",photoUrl);
        
        NSString *productsCreatedByCount = [item valueForKey:@"productsCreatedByCount"];
        NSString *productsLikesCount = [item valueForKey:@"productsLikesCount"];
        
        
        NSDictionary *properties = (NSDictionary *)[item valueForKey:@"properties"];
        NSDictionary *myLinkDictionary = (NSDictionary *)[properties valueForKey:@"myLink"];
        NSString *urlDocuments = nil;
        NSArray *values = (NSArray *)[myLinkDictionary valueForKey:@"values"];
        if (values.count > 0) {
            urlDocuments = [values objectAtIndex:0];
        }
        NSDictionary *isRivenditoreDictionary = (NSDictionary *)[properties valueForKey:@"ecoprint_isrivenditore"];
        NSString *isRivenditore = nil;
        values = (NSArray *)[isRivenditoreDictionary valueForKey:@"values"];
        if (values.count > 0) {
            isRivenditore = [values objectAtIndex:0];
        }
        SHPUser *user = [[SHPUser alloc] init];
        user.fullName = fullName;
        user.username = username;
        //      user.canUploadProducts = canUploadProducts;
//        user.email = email;
//        user.photoUrl = photoUrl;
//        user.urlDocuments = urlDocuments;
//        user.isRivenditore = isRivenditore;
//        user.productsCreatedByCount = productsCreatedByCount;
//        user.productsLikesCount = productsLikesCount;
        [users addObject:user];
    }
    return users;
}
//-------------------------------------------------------------------------------------//
//END CONNECTION
//-------------------------------------------------------------------------------------//
@end

