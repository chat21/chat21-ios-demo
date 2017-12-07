//
//  ChatImageUploadDC.h
//  Chat21
//
//  Created by Andrea Sponziello on 20/04/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUpload.h"

@class ChatImageUploadDC;
@class CLUploader;

@protocol ChatUploadDelegate
- (void)uploaded:(ChatImageUploadDC *)upload error:(NSError *)error;
@end

@interface ChatImageUploadDC : ChatUpload

@property (nonatomic, assign) BOOL removeMode;

@property (nonatomic, strong) NSMutableData *receivedData;
@property (assign, nonatomic) NSInteger statusCode;

@property(strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, assign) id <ChatUploadDelegate> delegate;

// product-form data
@property(strong, nonatomic) UIImage *image;
@property(strong, nonatomic) NSString *imageID;
//@property(strong, nonatomic) NSString *imagePath;

// cloudinary
@property(strong, nonatomic) CLUploader* uploader;


//+(NSMutableArray *)uploadIdsOnDisk;
//+(SHPProductUploaderDC *)getPersistentUploaderById:(NSString *)id;
//+(void)deleteMeFromPersistentConnections:(NSString *)id;
//+(void)removeUploadFromPersistentConnections:(NSString *)id;

@end
