//
//  SHPApplicationContext.h
//  Shopper
//
//  Created by andrea sponziello on 08/08/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPApplicationSettings.h"

@class HelloUser;
@class SHPConnectionsController;
@class SHPFacebookConnectionsHandler;
@class SHPObjectCache;
@class SHPFacebookPage;
@class SHPShop;
@class ChatManager;

@interface SHPApplicationContext: NSObject

@property (strong, nonatomic) HelloUser *loggedUser;
@property (nonatomic, strong) UITabBarController *tabBarController;

@property (nonatomic, strong) SHPApplicationSettings *settings;
@property (strong, nonatomic) NSString *tenant;
@property (nonatomic, strong) NSDictionary *plistDictionary;

@property (nonatomic, strong) NSMutableDictionary *properties;

- (void)setVariable:(NSString *)key withValue:(NSObject *)value;
- (NSObject *)getVariable:(NSString *)key;
- (void)removeVariable:(NSString *)key;
- (NSDictionary *)variablesDictionary;

+(int)tabIndexByName:(NSString *)tab_name;

- (void)signout;
- (void)signin:(HelloUser *)user;

-(void)setFirstLaunchDone;
-(BOOL)isFirstLaunch;

+(SHPApplicationContext *)getSharedInstance;

@end
