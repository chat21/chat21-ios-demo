//
//  HelloApplicationContext.h
//  Shopper
//
//  Created by andrea sponziello on 08/08/17.
//
//

#import <Foundation/Foundation.h>

@class HelloUser;

@interface HelloApplicationContext: NSObject

@property (strong, nonatomic) HelloUser *loggedUser;
//@property (nonatomic, strong) UITabBarController *tabBarController;

//@property (strong, nonatomic) NSString *tenant;
@property (nonatomic, strong) NSDictionary *settings;

//@property (nonatomic, strong) NSMutableDictionary *properties;

//- (void)setVariable:(NSString *)key withValue:(NSObject *)value;
//- (NSObject *)getVariable:(NSString *)key;
//- (void)removeVariable:(NSString *)key;
//- (NSDictionary *)variablesDictionary;

//+(int)tabIndexByName:(NSString *)tab_name;

- (void)signout;
- (void)signin:(HelloUser *)user;

//-(void)setFirstLaunchDone;
//-(BOOL)isFirstLaunch;

+(HelloApplicationContext *)getSharedInstance;

@end
