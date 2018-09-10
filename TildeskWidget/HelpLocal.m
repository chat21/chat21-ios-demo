//
//  HelpLocal.m
//  chat21
//
//  Created by Andrea Sponziello on 12/06/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import "HelpLocal.h"

@implementation HelpLocal

+(NSString *)translate:(NSString *)key {
    return NSLocalizedStringFromTable(key, @"Help", nil);
}

@end
