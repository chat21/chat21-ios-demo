//
//  ChatUtil.h
//  Soleto
//
//  Created by Andrea Sponziello on 02/12/14.
//
//

#import <Foundation/Foundation.h>

@class Firebase;
@class ChatNotificationView;
@class SHPApplicationContext;
@class ChatUser;

@import Firebase;

@interface ChatUtil : NSObject

+(NSString *)conversationIdWithSender:(NSString *)sender receiver:(NSString *)receiver;// tenant:(NSString *)tenant;
//+(NSString *)conversationIdForGroup:(NSString *)groupId;
//+(NSString *)usernameOnTenant:(NSString *)tenant username:(NSString *)username;
+(FIRDatabaseReference *)conversationRefForUser:(NSString *)userId conversationId:(NSString *)conversationId;
+(FIRDatabaseReference *)conversationMessagesRef:(NSString *)conversationId;

// firebase paths
+(NSString *)conversationPathForUser:(NSString *)user_id conversationId:(NSString *)conversationId;
+(NSString *)conversationsPathForUserId:(NSString *)user_id;
+(NSString *)contactsPath;
+(NSString *)groupsPath;
+(NSString *)mainGroupsPath;
// +(FIRDatabaseReference *)groupsRefWithBase:(NSString *)baseRefURL;
+(void)showNotificationWithMessage:(NSString *)message image:(UIImage *)image sender:(NSString *)sender senderFullname:(NSString *)senderFullname;

+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient;
+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient sendMessage:(NSString *)message;
+(void)moveToConversationViewWithGroup:(NSString *)groupid;
+(void)moveToConversationViewWithGroup:(NSString *)groupid sendMessage:(NSString *)message;
+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient orGroup:(NSString *)groupid sendMessage:(NSString *)message attributes:(NSDictionary *)attributes;

+(NSMutableDictionary *)groupMembersAsDictionary:(NSArray *)membersArray;
+(NSMutableArray *)groupMembersAsArray:(NSDictionary *)membersDictionary;
+(NSString *)groupMembersAsStringForUI:(NSDictionary *)membersDictionary;
+(NSString *)randomString:(NSInteger)length;

+(NSString *)groupImagesRelativePath;
+(NSString *)groupImageDownloadUrl;
+(NSString *)groupImageDeleteUrl;
+(NSString *)groupImageUrlById:(NSString *)imageID;
+(NSString *)imageIDFilename:(NSString *)imageID;
+(NSString *)userPath:(NSString *)userId;
+(NSString *)sanitizedNode:(NSString *)node_name;
+(NSString *)sanitizedUserId:(NSString *)userId;

@end
