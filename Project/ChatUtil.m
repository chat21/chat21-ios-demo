//
//  ChatUtil.m
//  Soleto
//
//  Created by Andrea Sponziello on 02/12/14.
//
//

#import "ChatUtil.h"
#import <Firebase/Firebase.h>
#import "ChatConversation.h"
#import "ChatManager.h"
//#import "NotificationAlertVC.h"
#import "NotificationAlertView.h"
#import "SHPApplicationContext.h"
#import "ChatRootNC.h"
#import "ChatConversationsVC.h"
#import "SHPAppDelegate.h"


//static NotificationAlertVC *notificationAlertInstance = nil;
static NotificationAlertView *notificationAlertInstance = nil;

@implementation ChatUtil

+(NotificationAlertView*)getNotificationAlertInstance {
    if (!notificationAlertInstance) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"notification_view" owner:self options:nil];
        NotificationAlertView *view = [subviewArray objectAtIndex:0];
        [view initViewWithHeight:60];
        notificationAlertInstance = view;
    }
    return notificationAlertInstance;
}

+(void)showNotificationWithMessage:(NSString *)message image:(UIImage *)image sender:(NSString *)sender senderFullname:(NSString *)senderFullname {
    
    NotificationAlertView *alert = [ChatUtil getNotificationAlertInstance];
    alert.messageLabel.text = message;
    alert.senderLabel.text = senderFullname ? senderFullname : sender;
    alert.userImage.image = image;
    alert.sender = sender;
    [alert animateShow];
}

+(NSString *)conversationIdWithSender:(NSString *)sender receiver:(NSString *)receiver {// tenant:(NSString *)tenant {
//    NSString *tenant = [ChatManager getSharedInstance].tenant;
    NSLog(@"conversationIdWithSender> sender is: %@ receiver is: %@", sender, receiver);
    NSString *sanitized_sender = [ChatUtil sanitizedNode:sender];
    NSString *sanitized_receiver = [ChatUtil sanitizedNode:receiver];
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObject:sanitized_sender];
    [users addObject:sanitized_receiver];
    NSLog(@"users 0 %@", [users objectAtIndex:0]);
    NSLog(@"users 1 %@", [users objectAtIndex:1]);
    NSArray *sortedUsers = [users sortedArrayUsingSelector:
                            @selector(localizedCaseInsensitiveCompare:)];
    //    // verify users order
    //    for (NSString *username in sortedUsers) {
    //        NSLog(@"username: %@", username);
    //    }
    NSString *conversation_id = [@"" stringByAppendingFormat:@"%@-%@", sortedUsers[0], sortedUsers[1]]; // [tenant stringByAppendingFormat:@"-%@-%@", sortedUsers[0], sortedUsers[1]];
    return  conversation_id;
}

// DEPRECATED
//+(NSString *)conversationIdForGroup:(NSString *)groupId {
//    // conversationID = "{groupID}_GROUP"
//    NSString *conversation_id = groupId;//[groupId stringByAppendingFormat:@"_GROUP"];
//    return  conversation_id;
//}

// #DEPRECATED
//+(NSString *)usernameOnTenant:(NSString *)tenant username:(NSString *)username {
//    NSString *sanitized_username = [ChatUtil sanitizedNode:username];
//    NSString *sanitized_tenant = [ChatUtil sanitizedNode:tenant];
//    return [[NSString alloc] initWithFormat:@"%@-%@", sanitized_tenant, sanitized_username];
//}

+(FIRDatabaseReference *)conversationRefForUser:(NSString *)userId conversationId:(NSString *)conversationId {
    NSString *relative_path = [self conversationPathForUser:userId conversationId:conversationId];
    FIRDatabaseReference *repoRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *conversation_ref_on_user = [repoRef child:relative_path];
    return conversation_ref_on_user;
}

+(NSString *)conversationPathForUser:(NSString *)user_id conversationId:(NSString *)conversationId {
    // path: apps/{tenant}/users/{userdId}/conversations/{conversationId}
    NSString *tenant = [ChatManager getInstance].tenant; //[settings_config objectForKey:@"tenantName"];
    NSString *conversation_path = [[NSString alloc] initWithFormat:@"apps/%@/users/%@/conversations/%@",tenant, user_id, conversationId];
    return conversation_path;
}

