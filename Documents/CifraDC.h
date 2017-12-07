//
//  CifraDC.h
//  mobichat
//
//  Created by Andrea Sponziello on 21/11/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CifraDC : NSObject

-(void)cifraString:(NSString *)stringaDaCifrare completion:(void (^)(NSString *stringaCifrata))callback;

@end
