//
//  SHPImageCache.h
//  Shopper
//
//  Created by andrea sponziello on 07/08/12.
//
//

#import <Foundation/Foundation.h>

@interface SHPImageCache : NSObject

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, assign) NSInteger maxSize;

-(void)addImage:(UIImage *)image withKey:(NSString *)key;
-(UIImage *)getImage:(NSString *)key;
-(void)empty;

@end