//+(Firebase *)conversationMessagesRef:(NSString *)conversationId settings:(NSDictionary *)settings {
+(FIRDatabaseReference *)conversationMessagesRef:(NSString *)conversationId {
    // path: apps/{tenant}/messages/{conversationId}
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *firebase_conversation_messages_ref = [[NSString alloc] initWithFormat:@"apps/%@/messages/%@",tenant, conversationId];
//    NSLog(@"##### firebase_conversation_messages_ref: %@", firebase_conversation_messages_ref);
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *messagesRef = [rootRef child:firebase_conversation_messages_ref];
    return messagesRef;
}

+(NSString *)sanitizedNode:(NSString *)node_name {
    // Firebase not accepted characters for node names must be a non-empty string and not contain:
    // . # $ [ ]
    NSString* _node_name;
    _node_name = [node_name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"#" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"$" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"[" withString:@"_"];
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"]" withString:@"_"];
    // "-", chat21 tenant - username sparator
    _node_name = [_node_name stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    
    return _node_name;
}

+(NSString *)sanitizedUserId:(NSString *)userId {
    return [ChatUtil sanitizedNode:userId];
}

//+(NSString *)buildConversationsReferenceWithTenant:(NSString *)tenant username:(NSString *)user_id baseFirebaseRef:(NSString *)baseFirebaseRef {
//    NSString *tenant_user_sender = [ChatUtil usernameOnTenant:tenant username:user_id];
//    NSLog(@"tenant-user-sender-id: %@", tenant_user_sender);
//    
//    NSString *firebase_conversations_ref = [baseFirebaseRef stringByAppendingFormat:@"/tenantUsers/%@/conversations", tenant_user_sender];
//    NSLog(@"buildConversationsReferenceWithTenant > firebase_conversations_ref: %@", firebase_conversations_ref);
//    return firebase_conversations_ref;
//}

+(NSString *)conversationsPathForUserId:(NSString *)user_id {
    // path: apps/{tenant}/users/{userId}/conversations
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *conversations_path = [[NSString alloc] initWithFormat:@"/apps/%@/users/%@/conversations", tenant, user_id];
    NSLog(@"buildConversationsReferenceWithTenant > firebase_conversations_ref: %@", conversations_path);
    return conversations_path;
}

// +(FIRDatabaseReference *)groupsRefWithBase:(NSString *)firebasePath {
//     FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
//     NSString *groups_path = [ChatUtil groupsPath];
//     FIRDatabaseReference *firebase_groups_ref = [rootRef child:groups_path];
//     return firebase_groups_ref;
// }

+(NSString *)mainGroupsPath {
    NSString *tenant = [ChatManager getInstance].tenant;
//    NSString *userid = [ChatManager getSharedInstance].loggedUser.userId;
    //NSString *path = [[NSString alloc] initWithFormat:@"/apps/%@/users/%@/groups", tenant, userid];
    NSString *path = [[NSString alloc] initWithFormat:@"/apps/%@/groups", tenant];
    return path;
}

+(NSString *)groupsPath {
    ChatManager *chat = [ChatManager getInstance];
    NSString *tenant = chat.tenant;
    NSString *userid = chat.loggedUser.userId;
    NSString *path = [[NSString alloc] initWithFormat:@"/apps/%@/users/%@/groups", tenant, userid];
    return path;
}

+(NSString *)contactsPath {
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *contacts_path = [[NSString alloc] initWithFormat:@"/apps/%@/contacts", tenant];
    return contacts_path;
}

+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient {
    [ChatUtil moveToConversationViewWithRecipient:recipient orGroup:nil sendMessage:nil attributes:nil];
}

+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient sendMessage:(NSString *)message {
    [ChatUtil moveToConversationViewWithRecipient:recipient orGroup:nil sendMessage:message attributes:nil];
}

+(void)moveToConversationViewWithGroup:(NSString *)groupid {
    [ChatUtil moveToConversationViewWithRecipient:nil orGroup:groupid sendMessage:nil attributes:nil];
}

+(void)moveToConversationViewWithGroup:(NSString *)groupid sendMessage:(NSString *)message {
    [ChatUtil moveToConversationViewWithRecipient:nil orGroup:groupid sendMessage:message attributes:nil];
}

+(void)moveToConversationViewWithRecipient:(ChatUser *)recipient orGroup:(NSString *)groupid sendMessage:(NSString *)message attributes:(NSDictionary *)attributes {
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController"];
    NSLog(@"processRemoteNotification: messages_tab_index %d", chat_tab_index);
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSLog(@"Current tab bar controller selectedIndex: %lu", (unsigned long)tabController.selectedIndex);
        NSArray *controllers = [tabController viewControllers];
        UIViewController *currentVc = [controllers objectAtIndex:tabController.selectedIndex];
        [currentVc dismissViewControllerAnimated:NO completion:nil];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        NSLog(@"openConversationWithRecipient:%@ orGroup: %@ sendText:%@", recipient.userId, groupid, message);
        tabController.selectedIndex = chat_tab_index;
        [nc openConversationWithRecipient:recipient orGroup:groupid sendMessage:message attributes:attributes];
    } else {
        NSLog(@"No Chat Tab configured");
    }
}

