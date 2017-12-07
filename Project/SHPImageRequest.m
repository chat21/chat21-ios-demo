//
//  SHPImageRequest.m
//  Shopper
//
//  Created by andrea sponziello on 25/09/12.
//
//

#import "SHPImageRequest.h"

@implementation SHPImageRequest

//@synthesize product;
@synthesize imageURL;
@synthesize imageHandler;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize options;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize progressView;
@synthesize expectedDataSize;

-(void)downloadImage:(NSString *)__imageURL completionHandler:(SHPImageHandler)handler {
    self.imageHandler = handler;
    self.imageURL = __imageURL;
    NSLog(@"downloading __imageURL %@", __imageURL);
    self.activeDownload = [NSMutableData data];
    NSString * _url = __imageURL;
    if (self.imageHeight > 0) {
        NSLog(@"width:::::: %f",[[UIScreen mainScreen] bounds].size.width);
        NSLog(@"scale:::::: %d", (int)[UIScreen mainScreen].scale);
        NSInteger _w = (self.imageWidth * (int)[UIScreen mainScreen].scale);
        NSInteger _h = (self.imageHeight * (int)[UIScreen mainScreen].scale);
        NSLog(@"_w %ld - %d", (long)_w, self.imageWidth);
        _url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", self.imageURL, (int)_w, (int)_h];
    }
//    NSString *__url_enc = [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"downloading image %@", _url);
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:_url]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             request delegate:self startImmediately:NO];
    // http://stackoverflow.com/questions/4090730/nsurlrequest-wont-fire-while-uiscrollview-is-scrolling
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [conn start];
    self.imageConnection = conn;
    conn = nil;
}

//- (void)downloadImage {
//    self.activeDownload = [NSMutableData data];
//
//    NSString * _url = self.imageURL;
//    if (self.imageHeight > 0) {
//        NSInteger _w = self.imageWidth;
//        NSInteger _h = self.imageHeight;
//        if ([UIScreen mainScreen].scale == 2.0) {
//            _w = self.imageWidth * 2;
//            _h = self.imageHeight * 2;
//        }
//        _url = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", self.imageURL, _w, _h];
//    }
//    //    NSLog(@"downloading image %@", self.imageURL);
//    NSLog(@"downloading image %@", _url);
//    // alloc+init and start an NSURLConnection; release on completion/failure
//    NSURLRequest *request = [NSURLRequest requestWithURL:
//                             [NSURL URLWithString:_url]];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
//                             request delegate:self startImmediately:NO];
//    // http://stackoverflow.com/questions/4090730/nsurlrequest-wont-fire-while-uiscrollview-is-scrolling
//    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    [conn start];
//    self.imageConnection = conn;
//    conn = nil;
//}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
//    NSLog(@"REDIRECTION!! %@", redirectResponse);
    NSURLRequest *newRequest = request;
    return newRequest;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode_ = [httpResponse statusCode];
    if (statusCode_ >= 200) {
        self.expectedDataSize = (int)[httpResponse expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //    NSLog(@"received %d / %d",self.activeDownload.length, self.expectedDataSize);
    if (self.progressView) {
        if (self.expectedDataSize > 0) {
            float progress = (float)self.activeDownload.length / (float)self.expectedDataSize;
            if (progress < 0.1) progress = 0.1;
            self.progressView.progress = progress;
        }
    }
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"image download failed! %@", [NSString stringWithFormat:@"%@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]]);
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // Create the error.
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"signin error"};
    NSError *theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:900 userInfo:errorDictionary];
    self.imageHandler(nil, self.imageURL, theError);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    //    image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
    self.activeDownload = nil;
    self.imageConnection = nil;
    // call our delegate and tell it that our icon is ready for display
    self.imageHandler(image, self.imageURL, nil);
//    [delegate appImageDidLoad:image withURL:self.imageURL downloader:self];
}

@end
