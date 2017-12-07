//
//  FirebaseAuth.h
//  bppmobile
//
//  Created by Andrea Sponziello on 21/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirebaseAuth : NSObject

-(void)generateToken:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *))callback;

@end

