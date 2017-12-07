//
//  MRCategoryStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 06/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRJobCategory;

@interface MRCategoryStepTVC : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *context;

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) MRJobCategory *category;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancelAction:(id)sender;

@end
