//
//  SHPImageRequest.h
//  Shopper
//
//  Created by andrea sponziello on 25/09/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^SHPImageHandler)(UIImage *image, NSString *imageURL, NSError *error);

@interface SHPImageRequest : NSObject

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, copy) SHPImageHandler imageHandler;
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
@property (nonatomic, strong) NSMutableDictionary *options;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, assign) NSInteger expectedDataSize;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) UIProgressView *progressView;

-(void)downloadImage:(NSString *)imageURL completionHandler:(SHPImageHandler)handler;
/*
 [downloader downloadImage: @"http://..." completionHandler: ^(NSString *imageURL, NSError *error) {
 if (!error) {
 NSLog(@"Image retriving successfull.");
 }
 }
 */

- (void)cancelDownload;

@end
