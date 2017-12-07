//
//  SHPSearchUsersLoader.h
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPUsersLoaderStrategy.h"

@class CLLocation;

@interface SHPSearchUsersLoader : SHPUsersLoaderStrategy

@property (strong, nonatomic) CLLocation *searchLocation;
@property (strong, nonatomic) NSString *textToSearch;

@end
