//
//  SHPIconDownloader.h
//  BirdWatching
//
//  Created by andrea sponziello on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class SHPProduct;
@class RootViewController;
@class SHPImageCache;

@protocol SHPIconDownloaderDelegate;

@interface SHPIconDownloader : NSObject

//@property (nonatomic, strong) SHPProduct *product;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
//@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) SHPImageCache *imageCache;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) NSInteger columnIndex;
@property (nonatomic, strong) id <SHPIconDownloaderDelegate> delegate;

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol SHPIconDownloaderDelegate 

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end