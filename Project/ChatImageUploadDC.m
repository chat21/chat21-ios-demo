//
//  ChatImageUploadDC.m
//  Chat21
//
//  Created by Andrea Sponziello on 20/04/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatImageUploadDC.h"
#import "ChatUtil.h"
#import "SHPImageUtil.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatUploadsController.h"
//#import "CLCloudinary.h"
//#import "CLUploader.h"

@implementation ChatImageUploadDC

//static CLCloudinary *cloudinary;

enum {
    STATE_UPLOADING = 10,
    STATE_FAILED = 20,
    STATE_TERMINATED = 30
};

-(void)cancel {
//    [self.uploader cancel];
}

-(void)start {
    if (self.removeMode) {
        [self remove];
    } else {
        [self upload];
    }
    
}

-(void)remove {
    NSLog(@"Removing image from cloudinary. Completion Block NEVER CALLED");
    [self initCloudunary];
//    [self.uploader destroy:self.imageID options:@{@"invalidate": @(true)} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
//        if (successResult) {
//            NSString* publicId = [successResult valueForKey:@"public_id"];
//            NSLog(@"Delete success. Public ID=%@, Full result=%@", publicId, successResult);
//            self.statusCode = STATE_TERMINATED;
//        } else {
//            NSLog(@"Delete error: %@, %ld", errorResult, code);
//            self.statusCode = STATE_FAILED;
//        }
//    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
//        NSLog(@"Delete progress: %ld/%ld (+%ld)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
//    }];
}

-(void)upload {
//    [self initCloudunary];
//    
//    NSLog(@"Using cloudinary to upload image.");
//    self.uploader = [[CLUploader alloc] init:cloudinary delegate:nil];
//    
//    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.image];
//    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
//    //    NSString *imageCloudId = [[NSUUID UUID] UUIDString];
//    
//    self.statusCode = STATE_UPLOADING;
//    [self.uploader upload:imageData options:@{@"folder":[ChatUtil groupImagesRelativePath], @"public_id": self.imageID, @"overwrite": @(true), @"invalidate": @(true)} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
//        if (successResult) {
//            NSString* publicId = [successResult valueForKey:@"public_id"];
//            NSLog(@"Block upload success. Public ID=%@, Full result=%@", publicId, successResult);
//            self.statusCode = STATE_TERMINATED;
//        } else {
//            NSLog(@"Block upload error: %@, %ld", errorResult, code);
//            self.statusCode = STATE_FAILED;
//        }
//    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
//        NSLog(@"Block upload progress: %ld/%ld (+%ld)", totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
//    }];
}

-(void)initCloudunary {
//    if (!cloudinary) {
//        NSLog(@"Initializing cloudinary to upload image.");
//        
//        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSDictionary *plistDictionary = appDelegate.applicationContext.plistDictionary;
//        NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Images"];
//        NSString *cloud_name = [settingsDictionary objectForKey:@"cloudinary_cloud_name"];
//        NSString *api_key = [settingsDictionary objectForKey:@"cloudinary_api_key"];
//        NSString *api_secret = [settingsDictionary objectForKey:@"cloudinary_api_secret"];
//        
//        cloudinary = [[CLCloudinary alloc] init];
//        [cloudinary.config setValue:cloud_name forKey:@"cloud_name"];
//        [cloudinary.config setValue:api_key forKey:@"api_key"];
//        [cloudinary.config setValue:api_secret forKey:@"api_secret"];
//    }
}

-(void)dealloc {
    NSLog(@"DEALLOCATING ChatImageUploadDC");
}

@end
