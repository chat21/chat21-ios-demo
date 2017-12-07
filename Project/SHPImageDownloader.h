//
//  SHPImageDownloader.h
//  Shopper
//
//  Created by andrea sponziello on 28/08/12.
//
//

#import <Foundation/Foundation.h>

@class SHPProduct;
@class RootViewController;
@class SHPImageCache;

@protocol SHPImageDownloaderDelegate;

@interface SHPImageDownloader : NSObject

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) SHPImageCache *imageCache;
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
@property (nonatomic, strong) NSMutableDictionary *options;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong) id <SHPImageDownloaderDelegate> delegate;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, assign) NSInteger expectedDataSize;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) UIProgressView *progressView;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol SHPImageDownloaderDelegate

- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader;

@end