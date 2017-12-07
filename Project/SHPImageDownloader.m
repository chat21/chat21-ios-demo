//
//  SHPImageDownloader.m
//  Shopper
//
//  Created by andrea sponziello on 28/08/12.
//
//

#import "SHPImageDownloader.h"
//#import "SHPProduct.h"
#import "SHPImageCache.h"

@implementation SHPImageDownloader

////@synthesize product;
@synthesize imageURL;
@synthesize imageCache;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize options;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize progressView;
@synthesize expectedDataSize;

#pragma mark

//- (void)dealloc
//{
//    product = nil;
//    indexPathInTableView = nil;
//
//    activeDownload = nil;
//
//    [imageConnection cancel];
//    imageConnection = nil;
//}

- (void)startDownload {
    self.activeDownload = [NSMutableData data];
    
    NSString * _url = self.imageURL;
    if (self.imageHeight > 0) {
        NSInteger _w = self.imageWidth;
        NSInteger _h = self.imageHeight;
//        if ([UIScreen mainScreen].scale == 2.0) {
//            _w = self.imageWidth * 2;
//            _h = self.imageHeight * 2;
//        }
        _url = [[NSString alloc] initWithFormat:@"%@&w=%ld&h=%ld", self.imageURL, _w, _h];
    }
//    NSLog(@"downloading image %@", self.imageURL);
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

- (void)cancelDownload
{
    NSLog(@"************ CANCELING CONNECTION TO IMAGE *************");
    [self.imageConnection cancel];
    self.delegate = nil;
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode_ = [httpResponse statusCode];
    if (statusCode_ >= 200) {
        self.expectedDataSize = [httpResponse expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"received %d / %d",self.activeDownload.length, self.expectedDataSize);
    if (self.progressView) {
        if (self.expectedDataSize > 0) {
            self.progressView.progress = (float)self.activeDownload.length / (float)self.expectedDataSize;
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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
//    NSLog(@"image loaded!!! %@", image);
//    image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
    self.activeDownload = nil;
    self.imageConnection = nil;
    // call our delegate and tell it that our icon is ready for display
    if (delegate) {
        [delegate appImageDidLoad:image withURL:self.imageURL downloader:self];
    } else {
        NSLog(@"(SHPImageDownloader) delegate is null. Connection was to be stopped before?");
    }

}

@end