//    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
//    // move to the converstations tab
//    if (chat_tab_index >= 0) {
//        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
//        NSArray *controllers = [tabController viewControllers];
//        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
//        [nc popToRootViewControllerAnimated:NO];
//        [nc openConversationWithRecipient:user sendText:message];
//        tabController.selectedIndex = chat_tab_index;
//    }

// at creation time from array (memory, UI) to dictionary (firebase)
+(NSMutableDictionary *)groupMembersAsDictionary:(NSArray *)membersArray {
    NSMutableDictionary *membersDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *memberId in membersArray) {
        [membersDictionary setObject:memberId forKey:memberId];
    }
    return membersDictionary;
}

// at download time from dictionary (firebase) to array (memory)
+(NSMutableArray *)groupMembersAsArray:(NSDictionary *)membersDictionary {
    NSMutableArray *membersArray = [[NSMutableArray alloc] init];
    for(id key in membersDictionary) {
        id value = [membersDictionary objectForKey:key];
        [membersArray addObject:value];
    }
    return membersArray;
}

+(NSString *)groupMembersAsStringForUI:(NSDictionary *)membersDictionary {
    if (membersDictionary.count == 0) {
        return @"";
    }
    NSArray *keys = [membersDictionary allKeys];
    NSString *members_string = [keys objectAtIndex:0];
    for (int i = 1; i < keys.count; i++) {
        NSString *member = (NSString *)keys[i];
        NSString *m_to_add = [[NSString alloc] initWithFormat:@", %@", member];
        members_string = [members_string stringByAppendingString:m_to_add];
    }
    return members_string;
}

+(NSString *)randomString:(NSInteger)length {
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

+(NSString *)userPath:(NSString *)userId {
    // path: apps/{tenant}/users/{userId}
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *user_path = [[NSString alloc] initWithFormat:@"/apps/%@/users/%@", tenant, userId];
    return user_path;
}

// ****** GROUP IMAGES ******

+(NSString *)groupImagesRelativePath {
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *plistDictionary = appDelegate.applicationContext.plistDictionary;
    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Images"];
    NSString *imagesPath = [settingsDictionary objectForKey:@"groupImagesPath"];
    return imagesPath;
}

// cloudinary
//+(NSString *)groupBaseImagesUrl {
//    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSDictionary *plistDictionary = appDelegate.applicationContext.plistDictionary;
//    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Images"];
//    NSString *serviceURL = [settingsDictionary objectForKey:@"service"];
//    NSString *imagesPath = [settingsDictionary objectForKey:@"groupImagesPath"];
//    NSString *url = [[NSString alloc] initWithFormat:@"%@%@", serviceURL, imagesPath];
//    return url;
//}

// smart21
+(NSString *)groupImageDownloadUrl {
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *plistDictionary = appDelegate.applicationContext.plistDictionary;
    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Images"];
    NSString *serviceURL = [settingsDictionary objectForKey:@"smart21ServiceDownload"];
    
    NSString *imagesPath = [ChatUtil groupImagesRelativePath];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@", serviceURL, imagesPath];
    
    return url;
}

+(NSString *)groupImageDeleteUrl {
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *plistDictionary = appDelegate.applicationContext.plistDictionary;
    NSDictionary *settingsDictionary = [plistDictionary objectForKey:@"Images"];
    NSString *serviceURL = [settingsDictionary objectForKey:@"smart21ServiceDelete"];
    
    NSString *imagesPath = [ChatUtil groupImagesRelativePath];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@", serviceURL, imagesPath];
    
    return url;
}

+(NSString *)groupImageUrlById:(NSString *)imageID {
//    NSString *name = [NSString stringWithFormat:@"%@.png", imageID];
    NSString *name = [ChatUtil imageIDFilename:imageID];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/%@", [ChatUtil groupImageDownloadUrl], name];
    return url;
}

+(NSString *)imageIDFilename:(NSString *)imageID {
    NSString *name = [NSString stringWithFormat:@"%@.jpg", imageID];
    return name;
}

// ****** END GROUP IMAGES *****

@end
