//
//  SHPObjectCache.m
//  Dressique
//
//  Created by andrea sponziello on 26/02/13.
//
//

#import "SHPObjectCache.h"

@implementation SHPObjectCache

@synthesize cache;

-(id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
        [self.cache setCountLimit:100];
    }
    return self;
}

-(void)addObject:(NSObject *)object withKey:(NSString *)key {
    [self.cache setObject:object forKey:key];
}

-(NSObject *)getObject:(NSString *)key {
    return [self.cache objectForKey:key];
}

-(void)empty {
    [self.cache removeAllObjects];
}

@end
