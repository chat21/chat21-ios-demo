//
//  SHPUsersLoaderStrategy.h
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import <Foundation/Foundation.h>

@class SHPUserDC;

@interface SHPUsersLoaderStrategy : NSObject

@property (strong, nonatomic) SHPUserDC *userDC;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;

-(void)loadUsers;
-(void)cancelOperation;

@end
