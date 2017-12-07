//
//  SHPIconDownloader.m
//  BirdWatching
//
//  Created by andrea sponziello on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPIconDownloader.h"
//#import "SHPProduct.h"
#import "SHPImageCache.h"

//#define kAppIconHeight 48


@implementation SHPIconDownloader

//@synthesize product;
@synthesize imageURL;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize imageCache;
@synthesize indexPathInTableView;
@synthesize columnIndex;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

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

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    //NSInteger _w = self.imageWidth;
    //NSInteger _h = self.imageHeight;
    NSLog(@"width:::::: %f",[[UIScreen mainScreen] bounds].size.width);
    NSLog(@"scale:::::: %d", (int)[UIScreen mainScreen].scale);
    NSInteger _w = (self.imageWidth * (int)[UIScreen mainScreen].scale);
    NSInteger _h = (self.imageHeight * (int)[UIScreen mainScreen].scale);
    NSLog(@"_w %ld - %d", (long)_w, self.imageWidth);

    // if activated loads retina-images with retina-resolution
//    if ([UIScreen mainScreen].scale == 2.0) {
//        _w = self.imageWidth * 2;
//        _h = self.imageHeight * 2;
//    }
//    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", product.imageURL, _w, _h];
    NSString *imageUrlWithRedim = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", self.imageURL, (int)_w, (int)_h];
    NSLog(@"downloading image %@", imageUrlWithRedim);
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLRequest *request = [NSURLRequest requestWithURL:
                         [NSURL URLWithString:imageUrlWithRedim]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             request delegate:self startImmediately:NO];
    // http://stackoverflow.com/questions/4090730/nsurlrequest-wont-fire-while-uiscrollview-is-scrolling
    
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [conn start];
    self.imageConnection = conn;
    conn = nil;
}

//- (void)startDownloadWithUrl
//{
//    self.activeDownload = [NSMutableData data];
//    NSInteger _w = self.imageWidth;
//    NSInteger _h = self.imageHeight;
//    NSLog(@"width:::::: %f",[[UIScreen mainScreen] bounds].size.width);
//    NSLog(@"scale:::::: %d", (int)[UIScreen mainScreen].scale);
//    NSInteger _w = (self.imageWidth * (int)[UIScreen mainScreen].scale);
//    NSInteger _h = (self.imageHeight * (int)[UIScreen mainScreen].scale);
//    NSLog(@"_w %ld - %d", (long)_w, self.imageWidth);
//    
//    // if activated loads retina-images with retina-resolution
//    //    if ([UIScreen mainScreen].scale == 2.0) {
//    //        _w = self.imageWidth * 2;
//    //        _h = self.imageHeight * 2;
//    //    }
//    //    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", product.imageURL, _w, _h];
//    
//    NSString *imageUrlWithRedim = [[NSString alloc] initWithFormat:@"%@&w=%d&h=%d", self.imageURL, (int)_w, (int)_h];
//    NSLog(@"downloading image %@", imageUrlWithRedim);
//    // alloc+init and start an NSURLConnection; release on completion/failure
//    NSURLRequest *request = [NSURLRequest requestWithURL:
//                             [NSURL URLWithString:imageUrlWithRedim]];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
//                             request delegate:self startImmediately:NO];
//    // http://stackoverflow.com/questions/4090730/nsurlrequest-wont-fire-while-uiscrollview-is-scrolling
//    
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceiveData");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"image dwnld failed! %@", [NSString stringWithFormat:@"%@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]]);
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    [self.imageCache addImage:image withKey:self.imageURL];
    
    self.activeDownload = nil;
    image = nil;
    // Release the connection now that it's finished
    self.imageConnection = nil;
    // call our delegate and tell it that our icon is ready for display
    [delegate appImageDidLoad:self.indexPathInTableView];
}

@end

