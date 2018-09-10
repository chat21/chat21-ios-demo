//
//  HelpAction.h
//  chat21
//
//  Created by Andrea Sponziello on 12/06/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HelpDepartment;

@interface HelpAction : NSObject

-(void)openSupportView:(UIViewController *)sourcevc;

//@property (nonatomic, copy) void (^endWizardCallback)(NSDictionary *attributes);
@property (nonatomic, strong) UIViewController *sourcevc;
//@property (strong, nonatomic) NSMutableDictionary *context;

@property (strong, nonatomic) HelpDepartment *department;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSDictionary *attributes;

-(void)dismissWizardAndOpenMessageViewWithSupport;

@end
