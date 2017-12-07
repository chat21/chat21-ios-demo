//
//  MRCategoryStepTVC.m
//  misterlupo
//
//  Created by Andrea Sponziello on 06/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "MRCategoryStepTVC.h"
#import "MRJobCategory.h"

@interface MRCategoryStepTVC ()

@end

@implementation MRCategoryStepTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]];
    NSArray *plist_categories = [dictionary objectForKey:@"misterlupo-categories"];
    if (self.category) {
        // selected category & children
        self.categories = self.category.children;
    }
    else {
        self.categories = [[NSMutableArray alloc] init];
        for (NSDictionary *cat in plist_categories) {
            MRJobCategory *category = [[MRJobCategory alloc] initWithDictionary:cat parent:nil];
            [self.categories addObject:category];
        }
    }
    if (!self.category) {
        self.cancelButton.title = NSLocalizedString(@"cancel", nil);
        self.navigationItem.title = NSLocalizedString(@"quote view title", nil);
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.title = self.category.nameInCurrentLocale;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 88;
    } else {
        MRJobCategory *category = self.categories[indexPath.row];
        NSLog(@"CATEGORY FOR HEIGHT = %@ image: %@", category.nameInCurrentLocale, category.imageName);
        if (category.parent) {
            return 44;
        } else {
            return 88;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.categories.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"title-cell" forIndexPath:indexPath];
        UILabel *titleLabel = [cell viewWithTag:1];
        titleLabel.text = NSLocalizedString(@"quote title", nil);
    }
    if (indexPath.section == 1) {
        MRJobCategory *category = self.categories[indexPath.row];
        if (category.parent) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"category-cell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"root-category-cell" forIndexPath:indexPath];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
            imageView.image = [UIImage imageNamed:category.imageName];
        }
        UILabel *categoryLabel = (UILabel *)[cell viewWithTag:1];
        categoryLabel.text = category.nameInCurrentLocale;
    }
    
    return cell;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 1) {
//        [self.context setObject:[self.categories objectAtIndex:indexPath.row] forKey:@"category"];
//        [self performSegueWithIdentifier:@"next" sender:self];
//    }
    
    MRJobCategory *selectedCategory = [self.categories objectAtIndex:indexPath.row];
    if (selectedCategory.children) {
        // call yourself, no prepareForSegue is called, all init here.
        MRCategoryStepTVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"request-vc"];
        vc.category = selectedCategory;
        vc.context = self.context;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.context setObject:selectedCategory forKey:@"category"];
        [self performSegueWithIdentifier:@"next" sender:self];
    }
    
//    NSLog(@"context %@", self.context);
}

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"next"]) {
        NSObject *vc = (NSObject *)[segue destinationViewController];
        [vc setValue:self.context forKey:@"context"];
    }
}

- (IBAction)cancelAction:(id)sender {
    NSLog(@"cancel");
    [self.context setObject:self forKey:@"source-view-controller"];
    id vc = [self.context objectForKey:@"view-controller"];
    NSLog(@"vc: %@", vc);
    if ([vc respondsToSelector:@selector(jobWizardEnd:)]) {
        NSLog(@"performing selctor...");
        [vc performSelector:@selector(jobWizardEnd:) withObject:self.context];
    }
    
}

@end
