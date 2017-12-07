//
//  ChatSettingsTVC.m
//  Chat21
//
//  Created by Andrea Sponziello on 30/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatSettingsTVC.h"
#import "SHPMiniWebBrowserVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPModifyProfileTVC.h"

@implementation ChatSettingsTVC

-(void)viewDidLoad {
    [super viewDidLoad];
    if(!self.applicationContext) {
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    
    NSString *versionApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];

//    NSString *versionApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)];
//    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundle];
    self.versionLabel.text = [[NSString alloc] initWithFormat:@"%@ build %@", versionApp, build];
    
    [self setup];
}

-(void)setup {
    self.changeFullNameLabel.text = NSLocalizedString(@"change fullname", nil);
    self.changePasswordLabel.text = NSLocalizedString(@"change password", nil);
    self.privacyLabel.text = NSLocalizedString(@"ChatPrivacy", nil);
    self.termsLabel.text = NSLocalizedString(@"ChatTerms", nil);
    self.navigationItem.title = NSLocalizedString(@"ChatSettingsMenuOption", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"settingsLegalSection", nil);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    NSString *lang = [self getLangCode];
    // default language = "en"
    if (![lang isEqualToString:@"en"] && ![lang isEqualToString:@"it"]) {
        lang = @"en";
    }
    NSLog(@"SELECTED LANG = %@",lang);
    
    
//    if([theString isEqualToString:@"idCellTerms"]){
//        //        listMode = @"LIKED";
//        //        rowSelected =  self.labelPiaciuti.text;
//        //        listProducts = listProductsLiked;
//        //        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
//        ChatSettingsTVC *settingsVC = [sb instantiateViewControllerWithIdentifier:@"ChatSettings"];
//        [self.navigationController pushViewController:settingsVC animated:YES];
//    }
    //    else if([theString isEqualToString:@"idCellCreated"]){
    //        listMode = @"CREATED";
    //        rowSelected =  self.labelCreati.text;
    //        listProducts = listProductsCreated;
    //        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
    //    }
    //    else if([theString isEqualToString:@"idCellLiked"]){
    //        listMode = @"LIKED";
    //        rowSelected =  self.labelPiaciuti.text;
    //        listProducts = listProductsLiked;
    //        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
    //    }
    //    else if([theString isEqualToString:@"idCellFacebook"]){
    //        //[self agganciaSganciaFacebook];
    //    }
    if([theString isEqualToString:@"idCellPrivacy"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"MainStoryboard" bundle:[NSBundle mainBundle]];
        SHPMiniWebBrowserVC *browserVC = [storyboard instantiateViewControllerWithIdentifier:@"MiniWebBrowser"];
        browserVC.applicationContext = self.applicationContext;
        browserVC.hiddenToolBar = YES;
        browserVC.titlePage = NSLocalizedString(@"ChatPrivacy", nil);
        browserVC.urlPage = [[NSString alloc] initWithFormat:@"http://www.labot.org/privacy-%@", lang];
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else if([theString isEqualToString:@"idCellTerms"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"MainStoryboard" bundle:[NSBundle mainBundle]];
        SHPMiniWebBrowserVC *browserVC = [storyboard instantiateViewControllerWithIdentifier:@"MiniWebBrowser"];
        browserVC.applicationContext = self.applicationContext;
        browserVC.hiddenToolBar = YES;
        browserVC.titlePage = NSLocalizedString(@"ChatTerms", nil);
        browserVC.urlPage = [[NSString alloc] initWithFormat:@"http://www.labot.org/terms-%@", lang];
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else if([theString isEqualToString:@"idCellLogout"]) {
        NSLog(@"LOGOUT");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChatSignoutAlert", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ChatCancel", nil) otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if([theString isEqualToString:@"idCellModifyUser"]) {
        [self performSegueWithIdentifier:@"ModifyUserSegue" sender:self];
    }
    else if([theString isEqualToString:@"idCellChangePassword"]) {
        [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:self];
    }
}

-(NSString *)getLangCode {
    NSString *localeId = [[NSLocale currentLocale] localeIdentifier];
    NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:localeId];
    NSLog(@"[NSLocale componentsFromLocaleIdentifier:localeId] = %@", components);
    NSString *languagecode = components[@"kCFLocaleLanguageCodeKey"];
    NSString *countrycode = components[@"kCFLocaleCountryCodeKey"];
    NSLog(@"languagecode (kCFLocaleLanguageCodeKey) = %@", languagecode);
    NSLog(@"countrycode (kCFLocaleCountryCodeKey) = %@", countrycode);
    return languagecode;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ModifyUserSegue"]) {
        SHPModifyProfileTVC *vc = (SHPModifyProfileTVC *)[segue destinationViewController];
        vc.modifyType = @"fullName";
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"ChangePasswordSegue"]) {
        SHPModifyProfileTVC *vc = (SHPModifyProfileTVC *)[segue destinationViewController];
        vc.modifyType = @"password";
        vc.applicationContext = self.applicationContext;
    }
}

//- (void)tableView:(UITableView *)tableView
//didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSUInteger section = [indexPath section];
//    NSUInteger row = [indexPath row];
//    
//    switch (section)
//    {
//        case SECTION_SPEED:
//            self.speed = row;
//            [defaults setInteger:row forKey:kUYLSettingsSpeedKey];
//            break;
//        case SECTION_VOLUME:
//            self.volume = row;
//            [defaults setInteger:row forKey:kUYLSettingsVolumeKey];
//            break;
//    }
//    [self.tableView reloadData];
//}

- (IBAction)unwindToChatSettingsTVC:(UIStoryboardSegue*)sender {
    NSLog(@"unwind ok.");
}

@end
