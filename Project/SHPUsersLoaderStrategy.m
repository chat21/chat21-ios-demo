//
//  SHPUsersLoaderStrategy.m
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import "SHPUsersLoaderStrategy.h"
#import "SHPUserDC.h"

@implementation SHPUsersLoaderStrategy

@synthesize userDC;
@synthesize searchPageSize;
@synthesize searchStartPage;

// abstract
-(void)loadUsers {}

-(void)cancelOperation {
    [self.userDC cancelConnection];
}

@end
