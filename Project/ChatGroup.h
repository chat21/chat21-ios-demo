//
//  ChatGroup.h
//  Smart21
//
//  Created by Andrea Sponziello on 27/03/15.
//
//

#import <Foundation/Foundation.h>

static NSString* const NOTIFICATION_TYPE_MEMBER_ADDED_TO_GROUP = @"group_member_added";
static NSString* const GROUP_OWNER = @"owner";
static NSString* const GROUP_CREATEDON = @"createdOn";
static NSString* const GROUP_NAME = @"name";
static NSString* const GROUP_MEMBERS = @"members";
static NSString* const GROUP_ICON_ID = @"iconID";

@import Firebase;

//@class Firebase;
@class FDataSnapshot;
@class SHPApplicationContext;

@interface ChatGroup : NSObject

@property (nonatomic, strong) NSString *key;
//@property (nonatomic, strong) Firebase *ref;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *tempId;
@property (nonatomic, strong) NSString *user; // used to query groups on local DB
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *owner;
//@property (nonatomic, strong) NSString *iconID;
@property (nonatomic, strong) NSDate *createdOn;
@property (nonatomic, strong) NSMutableDictionary *members;
@property (assign, nonatomic) BOOL completeData;

-(NSString *)iconUrl;
-(FIRDatabaseReference *)reference;
-(NSString *)memberPath:(NSString *)memberId;
-(FIRDatabaseReference *)memberReference:(NSString *)memberId;
-(BOOL)isMember:(NSString *)user_id;
-(NSMutableDictionary *)asDictionary;
+(NSMutableDictionary *)membersArray2Dictionary:(NSArray *)membersIds;
+(NSMutableArray *)membersDictionary2Array:(NSDictionary *)membersDict;
+(NSString *)membersDictionary2String:(NSDictionary *)membersDictionary;
//+(NSString *)membersArray2String:(NSArray *)membersArray;
//+(NSMutableArray *)membersString2Array:(NSString *)membersString;
+(NSMutableDictionary *)membersString2Dictionary:(NSString *)membersString;

// dc
//+(void)createGroup:(ChatGroup*)group reference:(Firebase *)groupsBaseRef withContext:(SHPApplicationContext *)context;
//+(void)addMember:(NSString *)groupId member:(NSString *)user_id; // TODO
//+(void)removeMember:(NSString *)groupId member:(NSString *)user_id; // TODO
//+(void)removeGroup:(NSString *)groupId; // TODO


@end
