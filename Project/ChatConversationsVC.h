//
//  ChatConversationsVC.h
//  Soleto
//
//  Created by Andrea Sponziello on 07/11/14.
//
//

#import <UIKit/UIKit.h>
//#import "SHPFirebaseTokenDelegate.h"
//#import <Firebase/Firebase.h>
#import "SHPConversationsViewDelegate.h"
#import "ChatPresenceHandler.h"
//#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"
//#import "SHPPushNotification.h"
//#import "SHPPushNotificationService.h"
//#import "SHPUserDC.h"
#import "ChatUser.h"

@import FirebaseDatabase;

//@class SHPApplicationContext;
//@class FirebaseCustomAuthHelper;
//@class SHPUser;
@class ChatConversationsHandler;
@class ChatGroupsHandler;
@class ChatImageCache;
@class ChatPresenceHandler;
@class SHPUserDC;
@class ChatContactsSynchronizer;

@interface ChatConversationsVC : UITableViewController <SHPConversationsViewDelegate, ChatPresenceViewDelegate, UIActionSheetDelegate, SHPModalCallerDelegate>
- (IBAction)testConnectionAction:(id)sender;

//- (IBAction)newQuoteAction:(id)sender;
//- (IBAction)newJobSkillAction:(id)sender;
- (IBAction)newGroupAction:(id)sender;
//- (IBAction)testAction:(id)sender;
//- (IBAction)printAction:(id)sender;
//- (IBAction)printGroupsAction:(id)sender;
- (IBAction)groupsAction:(id)sender;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *helpButton;
//- (IBAction)helpAction:(id)sender;

//@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *selectedConversationId;
@property (strong, nonatomic) NSString *selectedRecipient;
@property (strong, nonatomic) NSString *selectedRecipientFullname;
@property (strong, nonatomic) NSString *selectedRecipientTextToSend;
@property (strong, nonatomic) NSDictionary *selectedRecipientAttributesToSend;
@property (assign, nonatomic) BOOL groupsMode;
@property (strong, nonatomic) NSString *selectedGroupId;
//@property (strong, nonatomic) NSString *selectedGroupName;
@property (strong, nonatomic) ChatUser *me;
@property (strong, nonatomic) NSIndexPath *removingConversationAtIndexPath;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) ChatImageCache *imageCache;
@property (assign, nonatomic) int unread_count;
@property (strong, nonatomic) NSDictionary *settings;

// connection status
//@property (strong, nonatomic) FIRDatabaseReference *connectedRef;
@property (assign, nonatomic) FIRDatabaseHandle connectedRefHandle;
//@property (strong, nonatomic) FIRAuthStateDidChangeListenerHandle authStateDidChangeListenerHandle;
@property (strong, nonatomic) UIButton *usernameButton;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// user thumbs
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

//// user info
//@property (strong, nonatomic) SHPUserDC *userLoader;

@property (strong, nonatomic) ChatConversationsHandler *conversationsHandler;
@property (strong, nonatomic) ChatPresenceHandler *presenceHandler;
//@property (strong, nonatomic) ChatContactsSynchronizer *contactSynchronizer;

//-(void)openConversationWithUser:(NSString *)user;
-(void)initializeWithSignedUser; // call this on every signin
-(void)resetCurrentConversation;

//- (IBAction)newMessageAction:(id)sender;
- (IBAction)actionNewMessage:(id)sender;

//@property (strong, nonatomic) NSMutableDictionary *jobWizardContext;

- (IBAction)unwindToConversationsView:(UIStoryboardSegue*)sender;

-(void)openConversationWithRecipient:(ChatUser *)recipient;
-(void)openConversationWithRecipient:(ChatUser *)recipient orGroup:(NSString *)groupid sendMessage:(NSString *)text attributes:(NSDictionary *)attributes;

// it's bad using this from cellConfigurator to start an image download. SSS
//- (void)startIconDownload:(NSString *)username forIndexPath:(NSIndexPath *)indexPath;

-(void)setUIStatusDisconnected;
-(void)setUIStatusConnected;

-(void)logout;

@end

