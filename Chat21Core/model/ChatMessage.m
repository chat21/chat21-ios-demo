//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

-(id)init {
    self = [super init];
    if (self) {
        // initialization
    }
    return self;
}

// ConversationId custom getter
- (NSString *) conversationId {
    if (!_conversationId) {
        return _recipient;
    }
    else {
        return _conversationId;
    }
}

//- (NSDictionary *) asDictionary {
//    NSDictionary *dict = [[NSMutableDictionary alloc] init];
//    dict[]
//}

-(NSString *)snapshotAsJSONString {
    NSString * json = nil;
    if (self.snapshot && [self.snapshot isKindOfClass:[NSDictionary class]]) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.snapshot options:0 error:&err];
        if (err) {
            NSLog(@"Error: %@", err);
        }
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return json;
}

-(NSString *)attributesAsJSONString {
    NSString * json = nil;
//    NSLog(@"valid json? %d", [NSJSONSerialization isValidJSONObject:self.attributes]);
    if (self.attributes && [self.attributes isKindOfClass:[NSDictionary class]]) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.attributes options:0 error:&err];
        if (err) {
            NSLog(@"Error: %@", err);
        }
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return json;
}

-(NSString *)dateFormattedForListView {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    NSString *date = [timeFormat stringFromDate:self.date];
    return date;
}

-(void)updateStatusOnFirebase:(int)status {
    NSDictionary *message_dict = @{
                                   @"status": [NSNumber numberWithInt:status]
                                   };
    [self.ref updateChildValues:message_dict];
}

+(ChatMessage *)messageFromSnapshotFactory:(FIRDataSnapshot *)snapshot {
    NSString *conversationId = snapshot.value[MSG_FIELD_CONVERSATION_ID];
    NSString *type = snapshot.value[MSG_FIELD_TYPE];
    NSString *subtype = snapshot.value[MSG_FIELD_SUBTYPE];
    NSString *channel_type = snapshot.value[MSG_FIELD_CHANNEL_TYPE];
    if (!channel_type) {
        channel_type = MSG_CHANNEL_TYPE_DIRECT;
    }
    NSString *text = snapshot.value[MSG_FIELD_TEXT];
    NSString *sender = snapshot.value[MSG_FIELD_SENDER];
    NSString *senderFullname = snapshot.value[MSG_FIELD_SENDER_FULLNAME];
    NSString *recipient = snapshot.value[MSG_FIELD_RECIPIENT];
    NSString *recipientFullname = snapshot.value[MSG_FIELD_RECIPIENT_FULLNAME];
    NSString *lang = snapshot.value[MSG_FIELD_LANG];
    NSNumber *timestamp = snapshot.value[MSG_FIELD_TIMESTAMP];
    NSDictionary *attributes = (NSDictionary *) snapshot.value[MSG_FIELD_ATTRIBUTES];
    
    ChatMessage *message = [[ChatMessage alloc] init];
    
    message.snapshot = (NSDictionary *) snapshot.value;
//    for(id key in message.snapshotAsDictionary) {
//        NSLog(@"key=%@ value=%@", key, [message.asDictionary objectForKey:key]);
//    }
    message.attributes = attributes;
    message.key = snapshot.key;
    message.ref = snapshot.ref;
    message.messageId = snapshot.key;
    message.conversationId = conversationId;
    message.text = text;
    message.lang = lang;
    message.mtype = type;
    message.subtype = subtype;
    message.channel_type = channel_type;
    message.sender = sender;
    message.senderFullname = senderFullname;
    message.date = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue/1000];
    int status = [(NSNumber *)snapshot.value[MSG_FIELD_STATUS] intValue];
    if (status < 100) {
        status = 100;
    }
    message.status = status;
    message.recipient = recipient;
    message.recipientFullName = recipientFullname;
    return message;
}

-(BOOL)isDirect {
    return [self.channel_type isEqualToString:MSG_CHANNEL_TYPE_DIRECT] ? YES : NO;
}

@end

