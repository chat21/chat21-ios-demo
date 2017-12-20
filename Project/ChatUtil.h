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
@class ChatUser;

@import Firebase;

@interface ChatUtil : NSObject

+(FIRDatabaseReference *)conversationRefForUser:(NSString *)userId conversationId:(NSString *)conversationId;
+(FIRDatabaseReference *)conversationMessagesRef:(NSString *)recipient_id;

// firebase paths
+(NSString *)conversationPathForUser:(NSString *)user_id conversationId:(NSString *)conversationId;
+(NSString *)conversationsPathForUserId:(NSString *)user_id;
+(NSString *)contactsPath;
+(NSString *)contactPathOfUser:(NSString *)userid;
+(NSString *)groupsPath;
+(NSString *)mainGroupsPath;
+(void)showNotificationWithMessage:(NSString *)message image:(UIImage *)image sender:(NSString *)sender senderFullname:(NSString *)senderFullname;

+(void)moveToConversationViewWithUser:(ChatUser *)user;
+(void)moveToConversationViewWithUser:(ChatUser *)user sendMessage:(NSString *)message;
+(void)moveToConversationViewWithGroup:(NSString *)groupid;
+(void)moveToConversationViewWithGroup:(NSString *)groupid sendMessage:(NSString *)message;
+(void)moveToConversationViewWithUser:(ChatUser *)user orGroup:(NSString *)groupid sendMessage:(NSString *)message attributes:(NSDictionary *)attributes;

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
