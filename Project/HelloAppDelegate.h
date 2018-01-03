//
//  HelloAppDelegate.h
//
//  Created by andrea sponziello on 24/05/17.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@class HelloApplicationContext;
@class MBProgressHUD;

@interface HelloAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HelloApplicationContext *applicationContext;
@property (assign, nonatomic) BOOL registeredToAPN;
@property (strong, nonatomic) NSString *deviceToken;
@property(nonatomic, strong) MBProgressHUD *hud;

-(void)startPushNotifications;

@end
