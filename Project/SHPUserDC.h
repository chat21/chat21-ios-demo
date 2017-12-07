//
//  SHPUserServiceDC.h
//  Shopper
//
//  Created by andrea sponziello on 19/09/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class SHPUser;
@class SHPProduct;

@protocol SHPUserDCDelegate <NSObject>

@required
-(void)usersDidLoad:(NSArray *)users error:(NSError *) error;
//-(void)usersDidLoad:(NSArray *)users error:(NSError *) error;

//deprecated
//@optional
//- (void)networkError;

@end

@interface SHPUserDC : NSObject

@property (nonatomic, assign) id <SHPUserDCDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

-(void)findByUsername:(NSString *)username;
-(void)searchByText:(NSString *)text location:(CLLocation *)location page:(NSInteger) page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;
//-(void)likedTo:(SHPProduct *)product;
-(void)facebookConnect:(SHPUser *)user;
-(void)facebookDisconnect:(SHPUser *)user;
-(void)cancelConnection;

@end
