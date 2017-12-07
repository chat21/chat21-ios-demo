//
//  MRService.m
//  misterlupo
//
//  Created by Andrea Sponziello on 08/10/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "MRService.h"


@implementation MRService

-(void)sendCV:(NSDictionary *)cv completion:(void (^)(NSDictionary *))callback  {
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString *__url = [NSString stringWithFormat:@"http://script.smart21.it/labot/save_request.php?fullname=%@&userid=%@&category=%@&body=%@&cap=%@&city=%@&prov=%@&zone=%@&tel=%@&type=cv",
                       [cv[@"fullname"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"userid"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"category"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"body"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"cap"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"city"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"prov"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"zone"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [cv[@"tel"] stringByAddingPercentEncodingWithAllowedCharacters:set]];
    NSLog(@"job cv url: %@", __url);
    
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil);
            return;
        }
        NSString *json = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"search request json response: %@", json);
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:data
                                options:kNilOptions
                                error:&error];
        callback(result);
    }];
    [task resume];
    
//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:60.0];
//    
//    // eventually cancel the current running connection
//    if(self.theConnection != nil) {
//        [self.theConnection cancel];
//    }
//    // create the connection with the request
//    // and start loading the data
//    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (self.theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        self.receivedData = [[NSMutableData alloc] init];
//    } else {
//        // Inform the user that the connection failed.
//        NSLog(@"Connecion failed!");
//        NSError *error = [[NSError alloc] init];
//        [self connectionFailed:error];
//    }
}

-(void)sendSearchRequest:(NSDictionary *)request completion:(void (^)(NSDictionary *))callback {
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString *__url = [NSString stringWithFormat:@"http://script.smart21.it/labot/save_request.php?fullname=%@&userid=%@&category=%@&body=%@&cap=%@&city=%@&prov=%@&zone=%@&tel=%@&type=search",
                       [request[@"fullname"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"userid"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"category"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"body"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"cap"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"city"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"prov"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"zone"] stringByAddingPercentEncodingWithAllowedCharacters:set],
                       [request[@"tel"] stringByAddingPercentEncodingWithAllowedCharacters:set]];
    NSLog(@"search request url: %@", __url);
    
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil);
            return;
        }
        NSString *json = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"search request json response: %@", json);
        NSDictionary *result = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:kNilOptions
                                 error:&error];
        callback(result);
    }];
    [task resume];
    
//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:__url]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:60.0];
//    
//    // eventually cancel the current running connection
//    if(self.theConnection != nil) {
//        [self.theConnection cancel];
//    }
//    // create the connection with the request
//    // and start loading the data
//    self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (self.theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        self.receivedData = [[NSMutableData alloc] init];
//    } else {
//        // Inform the user that the connection failed.
//        NSLog(@"Connecion failed!");
//        NSError *error = [[NSError alloc] init];
//        [self connectionFailed:error];
//    }
}

-(void)subscribeToJobSearching:(NSString *)userid lat:(NSString *)lat lon:(NSString *)lon category:(NSString *)category completion:(void (^)(NSDictionary *))callback  {
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString* subscriber = [userid stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString* _lat = [lat stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString* _lon = [lon stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString* channel = [category stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString *dataString = [NSString stringWithFormat:@"subscriber=%@&lat=%@&lon=%@&radius=30&app_id=labot&channel=%@&enabled=1", subscriber, _lat, _lon, channel];
    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    sessionConfiguration.HTTPAdditionalHeaders = @{
//                                                   @"api-key"       : @"API_KEY"
//                                                   };
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://script.smart21.it/labot/subscriptions/subscribe.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"error: %@ data: %@", error, json);
    }];
    [postDataTask resume];
}

-(void)queryProfessionalsInCategory:(NSString *)category lat:(NSString *)lat lon:(NSString *)lon completion:(void (^)(NSDictionary *))callback  {
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSString* _lat = [lat stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString* _lon = [lon stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString* channel = [category stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString *__url = [NSString stringWithFormat:@"http://script.smart21.it/labot/subscriptions/query.php?lat=%@&lon=%@&radius=30&app_id=labot&channel=%@&enabled=1", _lat, _lon, channel];
    //    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    sessionConfiguration.HTTPAdditionalHeaders = @{
    //                                                   @"api-key"       : @"API_KEY"
    //                                                   };
    //    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:__url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil);
            return;
        }
        NSString *json = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"job query around response: %@", json);
        NSDictionary *result = [NSJSONSerialization
                                JSONObjectWithData:data
                                options:kNilOptions
                                error:&error];
        callback(result);
    }];
    [task resume];
}

//- (void)cancelDownload
//{
//    NSLog(@"(MRService) Canceling current connection: %@", self.theConnection);
//    [self.theConnection cancel];
//    self.theConnection = nil;
//    self.receivedData = nil;
//}
//
//-(void)connectionFailed:(NSError *)error {
//    NSLog(@"(MRService) Connection Error!");
//    [self.theConnection cancel];
//    self.theConnection = nil;
//    self.receivedData = nil;
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [self.receivedData setLength:0];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    [self.receivedData appendData:data];
//}
//
//- (void)connection:(NSURLConnection *)connection
//  didFailWithError:(NSError *)error
//{
//    NSLog(@"(MRService) Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    [self connectionFailed:error];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    self.theConnection = nil;
//    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
//    NSLog(@">>>>>>>>>>>> request successfully sent: %@", responseString);
//}

@end
