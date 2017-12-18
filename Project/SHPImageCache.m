//
//  SHPImageCache.m
//  Shopper
//
//  Created by andrea sponziello on 07/08/12.
//
//

#import "SHPImageCache.h"
#import <Foundation/Foundation.h>

@interface ImageWrapper: NSObject

@property (nonatomic, strong) NSDate *lastReadTime;
@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *key;

@end

@implementation ImageWrapper

@synthesize lastReadTime;
@synthesize creationTime;
@synthesize image;
@synthesize key;

//static int compareSelector(id w1, id w2, void *context) {
//    SEL methodSelector = (SEL)context;
//    NSDate d1 = [w1 performSelector:methodSelector];
//    NSDate d2 = [w2 performSelector:methodSelector];
//    return [value1 compare:value2];
//}

@end


@implementation SHPImageCache

@synthesize imageCache;
@synthesize maxSize;

-(id)init
{
    if (self = [super init])
    {
        self.imageCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addImage:(UIImage *)image withKey:(NSString *)key {
//    NSLog(@"ADDING NEW IMAGE...");
//    NSLog(@"CACHE: Actual size: %d", [imageCache count]);
//    NSLog(@"CACHE: Max size: %d", self.maxSize);
    [self removeOldestImage];
    ImageWrapper *wrapper = [[ImageWrapper alloc] init];
    wrapper.image = image;
    wrapper.lastReadTime = [[NSDate alloc] init];
    wrapper.creationTime = wrapper.lastReadTime;
//    NSLog(@"**** CREATED IMAGE AT %@", wrapper.creationTime);
    wrapper.key = key;
    [self.imageCache setObject:wrapper forKey:key];
}

-(void)removeOldestImage {
    if ([imageCache count] == self.maxSize) {
//        NSLog(@"Removing oldest element");
        // remove oldest element
        
        NSMutableArray *wrappers = [[NSMutableArray alloc] init];
        for (NSString* key in imageCache) {
            ImageWrapper *wrapper = [imageCache objectForKey:key];
            [wrappers addObject:wrapper];
//            NSLog(@"found: %@", wrapper);
        }
        // sort by lastDate
        
        // Ascending order
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastReadTime" ascending:YES];
        [wrappers sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        // first element is the oldest one
        ImageWrapper *wrapperToRemove = [wrappers objectAtIndex:0];
        wrapperToRemove.image = nil;
//        NSLog(@"CACHE: Removing object at 0 %@", wrapperToRemove.lastReadTime);
        [imageCache removeObjectForKey:wrapperToRemove.key];
    }
}

-(UIImage *)getImage:(NSString *)key {
    ImageWrapper * wrapper = (ImageWrapper *)[self.imageCache objectForKey:key];
    wrapper.lastReadTime = [[NSDate alloc] init];
    return wrapper.image;
}

-(void)empty {
    // NOT USE THIS: "for (NSString *key in imageCache)". This returns
    // an enumerator tha cannot be modified during iteration!
    // EXCEPTION was: "mutated while being enumerated"
    NSArray *keys = [self.imageCache allKeys];
    for (NSString* key in keys) {
        ImageWrapper *wrapperToRemove = [imageCache objectForKey:key];
        wrapperToRemove.image = nil; // really useful? The wrapper has a strong reference to the image...
        [self.imageCache removeObjectForKey:key]; // removeAllObjects (as next) or this? :(
    }
    [self.imageCache removeAllObjects]; // useful? :(
}

@end
