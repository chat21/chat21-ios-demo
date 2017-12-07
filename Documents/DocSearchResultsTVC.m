//
//  DocSearchResultsTVC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 21/08/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocSearchResultsTVC.h"
#import "AlfrescoNode.h"
#import "DocNodeCell.h"
#import "DocNavigatorTVC.h"
#import "AlfrescoFolder.h"
#import "DocMiniBrowserVC.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"

@interface DocSearchResultsTVC ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation DocSearchResultsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searching || self.searchNodes.count == 0) {
        return 1;
    }
    else {
        return self.searchNodes.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NodeCellIdentifier = @"node-cell";
    static NSString *LoadingCellIdentifier = @"loading-cell";
    static NSString *MessageCellIdentifier = @"message-cell";
    
    UITableViewCell *cell;
    if (self.searching) {
        
        cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *activity = [cell viewWithTag:1];
        [activity startAnimating];
        activity.hidden = NO;
        UILabel *label = [cell viewWithTag:2];
        label.text = @"Ricerca in corso...";
        
        // in alternativa activity indicator nella search bar qui:
        // https://stackoverflow.com/questions/1209842/replace-bookmarkbutton-with-activityindicator-in-uisearchbar
    }
    else if (self.searchNodes.count == 0) {
        cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier forIndexPath:indexPath];
        UILabel *label = [cell viewWithTag:1];
        if ([self.textToSearch isEqualToString:@""]) {
            label.text = @"";
        }
        else {
            label.text = @"Nessun risultato";
        }
    }
    else { // nodes found, rendering...
        AlfrescoNode *node = nil;
        node = [self.searchNodes objectAtIndex:indexPath.row];
        if (node.isFolder) {
            DocNodeCell *nodeCell = (DocNodeCell *) [tableView dequeueReusableCellWithIdentifier:NodeCellIdentifier forIndexPath:indexPath];
            cell = nodeCell;
            nodeCell.nodeName.text = node.name;
            nodeCell.nodeIcon.image = [UIImage imageNamed:@"cartella.png"];
            nodeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            DocNodeCell *nodeCell = (DocNodeCell *) [tableView dequeueReusableCellWithIdentifier:NodeCellIdentifier forIndexPath:indexPath];
            cell = nodeCell;
            nodeCell.nodeName.text = node.name;
            nodeCell.nodeIcon.image = [UIImage imageNamed:@"ic_unknown.png"];
            nodeCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

@end
