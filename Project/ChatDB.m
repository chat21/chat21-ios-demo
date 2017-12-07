//
//  ChatDB.m
//  Soleto
//
//  Created by Andrea Sponziello on 05/12/14.
//
//

#import "ChatDB.h"
#import "ChatMessage.h"
#import "ChatConversation.h"
#import "ChatGroup.h"
#import "ChatUser.h"

static ChatDB *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation ChatDB

+(ChatDB*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super alloc] init];
        sharedInstance.logQuery = YES;
    }
    return sharedInstance;
}

// name only [a-zA-Z0-9_]
-(BOOL)createDBWithName:(NSString *)name {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *db_name = nil;
    if (name) {
        db_name = [[NSString alloc] initWithFormat:@"%@.db", name];
    }
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: db_name]];
    NSLog(@"Using chat database: %@", databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    

    // **** TESTING ONLY ****
    // if you add another table or change an existing one you must (for the moment) drop the DB
//    [self drop_database];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        NSLog(@"Database %@ not exists. Creating...", databasePath);
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            
            if (self.logQuery) {NSLog(@"**** CREATING TABLE MESSAGES...");}
            const char *sql_stmt_messages =
            "create table if not exists messages (messageId text primary key, conversationId text, text_body text, sender text, sender_fullname text, recipient text, status integer, timestamp real, type text, attributes text)";
            if (sqlite3_exec(database, sql_stmt_messages, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table messages");
            }
            else {
                NSLog(@"Table messages successfully created.");
            }
            
            NSLog(@"**** CREATING TABLE CONVERSATIONS...");
            const char *sql_stmt_conversations =
            "create table if not exists conversations (conversationId text primary key, user text, sender text, sender_fullname, recipient text, last_message_text text, convers_with text, convers_with_fullname text, group_id text, group_name text, is_new integer, timestamp real, status integer)";
            if (sqlite3_exec(database, sql_stmt_conversations, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table conversations");
            }
            else {
                NSLog(@"Table conversations successfully created.");
            }
            
//            NSLog(@"**** CREATING TABLE GROUPS...");
//            const char *sql_stmt_groups =
//            "create table if not exists groups (groupId text primary key, user text, groupName text, owner text, members text, createdOn real)";
//            if (sqlite3_exec(database, sql_stmt_groups, NULL, NULL, &errMsg) != SQLITE_OK) {
//                isSuccess = NO;
//                NSLog(@"Failed to create table groups");
//            }
//            else {
//                NSLog(@"Table groups successfully created.");
//            }
            
//            NSLog(@"**** CREATING TABLE CONTACTS...");
//            const char *sql_stmt_contacts =
//            "create table if not exists contacts (contactId text primary key, firstname text, lastname text, fullname text, email text, imageurl text)";
//            if (sqlite3_exec(database, sql_stmt_contacts, NULL, NULL, &errMsg) != SQLITE_OK) {
//                isSuccess = NO;
//                NSLog(@"Failed to create table contacts");
//            }
//            else {
//                NSLog(@"Table contacts successfully created.");
//            }
            
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    } else {
        NSLog(@"Database %@ already exists.", databasePath);
    }
    return isSuccess;
}

// only for test
-(void)drop_database {
    NSLog(@"**** YOU DROPPED THE CHAT ARCHIVE: %@", databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == YES) {
        NSLog(@"**** DROP DATABASE %@", databasePath);
        NSLog(@"**** DATABASE DROPPED.");
        NSError *error;
        [filemgr removeItemAtPath:databasePath error:&error];
        if (error){
            NSLog(@"%@", error);
        }
    }
}

//- (BOOL)saveOrUpdateMessage:(ChatMessage *)message {
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:
//                              @"select messageId from messages where messageId = \"%@\"", message.messageId];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            if (sqlite3_step(statement) == SQLITE_ROW) {
//                NSString *messageId = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
//                NSLog(@"*** MESSAGE FOUND. UPDATING: %@", messageId);
//                [self updateMessage:message];
//            } else {
//                NSLog(@"*** MESSAGE NOT FOUND. INSERTING: %@", message.messageId);
//                [self insertMessage:message];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING MESSAGES...");
//        }
//    }
//}

-(BOOL)insertMessageIfNotExists:(ChatMessage *)message {
    if (!message.conversationId) {
        NSLog(@"ERROR: CAN'T INSERT A MESSAGE WITHOUT A CONVERSATION ID. MESSAGE ID: %@ MESSAGE TEXT: %@ MESSAGE CONVID: %@", message.messageId, message.text, message.conversationId);
        return false;
    }
    
    if (!message.messageId) {
        NSLog(@"ERROR: CAN'T INSERT A MESSAGE WITHOUT THE ID. MESSAGE ID: %@ MESSAGE TEXT: %@ MESSAGE CONVID: %@", message.messageId, message.text, message.conversationId);
        return false;
    }
    
//    NSLog(@"Inserting message: %@ - %@", message.messageId, message.text);
    ChatMessage *message_is_present = [self getMessageById:message.messageId];
//    NSLog(@"Present? %@", message_is_present.messageId);
    if (message_is_present) {
        NSLog(@"Present. Not inserting.");
        return NO;
    }
    return [self insertMessage:message];
}

-(BOOL)insertMessage:(ChatMessage *)message {
    NSLog(@"**** insert query for message %@ - %@", message.messageId, message.text);
    NSLog(@"__message.attributes %@", message.attributes);
    const char *dbpath = [databasePath UTF8String];
    double timestamp = (double)[message.date timeIntervalSince1970]; // NSTimeInterval is a (double)
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        
        
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into messages (messageId, conversationId, sender, sender_fullname,  recipient, text_body, status, timestamp) values (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d, %f)", message.messageId, message.conversationId, message.sender, message.senderFullname, message.recipient, message.text, message.status, timestamp];
//        if (self.logQuery) {NSLog(@"**** QUERY:%@", insertSQL);}
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);

        NSString *insertSQL = [NSString stringWithFormat:@"insert into messages (messageId, conversationId, sender, sender_fullname,  recipient, text_body, status, timestamp, type, attributes) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
        if (self.logQuery) {NSLog(@"**** QUERY:%@", insertSQL);}
        sqlite3_prepare(database, [insertSQL UTF8String], -1, &statement, NULL);
        
        sqlite3_bind_text(statement, 1, [message.messageId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [message.conversationId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [message.sender UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [message.senderFullname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [message.recipient UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [message.text UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 7, message.status);
        sqlite3_bind_double(statement, 8, timestamp);
        sqlite3_bind_text(statement, 9, [message.mtype UTF8String], -1, SQLITE_TRANSIENT);
        
        // convert attributes dictionary to JSON
        NSString * jsonAttributesAsString = nil;
        if (message.attributes) {
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:message.attributes options:0 error:&err]; // options: NSJSONWritingPrettyPrinted
            jsonAttributesAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"message.attributes converted to json string %@, err: %@", jsonAttributesAsString, err);
        }
        sqlite3_bind_text(statement, 10, [jsonAttributesAsString UTF8String], -1, SQLITE_TRANSIENT);
        
//                               , message.messageId, message.conversationId, message.sender, message.senderFullname, message.recipient, message.text, message.status, timestamp];
        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        }
        else {
            NSLog(@"Error on insert message.");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

-(BOOL)updateMessage:(NSString *)messageId withStatus:(int)status {
//    NSLog(@"**** update message %@ with status %d", messageId, status);
//    ChatMessage *previous_msg = [self getMessageById:messageId]; // TEST ONLY QUERY
//    NSLog(@"**** BEFORE MSG STATUS: %d", previous_msg.status);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE messages SET status = %d WHERE messageId = \"%@\"", status, messageId];
//        NSLog(@"**** QUERY:%@", updateSQL);
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, update_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            ChatMessage *msg = [self getMessageById:messageId];
            NSLog(@"**** AFTER MSG STATUS: %d", msg.status);
            sqlite3_reset(statement);
            return YES;
        }
        else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

static NSString *SELECT_FROM_MESSAGES_STATEMENT = @"select messageId, conversationId, sender, sender_fullname, recipient, text_body, status, timestamp, type, attributes from messages ";

-(NSArray*)getAllMessages {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
//        NSString *querySQL = [NSString stringWithFormat:@"select messageId, conversationId, sender, sender_fullname, recipient, text_body, status, timestamp, type, attributes from messages order by timestamp desc limit 40"];
        
        NSString *querySQL = [NSString stringWithFormat:@"%@ order by timestamp desc limit 40", SELECT_FROM_MESSAGES_STATEMENT];
        if (self.logQuery) {NSLog(@"querySQL: %@", querySQL);}
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ChatMessage *message = [self messageFromStatement:statement];
                [messages addObject:message];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"**** getAllMessages. PROBLEMS WHILE QUERYING MESSAGES...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return messages;
}

-(NSArray*)getAllMessagesForConversation:(NSString *)conversationId start:(int)start count:(int)count {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
//        NSString *querySQL = [NSString stringWithFormat:@"select messageId, conversationId, sender, sender_fullname, recipient, text_body, status, timestamp, type, attributes FROM messages WHERE conversationId = \"%@\" order by timestamp desc limit %d,%d", conversationId, start, count];
        
        NSString *querySQL = [NSString stringWithFormat:@"%@ WHERE conversationId = \"%@\" order by timestamp desc limit %d,%d", SELECT_FROM_MESSAGES_STATEMENT, conversationId, start, count];
        if (self.logQuery) {NSLog(@"querySQL: %@", querySQL);}
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ChatMessage *message = [self messageFromStatement:statement];
                [messages addObject:message];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"getAllMessagesForConversation. **** PROBLEMS WHILE QUERYING MESSAGES...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return messages;
}

-(NSArray*)getAllMessagesForConversation:(NSString *)conversationId {
    NSArray *messages = [[ChatDB getSharedInstance] getAllMessagesForConversation:conversationId start:0 count:-1];
    return messages;
}

-(ChatMessage *)getMessageById:(NSString *)messageId {
    ChatMessage *message = nil;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
//        NSString *querySQL = [NSString stringWithFormat: @"select messageId, conversationId, sender, sender_fullname, recipient, text_body, status, timestamp, type, attributes from messages where messageId = \"%@\"", messageId];
        
        NSString *querySQL = [NSString stringWithFormat:@"%@ where messageId = \"%@\"",SELECT_FROM_MESSAGES_STATEMENT, messageId];
        if (self.logQuery) {NSLog(@"querySQL: %@", querySQL);}
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                message = [self messageFromStatement:statement];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"**** getMessageById. PROBLEMS WHILE QUERYING MESSAGES...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return message;
}

-(ChatMessage *)messageFromStatement:(sqlite3_stmt *)statement {
    
    //NSString *messageId = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
    const char* _messageId = (const char *) sqlite3_column_text(statement, 0);
    NSString *messageId = nil;
    if (_messageId) {
        messageId = [[NSString alloc] initWithUTF8String:_messageId];
    }
    
    //NSString *conversationId = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
    const char* _conversationId = (const char *) sqlite3_column_text(statement, 1);
    NSString *conversationId = nil;
    if (_conversationId) {
        conversationId = [[NSString alloc] initWithUTF8String:_conversationId];
    }
    
    //NSString *sender = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
    const char* _sender = (const char *) sqlite3_column_text(statement, 2);
    NSString *sender = nil;
    if (_sender) {
        sender = [[NSString alloc] initWithUTF8String:_sender];
    }
    
    //NSString *senderFullname = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
    const char* _senderFullname = (const char *) sqlite3_column_text(statement, 3);
    NSString *senderFullname = nil;
    if (_senderFullname) {
        senderFullname = [[NSString alloc] initWithUTF8String:_senderFullname];
    }
    
    
    // group's messages have no recipient
    NSString *recipient = nil;
    const char *recipient_chars = (const char *) sqlite3_column_text(statement, 4);
    if (recipient_chars != NULL) {
        recipient = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
    }
    NSString *text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
    int status = sqlite3_column_int(statement, 6);
    double timestamp = sqlite3_column_double(statement, 7);
    
    NSString *type = nil;
    const char *type_chars = (const char *) sqlite3_column_text(statement, 8);
    if (type_chars != NULL) {
        type = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)];
    }
    
    NSString *attributes_json = nil;
    const char *attributes_json_chars = (const char *) sqlite3_column_text(statement, 9);
    if (attributes_json_chars != NULL) {
        attributes_json = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)];
    }
    //NSString *attributes_json = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)];
    NSMutableDictionary *attributes = nil;
    NSLog(@"attributes_json: %@", attributes_json);
    if (attributes_json) {
        NSData *jsonData = [attributes_json dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error;
        attributes = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:kNilOptions
                                 error:&error];
    }
    NSLog(@"*** MESSAGE FROM SQLITE:\nmessageId:%@\nconversationid:%@\nsender:%@\nrecipient:%@\ntext:%@\nstatus:%d\ntimestamp:%f", messageId, conversationId, sender, recipient, text, status, timestamp);
    ChatMessage *message = [[ChatMessage alloc] init];
    message.messageId = messageId;
    message.conversationId = conversationId;
    message.sender = sender;
    message.senderFullname = senderFullname;
    message.recipient = recipient;
    message.text = text;
    message.mtype = type;
    NSLog(@"VERIFY TYPE: %@", message.mtype);
    message.attributes = attributes;
    NSLog(@"VERIFY ATTRIBUTES: %@", message.attributes);
    message.status = status;
    message.date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    message.archived = YES;
    NSLog(@"message built %@ archived %d", message.text, message.archived);
    return message;
}

-(BOOL)removeAllMessagesForConversation:(NSString *)conversationId {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM messages WHERE conversationId = \"%@\"", conversationId];
        if (self.logQuery) {NSLog(@"**** QUERY:%@", sql);}
        const char *stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        }
        else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}





