//
//  HelloVC.m
//  tilechat
//
//  Created by Andrea Sponziello on 05/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HelloVC.h"
#import "HelloUser.h"
#import "SHPAppDelegate.h"
#import "HelloApplicationContext.h"
#import "HelloAuthTVC.h"
#import "SHPAppDelegate.h"
#import "HelpFacade.h"

@interface HelloVC ()

@end

@implementation HelloVC

- (void)viewDidLoad {
    [super viewDidLoad];
    SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.appName.text = [app.applicationContext.plistDictionary objectForKey:@"app-name"];
    
    [[HelpFacade sharedInstance] activateSupportBarButton:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    // here just to reduce the time that home controller is visible during signin out.
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    HelloUser *loggedUser = appDelegate.applicationContext.loggedUser;
    if (!loggedUser) {
        [self showLoginView];
        return;
    }
}

-(void)showLoginView {
    NSLog(@"PRESENTING LOGIN VIEW.");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"HelloChat" bundle:nil];
    HelloAuthTVC *vc = (HelloAuthTVC *)[sb instantiateViewControllerWithIdentifier:@"login-vc"];
    NSLog(@"vc = %@", vc);
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)helpAction:(id)sender {
    NSLog(@"Help in Home menu view.");
    [[HelpFacade sharedInstance] openSupportView:self];
}

-(void)helpWizardEnd:(NSDictionary *)context {
    NSLog(@"helpWizardEnd");
    [context setValue:NSStringFromClass([self class]) forKey:@"section"];
    [[HelpFacade sharedInstance] handleWizardSupportFromViewController:self helpContext:context];
}

@end
