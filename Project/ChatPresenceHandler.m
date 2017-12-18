//
//  ChatPresenceHandler.m
//  Chat21
//
//  Created by Andrea Sponziello on 02/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatPresenceHandler.h"
//#import "SHPFirebaseTokenDC.h"
#import "SHPApplicationContext.h"
//#import "SHPUser.h"
#import "ChatUtil.h"
#import "ChatUser.h"
#import "ChatManager.h"
//#import <Firebase/Firebase.h>

@import Firebase;

@implementation ChatPresenceHandler

-(id)initWithTenant:(NSString *)tenant user:(ChatUser *)user {
    if (self = [super init]) {
//        self.firebaseRef = firebaseRef;
        self.rootRef = [[FIRDatabase database] reference];
        self.tenant = tenant;
        self.loggeduser = user;
    }
    return self;
}

//-(id)initWithFirebaseRef:(NSString *)firebaseRef tenant:(NSString *)tenant user:(SHPUser *)user {
//    if (self = [super init]) {
//        self.firebaseRef = firebaseRef;
//        self.tenant = tenant;
//        self.loggeduser = user;
//    }
//    return self;
//}

//- (void)connect {
//    //    NSLog(@"Firebase login with username %@...", self.me);
//    //    if (!self.me) {
//    //        NSLog(@"ERROR: First set .me property with a valid username.");
//    //    }
//    //    [self firebaseLogin];
//    NSLog(@"connecting handler %@ to firebase: %@", self, self.firebaseRef);
//    [self setupMyConnections];
//}

+(FIRDatabaseReference *)lastOnlineRefForUser:(NSString *)userid {
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *lastOnlineRefURL = [[NSString alloc] initWithFormat:@"apps/%@/presence/%@/lastOnline",tenant, userid];
    FIRDatabaseReference *lastOnlineRef = [[[FIRDatabase database] reference] child:lastOnlineRefURL];
    return lastOnlineRef;
}

+(FIRDatabaseReference *)onlineRefForUser:(NSString *)userid {
    NSString *tenant = [ChatManager getInstance].tenant;
    NSString *myConnectionsRefURL = [[NSString alloc] initWithFormat:@"apps/%@/presence/%@/connections",tenant, userid];
    NSLog(@"Presence. myConnectionsRefURL: %@", myConnectionsRefURL);
    FIRDatabaseReference *connectionsRef = [[[FIRDatabase database] reference] child:myConnectionsRefURL];
    return connectionsRef;
}

-(void)setupMyPresence {
    // since I can connect from multiple devices, we store each connection instance separately
    // any time that connectionsRef's value is null (i.e. has no children) I am offline
    NSString *userid = self.loggeduser.userId;
    FIRDatabaseReference *myConnectionsRef = [ChatPresenceHandler onlineRefForUser:userid];
    FIRDatabaseReference *lastOnlineRef = [ChatPresenceHandler lastOnlineRefForUser:userid];
    
//    NSString *connectedRefURL = [[NSString alloc] initWithFormat:@"%@/.info/connected", self.firebaseRef];
    NSString *connectedRefURL = @"/.info/connected";
    FIRDatabaseReference *connectedRef = [[[FIRDatabase database] reference] child:connectedRefURL];
    if (self.connectionsRefHandle) {
        [connectedRef removeObserverWithHandle:self.connectionsRefHandle];
    }
    self.connectionsRefHandle = [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"> Connected (or reconnected after connection loss). Snapshot: %@", snapshot);
        NSLog(@"  Snapshot.value: %@", snapshot.value);
        if([snapshot.value boolValue]) {
            // connection established (or I've reconnected after a loss of connection)
            
            // add this device to my connections list
            // this value could contain info about the device or a timestamp instead of just true
            NSLog(@"self.deviceConnectionRef: %@", self.deviceConnectionRef);
            if (!self.deviceConnectionRef) {
                if (self.deviceConnectionKey) {
                    self.deviceConnectionRef = [myConnectionsRef child:self.deviceConnectionKey];
                }
                else {
                    self.deviceConnectionRef = [myConnectionsRef childByAutoId];
                    self.deviceConnectionKey = self.deviceConnectionRef.key;
                }
                NSLog(@"Connected Ref ID: %@", self.deviceConnectionRef);
                [self.deviceConnectionRef setValue:@YES];
                // when this device disconnects, remove it
                [self.deviceConnectionRef onDisconnectRemoveValue];
                // when I disconnect, update the last time I was seen online
                [lastOnlineRef onDisconnectSetValue:[FIRServerValue timestamp]];
            } else {
                NSLog(@"This is an error. self.deviceConnectionRef already set. Cannot be set again.");
            }
        }
    }];
}

-(void)goOffline {
    NSString *connectedRefURL = @"/.info/connected";
    FIRDatabaseReference *connectedRef = [[[FIRDatabase database] reference] child:connectedRefURL];
    [connectedRef removeObserverWithHandle:self.connectionsRefHandle];
    [self.deviceConnectionRef removeValue];
    NSString *userid = self.loggeduser.userId;
    FIRDatabaseReference *lastOnlineRef = [ChatPresenceHandler lastOnlineRefForUser:userid];
    [lastOnlineRef setValue:[FIRServerValue timestamp]];
    self.deviceConnectionRef = nil;
}

@end
