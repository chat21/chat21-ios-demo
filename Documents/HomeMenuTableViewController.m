//
//  HomeMenuTableViewController.m
//  misterlupo
//
//  Created by Andrea Sponziello on 18/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HomeMenuTableViewController.h"
#import "DocAuthTVC.h"
#import "SHPApplicationContext.h"
#import "DocAuthTVC.h"
#import "SHPUser.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "HomeMenuDC.h"
#import "SHPAppDelegate.h"
#import "DocAppMenuOption.h"
#import "HomeMenuSubOptionsTVC.h"
#import "DocVersionControlDC.h"
#import "HelpFacade.h"

@interface HomeMenuTableViewController () {
    BOOL firstAppear;
    BOOL verifyAppVersionOnStartup;
    MBProgressHUD *HUD;
    BOOL loading;
    BOOL errorLoadingData;
    NSMutableArray<DocAppMenuOption *> *menuOptions;
    DocAppMenuOption *selectedOption;
    SHPUser *currentUser;
}

@end

@implementation HomeMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Home";
    firstAppear = YES;
    [[HelpFacade sharedInstance] activateSupportBarButton:self];
    SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
    verifyAppVersionOnStartup = [app.applicationContext.plistDictionary[@"verifyAppVersionOnStartup"] boolValue];
}

-(BOOL)loadCachedMenu {
    return false;
}

//-(void)reachabilityChanged:(NSNotification*)notification
//{
//    NSLog(@"reachabilityChanged.");
//    Reachability* reachability = notification.object;
//    if(reachability.currentReachabilityStatus == NotReachable)
//        NSLog(@"Internet off");
//    else
//        NSLog(@"Internet on");
//}

-(void)showWaiting:(NSString *)label {
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:HUD];
    }
    HUD.center = self.view.center;
    HUD.labelText = label;
    HUD.animationType = MBProgressHUDAnimationZoom;
    [HUD show:YES];
}

-(void)hideWaiting {
    [HUD hide:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    // here just to reduce the time that home controller is visible during signin out.
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    SHPUser *loggedUser = appDelegate.applicationContext.loggedUser;
    if (!loggedUser) {
        [self showLoginView];
        return;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"HomeMenuTableViewController didAppear");
    //    if (!firstAppear) {
    //        return;
    //    }
    if (firstAppear) {
        if (verifyAppVersionOnStartup) {
            DocVersionControlDC *dc = [[DocVersionControlDC alloc] init];
            [dc getVersionWithCompletion:^(BOOL newVersionAvailable, NSError *error) {
                if (error) {
                    NSLog(@"errore durante caricamento numero versione disponibile: %@", error);
                }
                else if (newVersionAvailable) {
                    NSLog(@"New version available");
                    [self showVersionAvailable];
                }
                else {
                    NSLog(@"Actual version is the last available.");
                }
            }];
        }
        firstAppear = NO;
    }
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    SHPUser *loggedUser = appDelegate.applicationContext.loggedUser;
    
    if (!currentUser || ![currentUser.username isEqualToString:loggedUser.username]) {
        loading = YES;
        menuOptions = nil;
        [self.tableView reloadData];
        currentUser = loggedUser;
    }
    
    HomeMenuDC *dc = [[HomeMenuDC alloc] init];
    __weak HomeMenuTableViewController *weakSelf = self;
    loading = YES;
    errorLoadingData = NO;
    [dc getMenuMap:loggedUser completion:^(NSDictionary *menumap) {
        NSLog(@"Sincronizzazione menù completata: %@", menumap);
        loading = NO;
        if (menumap[@"error"]) {
            NSLog(@"error loading menu options");
            menuOptions = nil;
            errorLoadingData = YES;
        }
        else {
            errorLoadingData = NO;
            // build options
            menuOptions = [[NSMutableArray alloc] init];
            for (NSString *option_key in menumap.allKeys) {
                NSLog(@"adding option: %@", [menumap[option_key] class]);
                DocAppMenuOption *option = [[DocAppMenuOption alloc] init];
                option.subOptions = menumap[option_key];
                option.name = [option_key lowercaseString];
                NSLog(@"option.name %@", option.name);
                [menuOptions addObject:option];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (IBAction)showVersionAvailable {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Nuova versione disponibile"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Verifica aggiornamento"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSLog(@"Vado su testflight");
                             NSURL *customAppURL = [NSURL URLWithString:@"itms-beta://"];
                             if ([[UIApplication sharedApplication] canOpenURL:customAppURL]) {
                                 
                                 // TestFlight is installed
                                 
                                 // Special link that includes the app's Apple ID
                                 customAppURL = [NSURL URLWithString:@"https://beta.itunes.apple.com/v1/app/1264716913"];
                                 [[UIApplication sharedApplication] openURL:customAppURL];
                             }
                         }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"quote summary send dialog not yet", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"action canceled");
                             }];
    [view addAction:ok];
    [view addAction:cancel];
    // for ipad
    //view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:view animated:YES completion:nil];
}

-(void)showLoginView{
    NSLog(@"PRESENTING LOGIN VIEW.");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DocNavigator" bundle:nil];
    DocAuthTVC *vc = (DocAuthTVC *)[sb instantiateViewControllerWithIdentifier:@"login-vc"];
    NSLog(@"vc = %@", vc);
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (menuOptions.count > 0) {
        return menuOptions.count;
    } else {
        return 1; // message cell
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (loading == YES) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"message_cell" forIndexPath:indexPath];
        UILabel *message = (UILabel *)[cell viewWithTag:1];
        message.text = @"Caricamento menù...";
        cell.userInteractionEnabled = NO;
    }
    else if (errorLoadingData == YES) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"message_cell" forIndexPath:indexPath];
        UILabel *message = (UILabel *)[cell viewWithTag:1];
        message.text = @"Menù non disponibile";
        cell.userInteractionEnabled = NO;
    }
    else if (menuOptions.count > 0) {
        DocAppMenuOption *option = menuOptions[indexPath.row];
        NSLog(@"option rendering: %@", option);
        NSString *cell_area_name = [[NSString alloc] initWithFormat:@"%@_cell", option.name];
        cell = [tableView dequeueReusableCellWithIdentifier:cell_area_name forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"message_cell" forIndexPath:indexPath];
        UILabel *message = (UILabel *)[cell viewWithTag:1];
        message.text = @"Nessuna applicazione disponibile.";
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"selected option: %@", menuOptions[indexPath.row].name);
    selectedOption = menuOptions[indexPath.row];
    [self performSegueWithIdentifier:@"sub_options_segue" sender:self];
    //    [self performSegueWithIdentifier:@"modaltest" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"sub_options_segue"]) {
        HomeMenuSubOptionsTVC *vc = (HomeMenuSubOptionsTVC *)[segue destinationViewController];
        vc.subOptions = selectedOption.subOptions;
    }
}

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

