//
//  ChatConversationsHandler.m
//  Soleto
//
//  Created by Andrea Sponziello on 29/12/14.
//
//

#import "ChatConversationsHandler.h"
#import "SHPFirebaseTokenDC.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "ChatUtil.h"
#import <Firebase/Firebase.h>
#import "ChatConversation.h"
#import "SHPConversationsViewDelegate.h"
#import "ChatDB.h"
#import "ChatManager.h"
#import "ChatUser.h"

//#import "FirebaseCustomAuthHelper.h"

@implementation ChatConversationsHandler

//-(id)initWith:(SHPApplicationContext *)applicationContext delegateView:(id<SHPConversationsViewDelegate>)delegateView {
//    if (self = [super init]) {
//        self.applicationContext = applicationContext;
//        self.me = self.applicationContext.loggedUser.username;
//        self.delegateView = delegateView;
//        
//        self.conversations = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

-(id)initWithTenant:(NSString *)tenant user:(ChatUser *)user {
    if (self = [super init]) {
        //        self.firebaseRef = firebaseRef;
        self.rootRef = [[FIRDatabase database] reference];
        self.tenant = tenant;
        self.loggeduser = user;
        self.me = user.userId;
        self.conversations = [[NSMutableArray alloc] init];
    }
    return self;
}

//-(id)initWithTenant:(NSString *)tenant user:(SHPUser *)user {
//    if (self = [super init]) {
////        self.firebaseRef = firebaseRef;
//        self.rootRef = [[FIRDatabase database] reference];
//        self.tenant = tenant;
//        self.loggeduser = user;
//        self.me = [ChatUtil sanitizedUserId:user.username];
//        self.conversations = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

//-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user {
//    if (self = [super init]) {
//        self.firebaseRef = firebaseRef;
//        self.tenant = tenant;
//        self.loggeduser = user;
//        self.me = user.username;
//        self.conversations = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

- (void)connect {
//    NSLog(@"Firebase login with username %@...", self.me);
//    if (!self.me) {
//        NSLog(@"ERROR: First set .me property with a valid username.");
//    }
//    [self firebaseLogin];
//    NSLog(@"connecting handler %@ to firebase: %@", self, self.firebaseRef);
    [self setupConversations];
}

-(void)printAllConversations {
    NSLog(@"***** CONVERSATIONS DUMP **************************");
    self.conversations = [[[ChatDB getSharedInstance] getAllConversations] mutableCopy];
    for (ChatConversation *c in self.conversations) {
        NSLog(@"user: %@ id:%@ converswith:%@ sender:%@ recipient:%@",c.user, c.conversationId, c.conversWith, c.sender, c.recipient);
    }
    NSLog(@"******************************* END.");
}

-(NSMutableArray *)restoreConversationsFromDB {
    self.conversations = [[[ChatDB getSharedInstance] getAllConversationsForUser:self.me] mutableCopy];
    for (ChatConversation *c in self.conversations) {
        NSLog(@"restored conv user: %@, id: %@, last_message_text: %@",c.user, c.conversationId, c.last_message_text);
        if (c.conversationId) {
            FIRDatabaseReference *conversation_ref = [self.conversationsRef child:c.conversationId];
            c.ref = conversation_ref;
        }
        else {
            NSLog(@"ERROR restoring conv c: %@ id: %@, groupName: %@ groupId: %@ last_message_text: %@",c, c.conversationId, c.groupName, c.groupId, c.last_message_text);
        }
        
    }
    return self.conversations;
}

// ATTENZIONE: UTILIZZATO?????
//-(void)firebaseLogin {
//    //NSString *asdas;
//    SHPFirebaseTokenDC *dc = [[SHPFirebaseTokenDC alloc] init];
//    dc.delegate = self;
//    [dc getTokenWithParameters:nil withUser:self.loggeduser];
//}

// ATTENZIONE: UTILIZZATO?????
//-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error {
//    if (token) {
//        NSLog(@"Chat Conversations Firebase Auth ok. Token: %@", token);
//        self.firebaseToken = token;
//        [self setupConversations];
//    } else {
//        NSLog(@"Auth Firebase error: %@", error);
//    }
//    [self.delegateView didFinishConnect:self error:error];
//}

