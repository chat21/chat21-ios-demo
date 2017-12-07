//
//  HomeMenuSubOptionsTVC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 15/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HomeMenuSubOptionsTVC.h"
#import "SHPAppDelegate.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "DocMiniBrowserVC.h"

@interface HomeMenuSubOptionsTVC () {
    NSDictionary *selectedOption;
}
@end

@implementation HomeMenuSubOptionsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Applicazioni";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    if (self.subOptions.count > 0) {
        return self.subOptions.count;
    } else {
        return 1; // message cell
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.subOptions.count > 0) {
        NSDictionary *option = self.subOptions[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"option_cell" forIndexPath:indexPath];
        UILabel *message = (UILabel *)[cell viewWithTag:1];
        message.text = option[@"label"];
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
    NSLog(@"selected option: %@", self.subOptions[indexPath.row][@"id"]);
    NSLog(@"selected option class: %@", [self.subOptions[indexPath.row][@"id"] class]);
    selectedOption = self.subOptions[indexPath.row];
    [self performSegueWithIdentifier:@"webView" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"webView"]) {
        DocMiniBrowserVC *vc = (DocMiniBrowserVC *)[segue destinationViewController];
        vc.hiddenToolBar = YES;
        vc.titlePage = selectedOption[@"label"];
        //vc.username = self.app.loggedUser.username;
        //vc.password = self.app.loggedUser.password;
        // indirizzo: https://<username>:<password>@bppmobile.bpp.it/wsappintranetpre/autologinapp/<ID_APP> (campo: "id": "512”)
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        SHPUser *loggedUser = appDelegate.applicationContext.loggedUser;
        
        vc.urlPage = [[NSString alloc] initWithFormat:@"https://%@:%@@bppmobile.bpp.it/wsappintranetpre/autologinapp/%@", loggedUser.username, loggedUser.password, selectedOption[@"id"]];
        NSLog(@"show app page: %@", vc.urlPage);
    }
}

@end
