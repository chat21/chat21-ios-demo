//
//  DocFileDownloadDC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 01/10/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocFileDownloadDC : NSObject

- (void)downloadFile:(NSString*)name from:(NSString*)stringURL in:(NSString*)path username:(NSString *)username password:(NSString *)password;

@end