-(void)setupConversations {
    NSLog(@"Setting up conversations for handler %@ on delegate %@", self, self.delegateView);
    ChatManager *chat = [ChatManager getInstance];
    NSString *conversations_path = [ChatUtil conversationsPathForUserId:self.loggeduser.userId];
    NSLog(@"firebase_conversations_ref: %@", conversations_path);
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    self.conversationsRef = [rootRef child: conversations_path];
    [self.conversationsRef keepSynced:YES];
    NSLog(@"creating conversations_ref_handle_ADDED...");
    
    self.conversations_ref_handle_added = [[self.conversationsRef queryOrderedByChild:@"timestamp"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"NEW CONVERSATION SNAPSHOT: %@", snapshot);
        ChatConversation *conversation = [ChatConversation conversationFromSnapshotFactory:snapshot me:self.loggeduser];
        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
            // changes (forces) the "is_new" flag to FALSE;
            conversation.is_new = NO;
            FIRDatabaseReference *conversation_ref = [self.conversationsRef child:conversation.conversationId];
            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
        }
        if (conversation.status == CONV_STATUS_FAILED) {
            // a remote conversation can't be in failed status. force to last_message status
            // if the sender WRONGLY set the conversation STATUS to 0 this will block the access to the conversation.
            // IN FUTURE SERVER-SIDE HANDLING OF MESSAGE SENDING, WILL BE THE SERVER-SIDE SCRIPT RESPONSIBLE OF SETTING THE CONV STATUS AND THIS VERIFICATION CAN BE REMOVED.
            conversation.status = CONV_STATUS_LAST_MESSAGE;
        }
        [self insertOrUpdateConversationOnDB:conversation];
        [self restoreConversationsFromDB];
        [self finishedReceivingConversation:conversation];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    NSLog(@"creating conversations_ref_handle_CHANGED...");
    
    self.conversations_ref_handle_changed =
    [self.conversationsRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
//        NSLog(@"************************* CONVERSATION UPDATED ****************************");
        NSLog(@"CHANGED CONVERSATION snapshot............... %@", snapshot);
        ChatConversation *conversation = [ChatConversation conversationFromSnapshotFactory:snapshot me:self.loggeduser];
        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
            // changes (forces) the "is_new" flag to FALSE;
            conversation.is_new = NO;
            FIRDatabaseReference *conversation_ref = [self.conversationsRef child:conversation.conversationId];
            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
        }
        // CONVERSATIONS NON INSERISCE IN MEMORIA MA RECUPERA TUTTE LE CONV DAL DB
        // AD OGNI NUOVO ARRIVO/AGGIORNAMENTO
        [self insertOrUpdateConversationOnDB:conversation];
        [self restoreConversationsFromDB];
        [self finishedReceivingConversation:conversation];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    self.conversations_ref_handle_removed =
    [self.conversationsRef observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"************************* CONVERSATION REMOVED ****************************");
        NSLog(@"REMOVED CONVERSATION snapshot............... %@", snapshot);
        ChatConversation *conversation = [ChatConversation conversationFromSnapshotFactory:snapshot me:self.loggeduser];
        if ([self.currentOpenConversationId isEqualToString:conversation.conversationId] && conversation.is_new == YES) {
            // changes (forces) the "is_new" flag to FALSE;
            conversation.is_new = NO;
            FIRDatabaseReference *conversation_ref = [self.conversationsRef child:conversation.conversationId];
            NSLog(@"UPDATING IS_NEW=NO FOR CONVERSATION %@", conversation_ref);
            [chat updateConversationIsNew:conversation_ref is_new:conversation.is_new];
        }
        // CONVERSATIONS NON INSERISCE IN MEMORIA MA RECUPERA TUTTE LE CONV DAL DB
        // AD OGNI NUOVO ARRIVO/AGGIORNAMENTO
        [self removeConversationOnDB:conversation];
        [self restoreConversationsFromDB];
        [self finishedReceivingConversation:conversation];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)insertOrUpdateConversationOnDB:(ChatConversation *)conversation {
    conversation.user = self.me;
    [[ChatDB getSharedInstance] insertOrUpdateConversation:conversation];
}

-(void)removeConversationOnDB:(ChatConversation *)conversation {
    conversation.user = self.me;
    [[ChatDB getSharedInstance] removeConversation:conversation.conversationId];
}

-(void)finishedReceivingConversation:(ChatConversation *)conversation {
    NSLog(@"Finished receiving conversation %@ on delegate: %@",conversation.last_message_text, self.delegateView);
    // callbackToSubscribers()
    if (self.delegateView) {
        [self.delegateView finishedReceivingConversation:conversation];
    }
}

-(void)finishedRemovingConversation:(ChatConversation *)conversation {
    NSLog(@"Finished removing conversation %@ on delegate: %@",conversation.last_message_text, self.delegateView);
    // callbackToSubscribers()
    if (self.delegateView) {
        [self.delegateView finishedRemovingConversation:conversation];
    }
}

@end
