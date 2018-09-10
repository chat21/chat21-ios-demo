//
//  HelpStartVC.m
//  chat21
//
//  Created by Andrea Sponziello on 05/06/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import "HelpStartVC.h"
#import "HelpDataService.h"
#import "HelpDepartment.h"
#import "HelpCategoryStepTVC.h"
#import "HelpDescriptionStepTVC.h"
#import "HelpLocal.h"
#import "HelpAction.h"

@interface HelpStartVC ()

@end

@implementation HelpStartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.context = [[NSMutableDictionary alloc] init];
    
    self.cancelButton.title = [HelpLocal translate:@"cancel"];
//    [self.context setObject:@"test value" forKey:@"test key"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
    HelpDataService *service =[[HelpDataService alloc] init];
    [service downloadDepartmentsWithCompletionHandler:^(NSArray<HelpDepartment *> *departments, NSError *error) {
        // TODO
        NSLog(@"count deps: %lu", (unsigned long)departments.count);
        for (HelpDepartment *dep in departments) {
            NSLog(@"dep id: %@, name: %@ isDefault: %d", dep.departmentId, dep.name, dep.isDefault);
        }
        if (departments.count == 1) {
            // set context.department = default
            self.helpAction.department = departments[0];
            // perform message-segue
            [self performSegueWithIdentifier:@"message-segue" sender:self];
        }
        else if (departments.count > 1) {
            NSMutableArray<HelpDepartment *> *mutableDeps = [departments mutableCopy];
            for (int i = 0; i < mutableDeps.count; i++) {
                HelpDepartment *dep = mutableDeps[i];
                if (dep.isDefault) {
                    [mutableDeps removeObjectAtIndex:i];
                }
            }
            self.departments = mutableDeps;
            [self performSegueWithIdentifier:@"departments-segue" sender:self];
        }
        else {
            // error, deps.couont can't be 0
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"departments-segue"]) {
        NSObject *vc = [segue destinationViewController];
        [vc setValue:self.helpAction forKey:@"helpAction"];
        [vc setValue:self.departments forKey:@"departments"];
    }
    else if ([segue.identifier isEqualToString:@"message-segue"]) {
        NSObject *vc = [segue destinationViewController];
        [vc setValue:self.helpAction forKey:@"helpAction"];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
