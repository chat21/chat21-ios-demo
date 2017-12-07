//
//  SHPSearchUsersLoader.m
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import "SHPSearchUsersLoader.h"
#import "SHPUserDC.h"
#import "SHPStringUtil.h"

@implementation SHPSearchUsersLoader

@synthesize searchLocation;
@synthesize textToSearch;

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        self.userDC = [[SHPUserDC alloc] init];
    }
    return self;
}

// extends
-(void)loadUsers {
//    NSString *fulltextQuery = [SHPStringUtil fulltextQuery:self.textToSearch];
    [self.userDC searchByText:self.textToSearch location:self.searchLocation page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
}

@end
