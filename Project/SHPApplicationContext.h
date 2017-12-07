//
//  SHPApplicationContext.h
//  Shopper
//
//  Created by andrea sponziello on 08/08/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPApplicationSettings.h"
#import "SHPImageCache.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoRepositoryInfo.h"

@class SHPUser;
@class CLLocation;
@class SHPConnectionsController;
@class SHPFacebookConnectionsHandler;
@class SHPObjectCache;
@class SHPFacebookPage;
@class SHPShop;
@class ChatManager;

@interface SHPApplicationContext: NSObject

@property (nonatomic, strong) NSMutableArray *onDiskLastUsedShops;
@property (nonatomic, strong) NSMutableDictionary *onDiskLastProductForm;
@property (nonatomic, strong) NSMutableDictionary *onDiskData;
@property (strong, nonatomic) SHPUser *loggedUser;
@property (strong, nonatomic) SHPImageCache *productDetailImageCache;
@property (nonatomic, strong) SHPImageCache *mainListImageCache;
@property (nonatomic, strong) SHPImageCache *smallImagesCache;
@property (nonatomic, strong) SHPImageCache *categoryIconsCache;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSString *lastLocationName;
@property (nonatomic, strong) CLLocation *searchLocation;
@property (nonatomic, strong) NSString *searchLocationName;
@property (nonatomic, strong) SHPConnectionsController *connectionsController;
@property (nonatomic, strong) SHPFacebookConnectionsHandler *facebookConnections;
@property (nonatomic, strong) SHPObjectCache *objectsCache;
@property (nonatomic, strong) NSMutableArray *backgroundConnections;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (strong, nonatomic) SHPFacebookPage *postToFacebookPage;

@property (nonatomic, strong) SHPApplicationSettings *settings;
@property (strong, nonatomic) NSString *tenant;
@property (nonatomic, strong) NSDictionary *plistDictionary;
@property (nonatomic, assign) BOOL permissionUpload;

@property (nonatomic, strong) NSMutableDictionary *properties;

@property (nonatomic, strong) NSMutableDictionary *dictionaryArrayCart;
@property (nonatomic, strong) ChatManager *chatManager;

@property (nonatomic, strong) AlfrescoRepositorySession *docSession;
@property (nonatomic, strong) AlfrescoRepositoryInfo *docInfo;
@property (nonatomic, strong) AlfrescoFolder *docStartFolder;

- (void)setVariable:(NSString *)key withValue:(NSObject *)value;
- (NSObject *)getVariable:(NSString *)key;
- (void)removeVariable:(NSString *)key;
- (NSDictionary *)variablesDictionary;

+(void)saveSearchLocation:(CLLocation *)searchLocation;
+(CLLocation *)restoreSearchLocation;
+(void)saveSearchLocationName:(NSString *)searchLocationName;
+(NSString *)restoreSearchLocationName;
+(void)deleteSearchLocationInfo;
+(void)saveLastPhone:(NSString *)phone;
+(void)saveLastEmail:(NSString *)email;
+(NSString *)restoreLastPhone;
+(NSString *)restoreLastEmail;
+(int)tabIndexByName:(NSString *)tab_name;// context:(SHPApplicationContext *)context;

//+(void)saveLastWizardShop:(SHPShop *)shop;
//+(SHPShop *)restoreLastWizardShop;
//+(void)openConversationViewWith:(NSString *)userid context:(SHPApplicationContext *)context;

- (void)signout;
- (void)signin:(SHPUser *)user;
//- (void)switchToSignedInTabs;
//- (void)switchToSignedOutTabs;
//- (void)switchToSignedTabs:(bool)stateLogged;

-(void)setFirstLaunchDone;
-(BOOL)isFirstLaunch;
-(void)saveOnDiskData;

+(SHPApplicationContext *)getSharedInstance;

@end
