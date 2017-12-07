//
//  MRJobSkillPreviewStepTVC.m
//  misterlupo
//
//  Created by Andrea Sponziello on 29/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "MRJobSkillPreviewStepTVC.h"
#import "MRJobCategory.h"
#import "SHPAppDelegate.h"

@interface MRJobSkillPreviewStepTVC ()

@end

@implementation MRJobSkillPreviewStepTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.titleLabel.text = NSLocalizedString(@"summary title", nil);
    self.skillTitleLabel.text = NSLocalizedString(@"summary skill", nil);
    self.whereTitleLabel.text = NSLocalizedString(@"summary where", nil);
    self.telephoneTitleLabel.text = NSLocalizedString(@"summary telephone", nil);
    self.cvTitleLabel.text = NSLocalizedString(@"summary cv", nil);
    self.sendButton.title = NSLocalizedString(@"summary send", nil);
    self.navigationItem.title = NSLocalizedString(@"summary view title", nil);
    
    MRJobCategory *selectedCategory = [self.context objectForKey:@"category"];
    NSString *cat_name = selectedCategory.nameInCurrentLocale;
    //NSString *path_id = selectedCategory.pathId;
    self.categoryLabel.text = [NSString stringWithFormat:@"%@", cat_name];
    self.whereLabel.text = (NSString *)[self.context objectForKey:@"position"];
    self.descriptionLabel.text = (NSString *)[self.context objectForKey:@"description"];
    self.telephoneLabel.text = (NSString *)[self.context objectForKey:@"telephone"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 160.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        return UITableViewAutomaticDimension;
    }
    return 88;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.rowHeights) {
//        NSNumber *_height = (NSNumber *)[self.rowHeights objectForKey:@(indexPath.row)];
//        float cell_height = _height.floatValue;
//        if (cell_height > 0) {
//            //            NSLog(@"returning estimated height for row %ld of %f", indexPath.row, cell_height);
//            return cell_height;
//        }else {
//            //            NSLog(@"OOPS NO estimated height for row: %ld", indexPath.row);
//            
//        }
//    }
//    return UITableViewAutomaticDimension;
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)sendAction:(id)sender {
    UIAlertController * view =   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:NSLocalizedString(@"summary send dialog title", nil)
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* sendStepAskPush = [UIAlertAction
                           actionWithTitle:NSLocalizedString(@"summary send dialog yes", nil)
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               NSLog(@"Sending request");
                               [self sendStepAskPush];
                           }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"summary send dialog not yet", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"action canceled");
                             }];
    [view addAction:sendStepAskPush];
    [view addAction:cancel];
    // for ipad
    view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:view animated:YES completion:nil];
}

-(void)sendStepAskPush {
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *advice = [userPreferences objectForKey:@"PUSH_ADVICE_SHOWN"];
    if (advice != nil) {
        [self send];
        return;
    }
    
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Attiva le notifiche push quando ti verrà richiesto in modo da ricevere i messaggi degli utenti che vogliono contattarti"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* send = [UIAlertAction
                           actionWithTitle:@"Ok"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
                               [userPreferences setBool:YES forKey:@"PUSH_ADVICE_SHOWN"];
                               [userPreferences synchronize];
                               SHPAppDelegate *app = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
                               [app startPushNotifications];
                               [self send];
                           }];
    
    [view addAction:send];
    // for ipad
    view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:view animated:YES completion:nil];
}

-(void)send {
    NSLog(@"sending: %@", self.context);
    [self.context setObject:self forKey:@"source-view-controller"];
    id vc = [self.context objectForKey:@"view-controller"];
    NSLog(@"vc: %@", vc);
    if ([vc respondsToSelector:@selector(jobWizardEnd:)]) {
        NSLog(@"performing selector...");
        [vc performSelector:@selector(jobWizardEnd:) withObject:self.context];
    }
}

@end
