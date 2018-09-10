//
//  HelpAction.m
//  chat21
//
//  Created by Andrea Sponziello on 12/06/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import "HelpAction.h"
#import "HelpStartVC.h"
#import "ChatUser.h"
#import "ChatUIManager.h"
#import "HelpDepartment.h"

@implementation HelpAction

-(void)openSupportView:(UIViewController *)sourcevc {
//    self.context = [[NSMutableDictionary alloc] init];
    self.sourcevc = sourcevc;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Help_request" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"help-wizard"];
    HelpStartVC *firstStep = (HelpStartVC *)[[nc viewControllers] objectAtIndex:0];
    firstStep.helpAction = self;
//    self.endWizardCallback = ^(NSDictionary *attributes) {
        // TODO send metadata
        // TODO remove System's messages
        
//        ChatUser *recipient = [[ChatUser alloc] init:support_group_id fullname:@"Support"];
//        [[ChatUIManager getInstance] openConversationMessagesViewAsModalWith:(ChatUser *)recipient  viewController:self attributes:nil withCompletionBlock:^{
//            NSLog(@"Messages view dismissed.");
//        }];
//    };
//    firstStep.endWizardCallback = self.endWizardCallback;
    //    firstStep.context = [[NSMutableDictionary alloc] init];
    //    [firstStep.context setObject:sourcevc forKey:@"view-controller"];
    [sourcevc presentViewController:nc animated:YES completion:^{
        // NSLog(@"Presented");
    }];
}

-(void)dismissWizardAndOpenMessageViewWithSupport {
    
//    HelpDepartment *dep = (HelpDepartment *)[self.context objectForKey:@"department"];
    NSLog(@"department: %@[%@]", self.department.name, self.department.departmentId);
    NSString * uuid = [[NSUUID UUID] UUIDString];
    NSString *support_group_id = [[NSString alloc] initWithFormat:@"support-group-%@", uuid];
    NSLog(@"opening conversation with support group id: %@", support_group_id);
    // attributes setObject department
    // attributes setObject iPhone (vedi devices)
    
//    // TODO MANCA SENDING MESSAGE
//    [self.sourcevc dismissViewControllerAnimated:YES completion:^{
////        ChatUser *recipient = [[ChatUser alloc] init:support_group_id fullname:@"Support"];
//        [[ChatUIManager getInstance] openConversationMessagesViewAsModalWith:(ChatUser *)recipient  viewController:self.sourcevc attributes:self.attributes withCompletionBlock:^{
//            NSLog(@"Messages view dismissed.");
//        }];
//    }];
    
}

@end
