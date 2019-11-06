//
//  HelloSelectUserViewController.h
//  chat21
//
//  Created by Andrea Sponziello on 04/11/2019.
//  Copyright © 2019 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectContactProtocol.h"

@class ChatUser;

NS_ASSUME_NONNULL_BEGIN

@interface HelloSelectUserViewController : UIViewController <ChatSelectContactProtocol>

@property (nonatomic, copy) void (^ _Nullable completionCallback)( ChatUser * _Nullable contact, BOOL canceled);

- (IBAction)selectUserAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
