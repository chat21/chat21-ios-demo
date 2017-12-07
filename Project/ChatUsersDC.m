//
//  ChatUsersDC.m
//  Smart21
//
//  Created by Andrea Sponziello on 17/04/15.
//
//

#import "ChatUsersDC.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPUser.h"

@implementation ChatUsersDC

-(void)findByText:(NSString *)text page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)__user {
    NSString *_serviceUrl = [SHPServiceUtil serviceUrl:@"service.search.users"];
    //NSString *asdads;
    NSString *textQuery = @"";
    if(text) {
        NSString *textEscaped = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        textQuery = [[NSString alloc] initWithFormat:@"&q=%@", textEscaped];
    }
    
    NSString *pageQuery = [[NSString alloc] initWithFormat:@"&page=%d&pageSize=%d", (int)page, (int)pageSize];
    
    NSString *__url = [NSString stringWithFormat:@"%@?%@%@", _serviceUrl, textQuery, pageQuery];
    NSString *__url_enc = [__url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", __url_enc);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url_enc]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:60.0];
    
    if (__user) {
        NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
        [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
        NSLog(@"Requesting with basic auth.\nAuthorization:%@", httpAuthFieldValue);
    } else {
        NSLog(@"Requesting without autorization.");
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

-(void)findByUsername:(NSString *)username {
    NSString *serviceUrl = [SHPServiceUtil serviceUrl:@"service.people"];
    
    //    NSLog(@"self.serviceUrl: %@", serviceUrl);
    
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
    } else {
        // Inform the user that the connection failed.
        NSLog(@"(ChatUsersDC) Connection failed!");
    }
}

- (void)cancelConnection {
    [self.currentConnection cancel];
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.currentConnection = nil;
    self.receivedData = nil;
}

-(void)connectionFailed:(NSError *)error {
    NSLog(@"(SHPUserDC) Connection error!");
    self.receivedData = nil;
    if (self.delegate) {
        [self.delegate usersDidLoad:nil usersDC:self error:error];
    }
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Create and return the custom domain error.
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"Generic connection error."};
    // Create the error.
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    [self connectionFailed:theError];
    // Create and return the custom domain error.
    //    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey: @"connection error",
    //    NSUnderlyingErrorKey: error, NSFilePathErrorKey: nil };
    //    // Create the underlying error.
    //    NSError *anError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:nil];
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(usersDidLoad:error:)]) {
    //        [self.delegate usersDidLoad:nil error:error];
    //    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Succeeded! Received %ld bytes of data",[self.receivedData length]);
    
    NSString* text;
    text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    if (self.statusCode < 400) {
        NSArray *users = [self jsonToUsers:self.receivedData];
        if (users && users.count > 0) {
            [self.delegate usersDidLoad:users usersDC:self error:nil];
        } else {
            [self.delegate usersDidLoad:nil usersDC:self error:nil];
        }
    } else {
        NSLog(@"signin error");
        // Create and return the custom domain error.
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
        // Create the error.
        NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
        [self.delegate usersDidLoad:nil usersDC:self error:theError];
    }
}

- (NSArray *)jsonToUsers:(NSData *)jsonData {
    NSMutableArray *users = [[NSMutableArray alloc] init ];
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    
    //    NSString *channel = [objects valueForKey:@"channel"];
    //    NSLog(@"Channel: %@", channel);
    //    NSString *date = [objects valueForKey:@"date"];
    //    NSLog(@"Date: %@", date);
    NSArray *items = [objects valueForKey:@"items"];
    
    for(NSDictionary *item in items) {
        //        NSString *type = [item valueForKey:@"type"];
        NSString *username = [item valueForKey:@"username"];
        NSString *fullName = [item valueForKey:@"fullName"];
        //        NSString *canUploadProducts_s = [item valueForKey:@"canUploadProducts"];
        //        BOOL canUploadProducts = (canUploadProducts && [canUploadProducts_s isEqualToString:@"YES"]) ? YES : NO;
        NSString *email = [item valueForKey:@"email"];
        NSString *photoUrl = [item valueForKey:@"photo"];
        NSDictionary *properties = (NSDictionary *)[item valueForKey:@"properties"];
        
        NSDictionary *myLinkDictionary = (NSDictionary *)[properties valueForKey:@"myLink"];
        NSString *urlDocuments = nil;
        NSArray *values = (NSArray *)[myLinkDictionary valueForKey:@"values"];
        if (values.count > 0) {
            urlDocuments = [values objectAtIndex:0];
        }
        
//        NSDictionary *isRivenditoreDictionary = (NSDictionary *)[properties valueForKey:@"ecoprint_isrivenditore"];
//        NSString *isRivenditore = nil;
//        values = (NSArray *)[isRivenditoreDictionary valueForKey:@"values"];
//        if (values.count > 0) {
//            isRivenditore = [values objectAtIndex:0];
//        }
        
        SHPUser *user = [[SHPUser alloc] init];
        user.fullName = fullName;
        user.username = username;
        //      user.canUploadProducts = canUploadProducts;
        user.email = email;
//        user.photoUrl = photoUrl;
//        user.urlDocuments = urlDocuments;
//        user.isRivenditore = isRivenditore;
//        NSLog(@"********************* user  isRivenditore ****************: %d",user.isRivenditore);
        [users addObject:user];
        
    }
    
    return users;
}

@end
