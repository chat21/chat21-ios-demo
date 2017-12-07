//
//  ChatUsersDC.h
//  Smart21
//
//  Created by Andrea Sponziello on 17/04/15.
//
//

#import <Foundation/Foundation.h>
@class SHPUser;
@class SHPProduct;
@class ChatUsersDC;

@protocol ChatUsersDCDelegate <NSObject>
@required
-(void)usersDidLoad:(NSArray *)users usersDC:(ChatUsersDC *)usersDC error:(NSError *) error;
@end

@interface ChatUsersDC : NSObject

@property (nonatomic, assign) id <ChatUsersDCDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLConnection *currentConnection;

-(void)findByUsername:(NSString *)username;
-(void)findByText:(NSString *)text page:(NSInteger)page pageSize:(NSInteger)pageSize withUser:(SHPUser *)user;

-(void)cancelConnection;

@end
