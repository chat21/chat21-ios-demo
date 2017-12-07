//
//  ContactsDB.h
//  
//
//  Created by Andrea Sponziello on 17/09/2017.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ChatMessage;
@class ChatConversation;
@class ChatGroup;
@class ChatUser;

@interface ContactsDB : NSObject
{
    NSString *databasePath;
}

@property (assign, nonatomic) BOOL logQuery;

+(ContactsDB*)getSharedInstance;
-(BOOL)createDBWithName:(NSString *)name;

// contacts
-(void)insertOrUpdateContactSyncronized:(ChatUser *)contact completion:(void(^)()) callback;
-(void)getContactByIdSyncronized:(NSString *)contactId completion:(void(^)(ChatUser *)) callback;
-(void)searchContactsByFullnameSynchronized:(NSString *)searchString completion:(void (^)(NSArray<ChatUser *> *))callback;
-(BOOL)removeContactSynchronized:(NSString *)contactId;
-(ChatUser *)getMostRecentContact;
-(BOOL)insertContact:(ChatUser *)contact;
//-(BOOL)insertContact:(ChatUser *)contact;
//-(BOOL)updateContact:(ChatUser *)contact;
-(NSArray*)getAllContacts; // test only
//-(ChatUser *)getContactById:(NSString *)contactId;
//-(NSArray*)searchContactsByFullname:(NSString *)searchString;
-(void)drop_database;

@end