// CONVERSATIONS


-(BOOL)insertOrUpdateConversation:(ChatConversation *)conversation {
    NSLog(@"insertOrUpdateConversation: %@ user: %@", conversation.conversationId, conversation.user);
    ChatConversation *conv_exists = [self getConversationById:conversation.conversationId];
    if (conv_exists) {
        //NSLog(@"CONVERSATION %@ EXISTS. UPDATING CONVERSATION... is_new: %d",conversation.conversationId, conversation.is_new);
        return [self updateConversation:conversation];
    }
    else {
        NSLog(@"CONVERSATION IS NEW. INSERTING CONVERSATION...");
        return [self insertConversation:conversation];
    }
}

-(BOOL)insertConversation:(ChatConversation *)conversation {
        NSLog(@"**** insert query...");
    const char *dbpath = [databasePath UTF8String];
    double timestamp = (double)[conversation.date timeIntervalSince1970]; // NSTimeInterval is a (double)
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSLog(@">>>> Conversation groupID %@ and groupNAME %@", conversation.groupId, conversation.groupName);

        NSString *insertSQL = [NSString stringWithFormat:@"insert into conversations (conversationId, user, sender, sender_fullname, recipient, last_message_text, convers_with, convers_with_fullname, group_id, group_name, is_new, timestamp, status) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
        
        if (self.logQuery) {NSLog(@"**** QUERY:%@", insertSQL);}
        
        sqlite3_prepare(database, [insertSQL UTF8String], -1, &statement, NULL);
        
        sqlite3_bind_text(statement, 1, [conversation.conversationId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [conversation.user UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [conversation.sender UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [conversation.senderFullname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [conversation.recipient UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [conversation.last_message_text UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [conversation.conversWith UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [conversation.conversWith_fullname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 9, [conversation.groupId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [conversation.groupName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 11, conversation.is_new);
        sqlite3_bind_double(statement, 12, timestamp);
        sqlite3_bind_int(statement, 13, conversation.status);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"QUERY INSERT OK.");
            NSLog(@"Conversation successfully inserted.");
            ChatConversation *conv = [self getConversationById:conversation.conversationId];
            NSLog(@"**** AFTER: CONV SENDER: %@", conv.sender);
            sqlite3_reset(statement);
            return YES;
        }
        else {
            NSLog(@"Error on insertConversation.");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

// NOTE: fields "conversationId", "user" and "convers_with" are "invariant" and not updated.
-(BOOL)updateConversation:(ChatConversation *)conversation {
//    ChatConversation *previous_conv = [self getConversationById:conversation.conversationId]; // TEST ONLY QUERY
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        double timestamp = (double)[conversation.date timeIntervalSince1970]; // NSTimeInterval is a (double)
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE conversations SET sender = ?, sender_fullname = ?, recipient = ?, convers_with_fullname = ?, last_message_text = ?, group_name = ?, is_new = ?, timestamp = ?, status = ? WHERE conversationId = ?"];
        if (self.logQuery) {NSLog(@"QUERY:%@", updateSQL);}
        
        sqlite3_prepare(database, [updateSQL UTF8String], -1, &statement, NULL);
        
        sqlite3_bind_text(statement, 1, [conversation.sender UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [conversation.senderFullname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [conversation.recipient UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [conversation.conversWith_fullname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [conversation.last_message_text UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [conversation.groupName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 7, conversation.is_new);
        sqlite3_bind_double(statement, 8, timestamp);
        sqlite3_bind_int(statement, 9, conversation.status);
        sqlite3_bind_text(statement, 10, [conversation.conversationId UTF8String], -1, SQLITE_TRANSIENT);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Conversation successfully updated.");
            ChatConversation *conv = [self getConversationById:conversation.conversationId];
            NSLog(@"**** AFTER: CONV SENDER: %@", conv.sender);
            sqlite3_reset(statement);
            return YES;
        }
        else {
            NSLog(@"Error while updating conversation.");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

static NSString *SELECT_FROM_STATEMENT = @"SELECT conversationId, user, sender, sender_fullname, recipient, last_message_text, convers_with, convers_with_fullname, group_id, group_name, is_new, timestamp, status FROM conversations ";

- (NSArray*)getAllConversations {
    NSMutableArray *convs = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"%@ order by timestamp desc", SELECT_FROM_STATEMENT]; // limit 40?
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ChatConversation *conv = [self conversationFromStatement:statement];
                [convs addObject:conv];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"**** ERROR: PROBLEMS WHILE QUERYING CONVERSATIONS...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return convs;
}

- (NSArray*)getAllConversationsForUser:(NSString *)user {
    NSMutableArray *convs = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"%@ WHERE user = \"%@\" order by timestamp desc", SELECT_FROM_STATEMENT, user];
        if (self.logQuery) {NSLog(@"QUERY: %@", querySQL);}
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ChatConversation *conv = [self conversationFromStatement:statement];
//                NSLog(@"convesend %@", conv.sender);
                [convs addObject:conv];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"**** ERROR: PROBLEMS WHILE QUERYING CONVERSATIONS...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return convs;
}

- (ChatConversation *)getConversationById:(NSString *)conversationId {
    ChatConversation *conv = nil;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"%@ where conversationId = \"%@\"",SELECT_FROM_STATEMENT, conversationId];
        if (self.logQuery) {NSLog(@"*** QUERY: %@", querySQL);}
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                conv = [self conversationFromStatement:statement];
            }
            sqlite3_reset(statement);
        } else {
            NSLog(@"**** ERROR: PROBLEMS WHILE QUERYING CONVERSATIONS...");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        }
    }
    return conv;
}

-(BOOL)removeConversation:(NSString *)conversationId {
    //    NSLog(@"**** remove query...");
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM conversations WHERE conversationId = \"%@\"", conversationId];
        if (self.logQuery) {NSLog(@"**** QUERY:%@", sql);}
        const char *stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        }
        else {
            NSLog(@"Error on removeConversation.");
            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}


-(ChatConversation *)conversationFromStatement:(sqlite3_stmt *)statement {
    
    NSLog(@"== CONVERSATION FROM STATEMENT ==");
    const char* _conversationId = (const char *) sqlite3_column_text(statement, 0);
    NSLog(@">>>>>>>>>>> conversationID = %s", _conversationId);
    NSString *conversationId = nil;
    if (_conversationId) {
        conversationId = [[NSString alloc] initWithUTF8String:_conversationId];
        NSLog(@"NSString conversationID = %@", conversationId);
    }
    
    const char* _user = (const char *) sqlite3_column_text(statement, 1);
//    NSLog(@">>>>>>>>>>> user = %s", _user);
    NSString *user = nil;
    if (_user) {
        user = [[NSString alloc] initWithUTF8String:_user];
    }
    
    const char* _sender = (const char *) sqlite3_column_text(statement, 2);
//    NSLog(@">>>>>>>>>>> sender = %s", _sender);
    NSString *sender = nil;
    if (_sender) {
        sender = [[NSString alloc] initWithUTF8String:_sender];
    }
    
    const char* _senderFullname = (const char *) sqlite3_column_text(statement, 3);
    //    NSLog(@">>>>>>>>>>> senderFullname = %s", _senderFullname);
    NSString *senderFullname = nil;
    if (_senderFullname) {
        senderFullname = [[NSString alloc] initWithUTF8String:_senderFullname];
    }
    
    const char* _recipient = (const char *) sqlite3_column_text(statement, 4);
//    NSLog(@">>>>>>>>>>> recipient = %s", _recipient);
    NSString *recipient = nil;
    if (_recipient) {
        recipient = [[NSString alloc] initWithUTF8String:_recipient];
    }
    
    const char* _last_message_text = (const char *) sqlite3_column_text(statement, 5);
//    NSLog(@">>>>>>>>>>> last_message_text = %s", _last_message_text);
    NSString *last_message_text = nil;
    if (_last_message_text) {
        last_message_text = [[NSString alloc] initWithUTF8String:_last_message_text];
    }
    
    const char* _convers_with = (const char *) sqlite3_column_text(statement, 6);
//    NSLog(@">>>>>>>>>>> convers_with = %s", _convers_with);
    NSString *convers_with = nil;
    if (_convers_with) {
        convers_with = [[NSString alloc] initWithUTF8String:_convers_with];
    }
    
    const char* _convers_with_fullname = (const char *) sqlite3_column_text(statement, 7);
//    NSLog(@">>>>>>>>>>> _convers_with_fullname = %s", _convers_with_fullname);
    NSString *convers_with_fullname = nil;
    if (_convers_with_fullname) {
        convers_with_fullname = [[NSString alloc] initWithUTF8String:_convers_with_fullname];
    }
    
    const char* _group_id = (const char *) sqlite3_column_text(statement, 8);
    NSLog(@">>>>>>>>>>> group_id = %s", _group_id);
    NSString *group_id = nil;
    if (_group_id) {
        group_id = [[NSString alloc] initWithUTF8String:_group_id];
    }
    
    const char* _group_name = (const char *) sqlite3_column_text(statement, 9);
//    NSLog(@">>>>>>>>>>> group_name = %s", _group_name);
    NSString *group_name = nil;
    if (_group_name) {
        group_name = [[NSString alloc] initWithUTF8String:_group_name];
    }
    
    BOOL is_new = sqlite3_column_int(statement, 10);
//    NSLog(@">>>>>>>>>>> is_new = %d", is_new);
    double timestamp = sqlite3_column_double(statement, 11);
    int status = sqlite3_column_int(statement, 12);
//    NSLog(@">>>>>>>>>>> status = %d", status);
    
    ChatConversation *conv = [[ChatConversation alloc] init];
    conv.conversationId = conversationId;
    conv.user = user;
    conv.sender = sender;
    conv.senderFullname = senderFullname;
    conv.recipient = recipient;
    conv.last_message_text = last_message_text;
    conv.conversWith = convers_with;
    conv.conversWith_fullname = convers_with_fullname;
    conv.groupId = group_id;
    conv.groupName = group_name;
    conv.is_new = is_new;
    conv.date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    conv.status = status;
    
    return conv;
}


// CONVERSATIONS END




// GROUPS





//-(BOOL)insertOrUpdateGroup:(ChatGroup *)group {
////    NSLog(@"....GROUP NAME: %@", group.name);
//    ChatGroup *exists = [self getGroupById:group.groupId];
//    if (exists) {
//        NSLog(@"GROUP %@/%@ EXISTS. UPDATING...", group.groupId, group.name);
//        return [self updateGroup:group];
//    }
//    else {
//        NSLog(@"GROUP %@/%@ IS NEW. INSERTING GROUP...", group.groupId, group.name);
//        return [self insertGroup:group];
//    }
//}
//
//-(BOOL)insertGroup:(ChatGroup *)group {
//    NSLog(@"**** insert query...");
//    const char *dbpath = [databasePath UTF8String];
//    double createdOn = (double)[group.createdOn timeIntervalSince1970]; // NSTimeInterval is a (double)
//    NSString *members = [ChatGroup membersDictionary2String:group.members];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        
//        NSLog(@">>>> Inserting group %@", group.name);
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into groups (groupId, user, groupName, owner, members, createdOn) values (?, ?, ?, ?, ?, ?)"];
//        
//        if (self.logQuery) {NSLog(@"**** QUERY:%@", insertSQL);}
//        
//        sqlite3_prepare(database, [insertSQL UTF8String], -1, &statement, NULL);
//        
//        sqlite3_bind_text(statement, 1, [group.groupId UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 2, [group.user UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 3, [group.name UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 4, [group.owner UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 5, [members UTF8String], -1, SQLITE_TRANSIENT);
////        sqlite3_bind_text(statement, 6, [group.iconURL UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_double(statement, 6, createdOn);
//        
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
//            return YES;
//        }
//        else {
//            NSLog(@"Error on insertGroup.");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//-(BOOL)updateGroup:(ChatGroup *)group {
////    NSLog(@"**** updating group %@", group.groupId);
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *members = [ChatGroup membersDictionary2String:group.members];
//        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE groups SET groupName = ?, owner = ?, members = ? WHERE groupId = ?"];
////        NSLog(@"QUERY:%@", updateSQL);
//        
//        sqlite3_prepare(database, [updateSQL UTF8String], -1, &statement, NULL);
//        
//        sqlite3_bind_text(statement, 1, [group.name UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 2, [group.owner UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 3, [members UTF8String], -1, SQLITE_TRANSIENT);
////        sqlite3_bind_text(statement, 4, [group.iconURL UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 4, [group.groupId UTF8String], -1, SQLITE_TRANSIENT);
//        
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
////            NSLog(@"Group successfully updated.");
//            return YES;
//        }
//        else {
//            NSLog(@"Error while updating group.");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//static NSString *SELECT_FROM_GROUPS_STATEMENT = @"SELECT groupId, user, groupName, owner, members, createdOn FROM groups ";
//
//-(NSArray*)getAllGroups {
//    NSMutableArray *groups = [[NSMutableArray alloc] init];
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:@"%@ order by createdOn desc", SELECT_FROM_GROUPS_STATEMENT];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                ChatGroup *group = [self groupFromStatement:statement];
//                [groups addObject:group];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING GROUPS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    return groups;
//}
//
//-(NSArray*)getAllGroupsForUser:(NSString *)user {
//    NSMutableArray *groups = [[NSMutableArray alloc] init];
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:@"%@ WHERE user = \"%@\" order by createdOn desc", SELECT_FROM_GROUPS_STATEMENT, user];
//        NSLog(@"QUERY: %@", querySQL);
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                ChatGroup *group = [self groupFromStatement:statement];
////                NSLog(@"Adding group from DB id:%@ name:%@", group.groupId, group.name);
//                [groups addObject:group];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING GROUPS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    return groups;
//}
//
//-(ChatGroup *)getGroupById:(NSString *)groupId {
//    ChatGroup *group = nil;
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:
//                              @"%@ where groupId = \"%@\"",SELECT_FROM_GROUPS_STATEMENT, groupId];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                group = [self groupFromStatement:statement];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING GROUPS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    return group;
//}
//
//-(BOOL)removeGroup:(NSString *)groupId {
//    //    NSLog(@"**** remove query...");
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *sql = [NSString stringWithFormat:@"DELETE FROM groups WHERE groupId = \"%@\"", groupId];
////        NSLog(@"**** QUERY:%@", sql);
//        const char *stmt = [sql UTF8String];
//        sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
//            return YES;
//        }
//        else {
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//-(ChatGroup *)groupFromStatement:(sqlite3_stmt *)statement {
//    
//    // groupId, user, groupName, owner, members, iconURL, createdOn
//    
////    NSLog(@"== GROUP FROM STATEMENT ==");
//    const char* _groupId = (const char *) sqlite3_column_text(statement, 0);
////    NSLog(@">>>>>>>>>>> groupID = %s", _groupId);
//    NSString *groupId = nil;
//    if (_groupId) {
//        groupId = [[NSString alloc] initWithUTF8String:_groupId];
//    }
//    
//    const char* _user = (const char *) sqlite3_column_text(statement, 1);
////    NSLog(@">>>>>>>>>>> user = %s", _user);
//    NSString *user = nil;
//    if (_user) {
//        user = [[NSString alloc] initWithUTF8String:_user];
//    }
//    
//    const char* _groupName = (const char *) sqlite3_column_text(statement, 2);
////    NSLog(@">>>>>>>>>>> groupName = %s", _groupName);
//    NSString *groupName = nil;
//    if (_groupName) {
//        groupName = [[NSString alloc] initWithUTF8String:_groupName];
//    }
//    
//    const char* _owner = (const char *) sqlite3_column_text(statement, 3);
////    NSLog(@">>>>>>>>>>> owner = %s", _owner);
//    NSString *owner = nil;
//    if (_owner) {
//        owner = [[NSString alloc] initWithUTF8String:_owner];
//    }
//    
//    const char* _members = (const char *) sqlite3_column_text(statement, 4);
////    NSLog(@">>>>>>>>>>> members = %s", _members);
//    NSString *members = nil;
//    if (_members) {
//        members = [[NSString alloc] initWithUTF8String:_members];
//    }
//    
////    const char* _iconURL = (const char *) sqlite3_column_text(statement, 5);
////    NSString *iconURL = nil;
////    if (_iconURL) {
////        iconURL = [[NSString alloc] initWithUTF8String:_iconURL];
////    }
//    
//    double createdOn = sqlite3_column_double(statement, 5);
//    
//    ChatGroup *group = [[ChatGroup alloc] init];
//    group.groupId = groupId;
//    group.user = user;
//    group.name = groupName;
//    group.owner = owner;
//    group.members = [ChatGroup membersString2Dictionary:members];
//    group.createdOn = [NSDate dateWithTimeIntervalSince1970:createdOn];
//    
//    return group;
//}




//// *************
//// CONTACTS
//// *************
//
//
//
//-(BOOL)insertOrUpdateContact:(ChatUser *)contact {
//    //    NSLog(@"....GROUP NAME: %@", group.name);
//    ChatUser *exists = [self getContactById:contact.userId];
//    if (exists) {
//        NSLog(@"CONTACT %@/%@ EXISTS. UPDATING...", contact.userId, contact.fullname);
//        return [self updateContact:contact];
//    }
//    else {
//        NSLog(@"CONTACT %@/%@ IS NEW. INSERTING ...", contact.userId, contact.fullname);
//        return [self insertContact:contact];
//    }
//}
//
//-(BOOL)insertContact:(ChatUser *)contact {
//    NSLog(@"**** insert query...");
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSLog(@"Insert contact %@", contact.fullname);
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into contacts (contactId, firstname, lastname, fullname, email, imageurl) values (?, ?, ?, ?, ?, ?)"];
//        NSLog(@"inserting contact: %@, %@, %@, %@, %@", contact.lastname, contact.userId, contact.firstname, contact.email, contact.imageurl);
//        if (self.logQuery) {NSLog(@"**** QUERY:%@", insertSQL);}
//        
//        sqlite3_prepare(database, [insertSQL UTF8String], -1, &statement, NULL);
//        
//        sqlite3_bind_text(statement, 1, [contact.userId UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 2, [contact.firstname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 3, [contact.lastname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 4, [contact.fullname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 5, [contact.email UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 6, [contact.imageurl UTF8String], -1, SQLITE_TRANSIENT);
//        
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
//            return YES;
//        }
//        else {
//            NSLog(@"Error on insertContact.");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//-(BOOL)updateContact:(ChatUser *)contact {
//    //    NSLog(@"**** updating group %@", group.groupId);
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSLog(@"Update contact %@", contact.fullname);
//        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE contacts SET firstname = ?, lastname = ?, fullname = ?, email = ?, imageurl = ? WHERE contactId = ?"];
//        //        NSLog(@"QUERY:%@", updateSQL);
//        
//        sqlite3_prepare(database, [updateSQL UTF8String], -1, &statement, NULL);
//        
//        sqlite3_bind_text(statement, 1, [contact.firstname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 2, [contact.lastname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 3, [contact.fullname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 4, [contact.fullname UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 5, [contact.fullname UTF8String], -1, SQLITE_TRANSIENT);
//        //        sqlite3_bind_text(statement, 4, [group.iconURL UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 6, [contact.userId UTF8String], -1, SQLITE_TRANSIENT);
//        
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
//            NSLog(@"Contact successfully updated.");
//            return YES;
//        }
//        else {
//            NSLog(@"Error while updating contact.");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//static NSString *SELECT_FROM_CONTACTS_STATEMENT = @"SELECT contactId, firstname, lastname, fullname, email, imageurl FROM contacts ";
//
//-(NSArray*)getAllContacts {
//    NSMutableArray *contacts = [[NSMutableArray alloc] init];
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:@"%@ order by firstname desc", SELECT_FROM_CONTACTS_STATEMENT];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                ChatUser *contact = [self contactFromStatement:statement];
//                [contacts addObject:contact];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING CONTACTS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    return contacts;
//}
//
//-(ChatUser *)getContactById:(NSString *)contactId {
//    ChatUser *contact = nil;
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:
//                              @"%@ where contactId = \"%@\"",SELECT_FROM_CONTACTS_STATEMENT, contactId];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                contact = [self contactFromStatement:statement];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE QUERYING CONTACTS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    return contact;
//}
//
//-(void)searchContactsByFullname:(NSString *)searchString completion:(void (^)(NSArray<ChatUser *> *))callback {
//    NSMutableArray<ChatUser *> *contacts = [[NSMutableArray alloc] init];
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:
//                              @"%@ where fullname LIKE \"%%%@%%\"",SELECT_FROM_CONTACTS_STATEMENT, searchString];
//        const char *query_stmt = [querySQL UTF8String];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                ChatUser *contact = [self contactFromStatement:statement];
//                [contacts addObject:contact];
//            }
//            sqlite3_reset(statement);
//        } else {
//            NSLog(@"**** PROBLEMS WHILE SEARCHING CONTACTS...");
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//        }
//    }
//    callback(contacts);
//}
//
//-(BOOL)removeContact:(NSString *)contactId {
//    //    NSLog(@"**** remove contact query...");
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *sql = [NSString stringWithFormat:@"DELETE FROM contacts WHERE contactId = \"%@\"", contactId];
//        //        NSLog(@"**** QUERY:%@", sql);
//        const char *stmt = [sql UTF8String];
//        sqlite3_prepare_v2(database, stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            sqlite3_reset(statement);
//            return YES;
//        }
//        else {
//            NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
//            sqlite3_reset(statement);
//            return NO;
//        }
//    }
//    return NO;
//}
//
//-(ChatUser *)contactFromStatement:(sqlite3_stmt *)statement {
//    
//    // SELECT contactId, firstname, lastname, fullname, email, imageurl
//    
//    //    NSLog(@"== GROUP FROM STATEMENT ==");
//    const char* _contactId = (const char *) sqlite3_column_text(statement, 0);
//    //    NSLog(@">>>>>>>>>>> groupID = %s", _groupId);
//    NSString *contactId = nil;
//    if (_contactId) {
//        contactId = [[NSString alloc] initWithUTF8String:_contactId];
//    }
//    
//    const char* _firstname = (const char *) sqlite3_column_text(statement, 1);
//    //    NSLog(@">>>>>>>>>>> user = %s", _user);
//    NSString *firstname = nil;
//    if (_firstname) {
//        firstname = [[NSString alloc] initWithUTF8String:_firstname];
//    }
//    
//    const char* _lastname = (const char *) sqlite3_column_text(statement, 2);
//    //    NSLog(@">>>>>>>>>>> groupName = %s", _groupName);
//    NSString *lastname = nil;
//    if (_lastname) {
//        lastname = [[NSString alloc] initWithUTF8String:_lastname];
//    }
//    
//    const char* _fullname = (const char *) sqlite3_column_text(statement, 3);
//    //    NSLog(@">>>>>>>>>>> owner = %s", _owner);
//    NSString *fullname = nil;
//    if (_fullname) {
//        fullname = [[NSString alloc] initWithUTF8String:_fullname];
//    }
//    
//    const char* _email = (const char *) sqlite3_column_text(statement, 4);
//    //    NSLog(@">>>>>>>>>>> owner = %s", _owner);
//    NSString *email = nil;
//    if (_email) {
//        email = [[NSString alloc] initWithUTF8String:_email];
//    }
//    
//    const char* _imageurl = (const char *) sqlite3_column_text(statement, 5);
//    //    NSLog(@">>>>>>>>>>> owner = %s", _owner);
//    NSString *imageurl = nil;
//    if (_imageurl) {
//        imageurl = [[NSString alloc] initWithUTF8String:_fullname];
//    }
//    
//    ChatUser *contact = [[ChatUser alloc] init];
//    contact.userId = contactId;
//    contact.firstname = firstname;
//    contact.lastname = lastname;
//    contact.fullname = fullname;
//    contact.email = email;
//    contact.imageurl = imageurl;
//    return contact;
//}


@end
