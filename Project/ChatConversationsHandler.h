//
//  ChatConversationsHandler.h
//  Soleto
//
//  Created by Andrea Sponziello on 29/12/14.
//
//

#import <Foundation/Foundation.h>
#import "SHPFirebaseTokenDelegate.h"
#import "SHPConversationsViewDelegate.h"
//#import <Firebase/Firebase.h>

@import Firebase;

@class SHPApplicationContext;
@class FirebaseCustomAuthHelper;
@class Firebase;
//@class SHPUser;
@class ChatUser;

@interface ChatConversationsHandler : NSObject// <SHPFirebaseTokenDelegate>

//@property (strong, nonatomic) SHPApplicationContext *applicationContext;
//@property (strong, nonatomic) SHPUser *loggeduser;
@property (strong, nonatomic) ChatUser *loggeduser;
@property (strong, nonatomic) NSString *me;
@property (strong, nonatomic) FirebaseCustomAuthHelper *authHelper;
@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) NSString *firebaseToken;
@property (strong, nonatomic) FIRDatabaseReference *conversationsRef;
@property (assign, nonatomic) FIRDatabaseHandle conversations_ref_handle_added;
@property (assign, nonatomic) FIRDatabaseHandle conversations_ref_handle_changed;
@property (assign, nonatomic) FIRDatabaseHandle conversations_ref_handle_removed;
@property (assign, nonatomic) id <SHPConversationsViewDelegate> delegateView;
@property (strong, nonatomic) NSString *currentOpenConversationId;
//@property (strong, nonatomic) NSString *firebaseRef;
@property (nonatomic, strong) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) NSString *tenant;

//-(id)initWith:(SHPApplicationContext *)context delegateView:(id<SHPConversationsViewDelegate>)delegateView;
//-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user;
-(id)initWithTenant:(NSString *)tenant user:(ChatUser *)user;
-(void)connect;
-(NSMutableArray *)restoreConversationsFromDB;

@end
