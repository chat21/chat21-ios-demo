//
//  SHPUser.m
//  Shopper
//
//  Created by andrea sponziello on 25/08/12.
//
//

#import "SHPUser.h"
#import "SHPServiceUtil.h"
#import "SHPConstants.h"

@implementation SHPUser

+(NSString *)photoUrlByUsername:(NSString *)username {
    NSInteger w = SHPCONST_USER_ICON_WIDTH;
    NSInteger h = SHPCONST_USER_ICON_HEIGHT;
    // retina resolution img?
    //    if ([UIScreen mainScreen].scale == 2.0) {
    //        w = w * 2;
    //        h = h * 2;
    //    }
    NSString *peopleService = [SHPServiceUtil serviceUrl:@"service.people"];
    NSString *username_enc = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@/photo?w=%d&h=%d", peopleService, username_enc, (int)w, (int)h];

    return url;
}

-(NSString *)photoUrl {
    return [SHPUser photoUrlByUsername:self.username];
}

-(NSString *)displayName {
    NSString *displayName;
    // use fullname if available
    if (self.fullName) {
        NSString *trimmedFullname = [self.fullName stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceCharacterSet]];
        if (trimmedFullname.length > 0) {
            displayName = trimmedFullname;
        }
    }
    
    if (!displayName && (self.firstName || self.lastName)) {
        displayName = [[NSString alloc] initWithFormat:@"%@ %@", (self.firstName ? self.firstName : @""), (self.lastName ? self.lastName : @"")];
        displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else {
        displayName = self.username;
    }
    return displayName;
}

@end
