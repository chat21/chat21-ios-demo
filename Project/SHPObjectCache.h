//
//  SHPObjectCache.h
//  Dressique
//
//  Created by andrea sponziello on 26/02/13.
//
//

#import <Foundation/Foundation.h>

@interface SHPObjectCache : NSObject

@property(strong, nonatomic) NSCache *cache;

-(void)addObject:(NSObject *)object withKey:(NSString *)key;
-(NSObject *)getObject:(NSString *)key;
-(void)empty;

@end
