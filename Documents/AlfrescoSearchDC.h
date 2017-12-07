//
//  AlfrescoSearchDC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 21/08/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AlfrescoNode;
@class AlfrescoRequest;
@class AlfrescoFolder;

@interface AlfrescoSearchDC : NSObject

-(AlfrescoRequest *)documentsByText:(NSString *)text folder:(AlfrescoFolder *)folder completion:(void (^)(NSArray<AlfrescoNode *> *))callback;

@end
