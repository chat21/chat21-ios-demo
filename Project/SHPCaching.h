//
//  SHPCaching.h
//  Shopper
//
//  Created by andrea sponziello on 02/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPCaching : NSObject

+(void)saveLastUsedShops:(NSMutableArray *)shops;
+(NSMutableArray *)restoreLastUsedShops;
+(void)deleteLastUsedShopsFile;

+(void)saveLastProductForm:(NSMutableDictionary *)form;
+(NSMutableDictionary *)restoreLastProductForm;

+(void)saveDictionary:(NSMutableDictionary *)data inFile:(NSString *)fileName;
+(NSMutableDictionary *)restoreDictionaryFromFile:(NSString *)fileName;

+(void)saveArray:(NSMutableArray *)data inFile:(NSString *)fileName;
+(NSMutableArray *)restoreArrayFromFile:(NSString *)fileName;

+(void)deleteFile:(NSString *)fileName;
+(void)createEmptyFile:(NSString *)fileName;
+(BOOL)fileExists:(NSString *)fileName;

+(UIImage *)restoreImage:(NSString *)fileName;
+(void)saveImage:(UIImage *)image inFile:(NSString*)fileName;

@end
