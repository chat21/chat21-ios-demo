//
//  ChatConversationHandler.m
//  Soleto
//
//  Created by Andrea Sponziello on 19/12/14.
//
//

#import "ChatConversationHandler.h"
//#import <Firebase/Firebase.h>
#import "ChatMessage.h"
#import "FirebaseCustomAuthHelper.h"
//#import "SHPUser.h"
//#import "SHPFirebaseTokenDC.h"
#import "ChatUtil.h"
#import "ChatDB.h"
#import "ChatConversation.h"
#import "SHPChatDelegate.h"
//#import "SHPPushNotificationService.h"
//#import "SHPPushNotification.h"
#import "ChatManager.h"
#import "ChatGroup.h"
//#import "ParseChatNotification.h"
//#import "ChatParsePushService.h"
#import "SHPApplicationContext.h"
#import "ChatUser.h"

@implementation ChatConversationHandler

-(id)initWithRecipient:(NSString *)recipientId recipientFullName:(NSString *)recipientFullName user:(ChatUser *)user {
    if (self = [super init]) {
        self.recipientId = recipientId;
        self.recipientFullname = recipientFullName;
        self.user = user;
        self.senderId = user.userId;
        self.conversationId = recipientId; //[ChatUtil conversationIdWithSender:user.userId receiver:recipient]; //conversationId;
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithGroupId:(NSString *)groupId user:(ChatUser *)user {
    if (self = [super init]) {
        self.groupId = groupId;
        self.user = user;
        self.senderId = user.userId;
        self.conversationId = groupId; //conversationId;
        self.messages = [[NSMutableArray alloc] init];
    }
    return self;
}

// ChatGroupsDelegate delegate
-(void)groupAddedOrChanged:(ChatGroup *)group {
    NSLog(@"Group added or changed delegate. Group name: %@", group.name);
    if (![group.groupId isEqualToString:self.groupId]) {
        return;
    }
    if ([group isMember:self.user.userId]) {
        [self connect];
        [self.delegateView groupConfigurationChanged:group];
    }
    else {
        [self dispose];
        [self.delegateView groupConfigurationChanged:group];
    }
}

//-(id)init {
//    if (self = [super init]) {
//        //
//    }
//    return self;
//}

//- (void)connect {
//    NSLog(@"Firebase login...");
////    [self firebaseLogin];
//    [self setupConversation];
//}

-(void)dispose {
//    [self.messagesRef removeObserverWithHandle:self.messages_ref_handle];
//    [self.messagesRef removeObserverWithHandle:self.updated_messages_ref_handle];
//    self.messages_ref_handle = 0;
//    self.updated_messages_ref_handle = 0;
    [self.messagesRef removeAllObservers];
}

-(void)restoreMessagesFromDB {
    NSLog(@"RESTORING ALL MESSAGES FOR CONVERSATION %@", self.conversationId);
    NSArray *inverted_messages = [[[ChatDB getSharedInstance] getAllMessagesForConversation:self.conversationId start:0 count:40] mutableCopy];
    NSLog(@"DB MESSAGES NUMBER: %lu", (unsigned long) inverted_messages.count);
    NSLog(@"Last 40 messages restored...");
//    NSLog(@"Reversing array...");
    NSEnumerator *enumerator = [inverted_messages reverseObjectEnumerator];
    for (id element in enumerator) {
        [self.messages addObject:element];
    }
    
    // set as status:"failed" all the messages in status: "sending"
    for (ChatMessage *m in self.messages) {
        if (m.status == MSG_STATUS_SENDING) {
            m.status = MSG_STATUS_FAILED;
        }
    }
}

//-(void)updateMemoryFromDB {
//    NSLog(@"UPDATE DB > MEMORY ALL MESSAGES FOR CONVERSATION %@", self.conversationId);
//    int count = (int) self.messages.count + 1;
//    [self.messages removeAllObjects];
//    NSArray *inverted_messages = [[[ChatDB getSharedInstance] getAllMessagesForConversation:self.conversationId start:0 count:count] mutableCopy];
//    NSLog(@"DB MESSAGES NUMBER: %lu", (unsigned long) inverted_messages.count);
//    NSLog(@"Last %d messages restored...", count);
//    NSLog(@"Reversing array...");
//    NSEnumerator *enumerator = [inverted_messages reverseObjectEnumerator];
//    for (id element in enumerator) {
//        [self.messages addObject:element];
//    }
//}

//-(void)firebaseLogin {
//    SHPFirebaseTokenDC *dc = [[SHPFirebaseTokenDC alloc] init];
//    dc.delegate = self;
//    [dc getTokenWithParameters:nil withUser:self.user];
//}

//-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error {
//    if (token) {
//        NSLog(@"Auth Firebase ok. Token: %@", token);
//        self.firebaseToken = token;
//        [self setupConversation];
//    } else {
//        NSLog(@"Auth Firebase error: %@", error);
//    }
//    [self.delegateView didFinishInitConversationHandler:self error:error];
//}

-(void)connect {
    NSLog(@"Setting up references' connections with firebase using token: %@", self.firebaseToken);
    if (self.messages_ref_handle) {
        NSLog(@"Trying to re-open messages_ref_handle %ld while already open. Returning.", self.messages_ref_handle);
        return;
    }
    self.messagesRef = [ChatUtil conversationMessagesRef:self.recipientId];
    
    // AUTHENTICATION DISABLED FOR THE MOMENT!
//    [self initFirebaseWithRef:self.messagesRef token:self.firebaseToken];
    
    
    self.conversationOnSenderRef = [ChatUtil conversationRefForUser:self.senderId conversationId:self.conversationId];
    self.conversationOnReceiverRef = [ChatUtil conversationRefForUser:self.recipientId conversationId:self.conversationId];
    
    NSInteger lasttime = 0;
    if (self.messages && self.messages.count > 0) {
        ChatMessage *message = [self.messages lastObject];
        NSLog(@"****** MOST RECENT MESSAGE TIME %@ %@", message, message.date);
        lasttime = message.date.timeIntervalSince1970 * 1000; // objc return time in seconds, firebase saves time in milliseconds. queryStartingAtValue: will respond to events at nodes with a value greater than or equal to startValue. So seconds is always < then milliseconds. * 1000 translates seconds in millis and the query is ok.
    } else {
        lasttime = 0;
    }
    
    self.messages_ref_handle = [[[self.messagesRef queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(lasttime)] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        // IMPORTANT: This callback is called also for newly locally created messages not still sent.
        NSLog(@">>>> NEW MESSAGE SNAPSHOT: %@", snapshot);
        ChatMessage *message = [ChatMessage messageFromSnapshotFactory:snapshot];
        message.conversationId = self.conversationId; // DB query is based on this attribute!!! (conversationID = Interlocutor)
        
        // IMPORTANT (REPEATED)! This callback is called ALSO (and NOT ONLY) for newly locally created messages not still sent (called also with network off!).
        // Then, for every "new" message received (also locally generated) we update the conversation data & his status to "read" (is_new: NO).
        
        // updates status only of messages not sent by me
        // HO RICEVUTO UN MESSAGGIO NUOVO
        NSLog(@"self.senderId: %@", self.senderId);
        if (message.status < MSG_STATUS_RECEIVED && ![message.sender isEqualToString:self.senderId]) { // CONTROLLO "message.status < MSG_STATUS_RECEIVED &&" IN MODO DA EVITARE IL COSTO DI RI-AGGIORNARE CONTINUAMENTE LO STATO DI MESSAGGI CHE HANNO GIA LO STATO RECEIVED (MAGARI E' LA SINCRONIZZAZIONE DI UN NUOVO DISPOSITIVO CHE NON DEVE PIU' COMUNICARE NULLA AL MITTENTE MA SOLO SCARICARE I MESSAGGI NELLO STATO IN CUI SI TROVANO).
            // NOT RECEIVED = NEW!
            NSLog(@"NEW MESSAGE!!!!! %@ group %@", message.text, message.recipientGroupId);
            if (!message.recipientGroupId) {
                [message updateStatusOnFirebase:MSG_STATUS_RECEIVED]; // firebase
            } else {
                NSLog(@"No received status for group's messages");
            }
        }
        // updates or insert new messages
        // Note: a last message is always resent. So this check to avoid this notified as new (...playing sound etc.)
        ChatMessage *message_archived = [[ChatDB getSharedInstance] getMessageById:message.messageId];
        NSLog(@"messa.attr 5 %@", message.attributes);
        if (!message_archived) {
            NSLog(@"*** message not archived");
            NSLog(@"messa.attr 6 %@", message.attributes);
            [self insertMessageInMemory:message]; // memory
            [self finishedReceivingMessage:message];
            [self insertMessageOnDBIfNotExists:message];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
//    self.updated_messages_ref_handle = [[self.messagesRef queryLimitedToLast:10] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@">>>> new UPDATED message snapshot %@", snapshot);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
    self.updated_messages_ref_handle = [self.messagesRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@">>>> new UPDATED message snapshot %@", snapshot);
        ChatMessage *message = [ChatMessage messageFromSnapshotFactory:snapshot];
        if (message.status == MSG_STATUS_SENDING) {
            NSLog(@"Queed message updated. Data saved successfully.");
            int status = MSG_STATUS_SENT;
            [self updateMessageStatusInMemory:message.messageId withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else if (message.status == MSG_STATUS_RETURN_RECEIPT) {
            NSLog(@"Message update: return receipt.");
            [self updateMessageStatusInMemory:message.messageId withStatus:message.status];
            [self updateMessageStatusOnDB:message.messageId withStatus:message.status];
            [self finishedReceivingMessage:message];
//            [self sendReadNotificationForMessage:message];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

//-(void) initFirebaseWithRef:(FIRDatabaseReference *)ref token:(NSString *)token {
//    self.authHelper = [[FirebaseCustomAuthHelper alloc] initWithFirebaseRef:ref token:token];
//    NSLog(@"ok111");
//    [self.authHelper authenticate:^(NSError *error, FAuthData *authData) {
//        NSLog(@"authData: %@", authData);
//        if (error != nil) {
//            NSLog(@"There was an error authenticating.");
//        } else {
//            NSLog(@"authentication success %@", authData);
//        }
//    }];
//}

//-(void)sendReadNotificationForMessage:(ChatMessage *)message {
//    double now = [[NSDate alloc] init].timeIntervalSince1970;
//    if (now - self.lastSentReadNotificationTime < 10) {
//        NSLog(@"TOO EARLY TO SEND A NOTIFICATION FOR THIS MESSAGE: %@", message.text);
//        return;
//    }
//    NSLog(@"SENDING READ NOTIFICATION TO: %@ FOR MESSAGE: %@", message.sender, message.text);
//    // PARSE NOTIFICATION
//    ParseChatNotification *notification = [[ParseChatNotification alloc] init];
//    notification.senderUser = self.user.userId; //[self.user.username stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//    notification.senderUserFullname = self.user.fullname;
//    notification.toUser = message.sender;
//    notification.alert = [[NSString alloc] initWithFormat:@"%@ ha ricevuto il messaggio", message.recipient];
//    notification.conversationId = message.conversationId;
//    notification.badge = @"-1";
//    ChatParsePushService *push_service = [[ChatParsePushService alloc] init];
//    [push_service sendNotification:notification];
//    // END PARSE NOTIFICATION
//    self.lastSentReadNotificationTime = now;
//}

-(ChatMessage *)newBaseMessage {
    ChatMessage *message = [[ChatMessage alloc] init];
    message.sender = self.senderId;
    message.senderFullname = self.user.fullname;
    NSDate *now = [[NSDate alloc] init];
    message.date = now;
    message.status = MSG_STATUS_SENDING;
    message.conversationId = self.conversationId; // = intelocutor-id, for local-db queries
    NSString *langID = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    message.lang = langID;
    return message;
}

-(void)sendMessageWithText:(NSString *)text type:(NSString *)type attributes:(NSDictionary *)attributes {
    ChatMessage *message = [self newBaseMessage];
    if (text) {
        message.text = text;
    }
    message.mtype = type;
    message.attributes = attributes;
    if (self.groupId) {
        NSLog(@"SENDING MESSAGE IN GROUP MODE. User: %@", [FIRAuth auth].currentUser.uid);
        message.recipientGroupId = self.groupId;
        [self sendMessageToGroup:message];
    } else {
        NSLog(@"SENDING MESSAGE DIRECT MODE. User: %@", [FIRAuth auth].currentUser.uid);
        message.recipient = self.recipientId;
        message.recipientFullName = self.recipientFullname;
        [self sendDirect:message];
    }
}

-(void)sendMessage:(NSString *)text {
    [self sendMessageWithText:text type:MSG_TYPE_TEXT attributes:nil];
}

-(void)sendDirect:(ChatMessage *)message {
    // create firebase reference
    FIRDatabaseReference *messageRef = [self.messagesRef childByAutoId]; // CHILD'S AUTOGEN UNIQUE ID
    message.messageId = messageRef.key;
    
    // save message locally
    [self insertMessageInMemory:message];
    [self insertMessageOnDBIfNotExists:message];
    [self finishedReceivingMessage:message]; // TODO messageArrived
    
    // save message to firebase
    NSMutableDictionary *message_dict = [ChatConversationHandler firebaseMessageFor:message];
    NSLog(@"Sending message to Firebase: %@ %@ %d", message.text, message.messageId, message.status);
    [messageRef setValue:message_dict withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        NSLog(@"messageRef.setValue callback. %@", message_dict);
        if (error) {
            NSLog(@"Data could not be saved because of an occurred error: %@", error);
            int status = MSG_STATUS_FAILED;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else {
            NSLog(@"Data saved successfully. Updating status & reloading tableView.");
            int status = MSG_STATUS_SENT;
            NSAssert([ref.key isEqualToString:message.messageId], @"REF.KEY %@ different by MESSAGE.ID %@",ref.key, message.messageId);
            [self updateMessageStatusInMemory:message.messageId withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
            
//            NSLog(@"Updating conversations sender %@ recipient %@", self.senderId, self.recipient);
            // updates conversations
//            // Sender-side conversation
//            ChatManager *chat = [ChatManager getInstance];
//            ChatConversation *senderConversation = [[ChatConversation alloc] init];
//            senderConversation.ref = self.conversationOnSenderRef;
//            senderConversation.last_message_text = message.text;
//            senderConversation.is_new = NO;
//            senderConversation.date = message.date;
//            senderConversation.sender = message.sender;
//            senderConversation.senderFullname = message.senderFullname;
//            senderConversation.recipient = self.recipient;
//            senderConversation.conversWith_fullname = self.recipientFullname;
//            senderConversation.groupName = self.groupName;
//            senderConversation.groupId = self.groupId;
//            senderConversation.status = CONV_STATUS_LAST_MESSAGE;
//            [chat createOrUpdateConversation:senderConversation];
            
//            // Recipient-side: the conversation is new. It becomes !new immediately after the "tap" in recipent-side's converations-list.
//            ChatConversation *receiverConversation = [[ChatConversation alloc] init];
//            receiverConversation.ref = self.conversationOnReceiverRef;
//            receiverConversation.last_message_text = message.text;
//            receiverConversation.is_new = YES;
//            receiverConversation.date = message.date;
//            receiverConversation.sender = message.sender;
//            receiverConversation.senderFullname = message.senderFullname;
//            receiverConversation.recipient = self.recipient;
//            receiverConversation.conversWith_fullname = self.user.fullname;
//            receiverConversation.groupName = self.groupName;
//            receiverConversation.groupId = self.groupId;
//            receiverConversation.status = CONV_STATUS_LAST_MESSAGE;
//            [chat createOrUpdateConversation:receiverConversation];
        }
    }];
}

//-(void)sendMessageToGroup:(NSString *)text {
-(void)sendMessageToGroup:(ChatMessage *)message {
    // create firebase reference
    FIRDatabaseReference *messageRef = [self.messagesRef childByAutoId]; // CHILD'S AUTOGEN UNIQUE ID
    message.messageId = messageRef.key;
    // save message locally
    [self insertMessageInMemory:message];
    [self insertMessageOnDBIfNotExists:message];
    [self finishedReceivingMessage:message];
    // save message to firebase
    NSMutableDictionary *message_dict = [ChatConversationHandler firebaseMessageFor:message];
    NSLog(@"(Group) Sending message to Firebase:(%@) %@ %@ %d dict: %@",messageRef, message.text, message.messageId, message.status, message_dict);
    [messageRef setValue:message_dict withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        NSLog(@"messageRef.setValue callback. %@", message_dict);
        if (error) {
            NSLog(@"Data could not be saved with error: %@", error);
            int status = MSG_STATUS_FAILED;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
        } else {
            NSLog(@"Data saved successfully. Updating status & reloading tableView.");
            int status = MSG_STATUS_SENT;
            [self updateMessageStatusInMemory:ref.key withStatus:status];
            [self updateMessageStatusOnDB:message.messageId withStatus:status];
            [self finishedReceivingMessage:message];
            
            ChatGroup *group = [[ChatManager getInstance] groupById:self.groupId];
            
//            // send push to notification provider
//            for (NSString *memberId in group.members) {
//                NSLog(@"*** GROUP NOTIFICATION:%@/%@. Message: %@, member: %@",group.name, group.groupId, message.text, memberId);
//                if (![memberId isEqualToString:self.senderId]) {
//                    // PARSE NOTIFICATION
//                    NSLog(@"Sending notification for message: %@ to %@", message.text, memberId);
//                    ParseChatNotification *notification = [[ParseChatNotification alloc] init];
//                    notification.senderUser = @"";
//                    notification.toUser = memberId;
//                    NSString *displayName = (message.senderFullname && message.senderFullname.length > 0) ? message.senderFullname : message.sender;
//                    notification.alert = [[NSString alloc] initWithFormat:@"%@ \"%@\":\n%@", displayName, group.name, message.text];
//                    notification.conversationId = group.groupId;
//                    notification.badge = @"1";
//                    ChatParsePushService *push_service = [[ChatParsePushService alloc] init];
//                    [push_service sendNotification:notification];
//                    // END PARSE NOTIFICATION
//                } else {
//                    NSLog(@"NOT Sending notification to me: %@ for message: %@", self.senderId, message.text);
//                }
//            }
            
            NSLog(@"Updating conversations of group's members...");
            
            // updates conversations
            
            // Sender-side conversation
            ChatManager *chat = [ChatManager getInstance];
            
            ChatConversation *senderConversation = [[ChatConversation alloc] init];
            senderConversation.ref = self.conversationOnSenderRef;
            senderConversation.last_message_text = message.text;
            senderConversation.is_new = NO;
            senderConversation.date = message.date;
            senderConversation.sender = message.sender;
            senderConversation.senderFullname = message.senderFullname;
            senderConversation.groupName = group.name;
            senderConversation.groupId = group.groupId;
            senderConversation.status = CONV_STATUS_LAST_MESSAGE;
            
            [chat createOrUpdateConversation:senderConversation];
            
            // Recipient-side: the conversation is new. It becomes !new immediately after the "tap" in recipent-side's converations-list.
            NSLog(@"AGGIORNO LA CONVERSAZIONE DEI MEMBRI RICEVENTI CON IS_NEW = SI");
            
            for (NSString *memberId in group.members) {
                NSLog(@"AGGIORNO CONVERSAZIONE DI %@", memberId);
                FIRDatabaseReference *conversationOnMember = [ChatUtil conversationRefForUser:memberId conversationId:self.conversationId];
                
                ChatConversation *memberConversation = [[ChatConversation alloc] init];
                memberConversation.ref = conversationOnMember;
                memberConversation.last_message_text = message.text;
                memberConversation.is_new = YES;
                memberConversation.date = message.date;
                memberConversation.sender = message.sender;
                memberConversation.senderFullname = message.senderFullname;
                memberConversation.groupName = self.groupName;
                memberConversation.groupId = self.groupId;
                memberConversation.status = CONV_STATUS_LAST_MESSAGE;
                
                [chat createOrUpdateConversation:memberConversation];
            }
            NSLog(@"Finished updating group conversations...");
        }
    }];
}

+(NSMutableDictionary *)firebaseMessageFor:(ChatMessage *)message {
    // firebase message dictionary
    NSMutableDictionary *message_dict = [[NSMutableDictionary alloc] init];
//    NSNumber *msg_timestamp = [NSNumber numberWithDouble:[message.date timeIntervalSince1970]];
    // always
//    [message_dict setObject:message.conversationId forKey:MSG_FIELD_CONVERSATION_ID];
    [message_dict setObject:message.text forKey:MSG_FIELD_TEXT];
//    [message_dict setObject:[FIRServerValue timestamp] forKey:MSG_FIELD_TIMESTAMP];
    [message_dict setObject:[NSNumber numberWithInt:message.status] forKey:MSG_FIELD_STATUS];
    
//    if (message.sender) {
//        NSString *sanitezed_sender = [message.sender stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//        [message_dict setObject:sanitezed_sender forKey:MSG_FIELD_SENDER];
//    }
    
    if (message.senderFullname) {
        [message_dict setObject:message.senderFullname forKey:MSG_FIELD_SENDER_FULLNAME];
    }
    
    if (message.recipientFullName) {
        [message_dict setObject:message.recipientFullName forKey:MSG_FIELD_RECIPIENT_FULLNAME];
    }
    
    if (message.mtype) {
        [message_dict setObject:message.mtype forKey:MSG_FIELD_TYPE];
    }
    
    if (message.attributes) {
        [message_dict setObject:message.attributes forKey:MSG_FIELD_ATTRIBUTES];
    }
    
    if (message.lang) {
        [message_dict setObject:message.lang forKey:MSG_FIELD_LANG];
    }
    
    // only if one-to-one
//    if (message.recipient) {
//        NSString *sanitezed_recipient = [message.recipient stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//        [message_dict setValue:sanitezed_recipient forKey:MSG_FIELD_RECIPIENT];
//    }
    
    // only if group
//    if (message.recipientGroupId) {
//        [message_dict setValue:message.recipientGroupId forKey:MSG_FIELD_RECIPIENT_GROUP_ID];
//    }
    return message_dict;
}

// Updates a just-sent memory-message with the new status: MSG_STATUS_FAILED or MSG_STATUS_SENT
-(void)updateMessageStatusInMemory:(NSString *)messageId withStatus:(int)status {
    for (ChatMessage* msg in self.messages) {
        if([msg.messageId isEqualToString: messageId]) {
            NSLog(@"message found, updating status %d", status);
            msg.status = status;
            break;
        }
    }
}

-(void)updateMessageStatusOnDB:(NSString *)messageId withStatus:(int)status {
    [[ChatDB getSharedInstance] updateMessage:messageId withStatus:status];
}

-(void)insertMessageOnDBIfNotExists:(ChatMessage *)message {
    NSLog(@"******* saving on db %@", message.attributes);
    [[ChatDB getSharedInstance] insertMessageIfNotExists:message];
}

-(void)insertMessageInMemory:(ChatMessage *)message {
    // find message...
    BOOL found = NO;
    for (ChatMessage* msg in self.messages) {
        if([msg.messageId isEqualToString: message.messageId]) {
            NSLog(@"message found, skipping insert");
            found = YES;
            break;
        }
    }
    
    if (found) {
        return;
    }
    else {
        NSUInteger newIndex = [self.messages indexOfObject:message
                                     inSortedRange:(NSRange){0, [self.messages count]}
                                           options:NSBinarySearchingInsertionIndex
                                           usingComparator:^NSComparisonResult(id a, id b) {
                                               NSDate *first = [(ChatMessage *)a date];
                                               NSDate *second = [(ChatMessage *)b date];
                                               return [first compare:second];
                                           }];
        [self.messages insertObject:message atIndex:newIndex];
    }
//    // TODO: i messaggi offline del mittente, ricevuti dopo l'invio di messaggi da parte
//    // del mittente, non vengono inseriti. Procedere
////    NSLog(@"THIS MESSAGE -%@- DATE: %@ TIME: %f",message.text, message.date, message.date.timeIntervalSince1970);
//    NSInteger new_msg_time = message.date.timeIntervalSince1970;
//    ChatMessage *last_message = [self.messages lastObject];
//    NSInteger last_msg_time = last_message.date.timeIntervalSince1970;
////    NSLog(@"***** > Before adding, verifying last message -%@- date: %@, time: %ld",message.text, lastmessage.date, lasttime);
//    if (new_msg_time > last_msg_time) {
////        NSLog(@"OK. newtime > lasttime. ADDING THIS MESSAGE: %@", message.text);
//        [self.messages addObject:message];
//    }

}

-(void)finishedReceivingMessage:(ChatMessage *)message {
    NSLog(@"ConversationHandler: Finished receiving message %@ on delegate: %@",message.text, self.delegateView);
    if (self.delegateView) {
        [self.delegateView finishedReceivingMessage:message];
    }
}

@end
