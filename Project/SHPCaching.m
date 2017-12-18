//
//  SHPCaching.m
//  Shopper
//
//  Created by andrea sponziello on 02/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPCaching.h"
#import "SHPStringUtil.h"

@implementation SHPCaching

static NSString *LAST_USED_SHOPS_FILE = @"ShopperLastUsedShops";
static NSString *LAST_PRODUCT_FORM_FILE = @"ShopperLastProductForm";
//static NSString *LAST_DATA_FILE = @"ShopperLastData";
static NSString *SHOPS_KEY = @"shops";
static NSString *FORM_KEY = @"form";
static NSString *DATA_KEY = @"data";
static NSString *VERSION_KEY = @"version";
static NSString *VERSION = @"1.0";

+(NSMutableArray *)restoreLastUsedShops {
    NSString *file = [SHPStringUtil filePathInApp:LAST_USED_SHOPS_FILE];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"NO SHOPS FILE TO RESTORE!");
        return nil;
    }
    NSMutableData *data = [NSData dataWithContentsOfFile:file];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSMutableArray *_shops = [unarchiver decodeObjectForKey:SHOPS_KEY];
    NSString *version = [unarchiver decodeObjectForKey:VERSION_KEY];
    [unarchiver finishDecoding];
    NSLog(@"Decoded cache version %@" , version);
    return _shops;
}

+(void)saveLastUsedShops:(NSMutableArray *)shops {
    NSLog(@"caching last shops on disk...");
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:shops forKey:SHOPS_KEY];
    [archiver encodeObject:VERSION forKey:VERSION_KEY]; //TODO version number from properties file
    [archiver finishEncoding];
    NSString *file = [SHPStringUtil filePathInApp:LAST_USED_SHOPS_FILE];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    }
    NSLog(@"error? %@", err);
}

+(void)deleteLastUsedShopsFile {
    NSString *file = [SHPStringUtil filePathInApp:LAST_USED_SHOPS_FILE];
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:file error:&err];
//    NSLog(@"error deleting? %@", err);
//    NSLog(@"CACHE FILE DELETED! NOW RESTART THE APPLICATION AND COMMENT THE CALL TO THIS METHOD.");
}

+(NSMutableDictionary *)restoreLastProductForm {
    NSString *file = [SHPStringUtil filePathInApp:LAST_PRODUCT_FORM_FILE];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"NO PRODUCT-FORM FILE TO RESTORE!");
        return nil;
    }
    NSMutableData *data = [NSData dataWithContentsOfFile:file];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSMutableDictionary *_form = [unarchiver decodeObjectForKey:FORM_KEY];
    NSString *version = [unarchiver decodeObjectForKey:VERSION_KEY];
    [unarchiver finishDecoding];
    NSLog(@"Decoded cache version: %@" , version);
    return _form;
}

+(void)saveLastProductForm:(NSMutableDictionary *)form {
    NSLog(@"caching last product-form on disk...");
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:form forKey:FORM_KEY];
    [archiver encodeObject:VERSION forKey:VERSION_KEY]; //TODO version number from properties file
    [archiver finishEncoding];
    NSString *file = [SHPStringUtil filePathInApp:LAST_PRODUCT_FORM_FILE];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    }
    NSLog(@"error? %@", err);
}

+(NSMutableDictionary *)restoreDictionaryFromFile:(NSString *)fileName {
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSLog(@"RESTORE: %@",file);
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"NO LAST-DATA FILE TO RESTORE!");
        return nil;
    }
    NSMutableData *data = [NSData dataWithContentsOfFile:file];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSMutableDictionary *_data = [unarchiver decodeObjectForKey:DATA_KEY];
    //NSString *version = [unarchiver decodeObjectForKey:VERSION_KEY];
    [unarchiver finishDecoding];
    return _data;
}

+(void)saveDictionary:(NSMutableDictionary *)dictionary inFile:(NSString*)fileName {
//    NSLog(@"saving %@...", fileName);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dictionary forKey:DATA_KEY];
    [archiver encodeObject:VERSION forKey:VERSION_KEY]; //TODO version number from properties file
    [archiver finishEncoding];
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    }
}

+(void)deleteFile:(NSString *)fileName {
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:file error:&err];
    NSLog(@"error deleting %@? %@", fileName, err);
}

// good for boolean settings
+(void)createEmptyFile:(NSString *)fileName {
    NSLog(@"saving %@...", fileName);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    } else {
        NSLog(@"error creating %@: %@", fileName, err);
    }
}

+(BOOL)fileExists:(NSString *)fileName {
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSLog(@"file path: %@", file);
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return YES;
    }
    return NO;
}

+(UIImage *)restoreImage:(NSString *)fileName {
    NSString *labelKey = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    NSString *file = [SHPStringUtil filePathInApp:labelKey];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
//        NSLog(@"NO LAST-DATA FILE TO RESTORE!");
        return nil;
    }else{
//        NSLog(@"OK LOADED!");
    }
    NSData *data = [NSData dataWithContentsOfFile:file];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	UIImage *_data = [unarchiver decodeObjectForKey:labelKey];
    //NSString *version = [unarchiver decodeObjectForKey:VERSION_KEY];
    [unarchiver finishDecoding];
    return _data;
}

+(void)saveImage:(UIImage *)image inFile:(NSString*)fileName {
    NSString *labelKey = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    NSLog(@"SAVING %@...", labelKey);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:image forKey:labelKey];
    [archiver finishEncoding];
    NSString *file = [SHPStringUtil filePathInApp:labelKey];
   [NSKeyedArchiver archiveRootObject:image toFile:file];//@"/path/to/archive"];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    }
}

// array

+(NSMutableArray *)restoreArrayFromFile:(NSString *)fileName {
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSLog(@"RESTORE: %@",file);
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"NO LAST-DATA FILE TO RESTORE!");
        return nil;
    }
    NSMutableData *data = [NSData dataWithContentsOfFile:file];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableArray *_data = [unarchiver decodeObjectForKey:DATA_KEY];
    //NSString *version = [unarchiver decodeObjectForKey:VERSION_KEY];
    [unarchiver finishDecoding];
    return _data;
}

+(void)saveArray:(NSMutableArray *)array inFile:(NSString*)fileName {
    //    NSLog(@"saving %@...", fileName);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:array forKey:DATA_KEY];
    [archiver encodeObject:VERSION forKey:VERSION_KEY]; //TODO version number from properties file
    [archiver finishEncoding];
    NSString *file = [SHPStringUtil filePathInApp:fileName];
    NSError *err;
    NSLog(@"path: %@", file);
    BOOL success = [data writeToFile:file options:NSDataWritingAtomic error:&err];
    if (!success) {
        NSLog(@"Could not write file %@", [err description]);
    }
}


@end
