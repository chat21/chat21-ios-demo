//
//  DocFileUploadDC.h
//  mobichat
//
//  Created by Andrea Sponziello on 15/11/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlfrescoFolder;

@interface DocFileUploadDC : NSObject

-(void)createDocumentWithName:(NSString*)name fromURL:(NSURL*)url folder:(AlfrescoFolder *)folder username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL error))callback;

@end
