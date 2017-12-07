//
//  DocFileUploadDC.m
//  mobichat
//
//  Created by Andrea Sponziello on 15/11/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocFileUploadDC.h"
#import "AlfrescoDocumentFolderService.h"

@implementation DocFileUploadDC

-(void)createDocumentWithName:(NSString*)name fromURL:(NSURL*)url folder:(AlfrescoFolder *)folder username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL error))callback {
    NSLog(@"Uploading file...");
    AlfrescoContentFile *file = [[AlfrescoContentFile alloc] initWithUrl:url];
    AlfrescoDocumentFolderService *folderservice = [[AlfrescoDocumentFolderService alloc] init];
    [folderservice createDocumentWithName:name inParentFolder:folder contentFile:file properties:nil completionBlock:^(AlfrescoDocument *document, NSError *error) {
        if (error) {
            callback(YES);
        }
        else {
            callback(NO);
        }
    } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
        NSLog(@"Progress...");
    }];
}

//-(NSString *)AFBase64EncodedStringFromString:(NSString *)string {
//    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
//    NSUInteger length = [data length];
//    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
//
//    uint8_t *input = (uint8_t *)[data bytes];
//    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
//
//    for (NSUInteger i = 0; i < length; i += 3) {
//        NSUInteger value = 0;
//        for (NSUInteger j = i; j < (i + 3); j++) {
//            value <<= 8;
//            if (j < length) {
//                value |= (0xFF & input[j]);
//            }
//        }
//
//        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//
//        NSUInteger idx = (i / 3) * 4;
//        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
//        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
//        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
//        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
//    }
//
//    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
//}

@end
