//
//  DocVersionControlDC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 21/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocVersionControlDC : NSObject

-(void)getVersionWithCompletion:(void (^)(BOOL newVersionAvailable, NSError *error))callback;

@end
