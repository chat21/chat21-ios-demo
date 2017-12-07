//
//  HomeMenuDC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 15/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPUser;

@interface HomeMenuDC : NSObject

-(void)getMenuMap:(SHPUser *)user completion:(void (^)(NSDictionary *menu))callback;

@end
