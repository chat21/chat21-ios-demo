//
//  ChatConversationHandler.h
//  Soleto
//
//  Created by Andrea Sponziello on 19/12/14.
//
//

#import <Foundation/Foundation.h>
#import "SHPFirebaseTokenDelegate.h"
#import "SHPChatDelegate.h"
#import <Firebase/Firebase.h>
#import "ChatGroupsDelegate.h"

@class SHPApplicationContext;
@class FAuthData;
@class FirebaseCustomAuthHelper;
@class Firebase;
//@class SHPUser;
@class ChatUser;
@class ChatGroup;

@interface ChatConversationHandler : NSObject <ChatGroupsDelegate>

//@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) ChatUser *user;
@property (strong, nonatomic) NSString *recipientId;
@property (strong, nonatomic) NSString *recipientFullname;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSString *groupId;

@property (strong, nonatomic) NSString *senderId;

@property (strong, nonatomic) NSString *conversationId; // Intelocutor-id
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *firebaseToken;
@property (strong, nonatomic) FIRDatabaseReference *messagesRef;
@property (strong, nonatomic) FIRDatabaseReference *conversationOnSenderRef;
@property (strong, nonatomic) FIRDatabaseReference *conversationOnReceiverRef;
@property (assign, nonatomic) FIRDatabaseHandle messages_ref_handle;
@property (assign, nonatomic) FIRDatabaseHandle updated_messages_ref_handle;
@property (strong, nonatomic) FirebaseCustomAuthHelper *authHelper;
@property (assign, nonatomic) id <SHPChatDelegate> delegateView;

@property (assign, nonatomic) double lastSentReadNotificationTime;

//-(id)initWithRecipient:(NSString *)recipient recipientFullName:(NSString *)recipientFullName conversationId:(NSString *)conversationId user:(ChatUser *)user;
-(id)initWithRecipient:(NSString *)recipientId recipientFullName:(NSString *)recipientFullName user:(ChatUser *)user;
//-(id)initWithGroupId:(NSString *)groupId conversationId:(NSString *)conversationId user:(ChatUser *)user;
-(id)initWithGroupId:(NSString *)groupId user:(ChatUser *)user;
-(void)connect;
-(void)dispose;
- (void)sendMessage:(NSString *)text;
-(void)sendMessageWithText:(NSString *)text type:(NSString *)type attributes:(NSDictionary *)attributes;
-(void)restoreMessagesFromDB;
//+(void)sendSpecialMessageFromTeamlabotButMustBeServerSide:(NSString *)recipient attributes:(NSDictionary *)attributes;
+(NSMutableDictionary *)firebaseMessageFor:(ChatMessage *)message;

@end
