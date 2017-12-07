//
//  DocAppMenuOption.h
//  bppmobile
//
//  Created by Andrea Sponziello on 15/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocAppMenuOption : NSObject

@property (strong, nonatomic) NSArray<NSDictionary *> *subOptions;
@property (strong, nonatomic) NSString *name;

@end
