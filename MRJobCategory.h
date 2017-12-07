//
//  MRJobCategory.h
//  misterlupo
//
//  Created by Andrea Sponziello on 06/07/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRJobCategory : NSObject

@property(strong, nonatomic) NSDictionary *langs;
@property(strong, nonatomic) NSString *categoryId; // refactor > categoryId
@property(strong, nonatomic) NSMutableArray *children;
@property(strong, nonatomic) MRJobCategory *parent;

@property(strong, nonatomic) NSString *nameInCurrentLocale;
@property(strong, nonatomic) NSString *imageName;
@property(strong, nonatomic) NSString *pathId;

- (id)initWithDictionary:(NSDictionary *)catDict parent:(MRJobCategory *)parent;

@end
