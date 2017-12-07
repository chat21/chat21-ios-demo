//
//  MRJobSkillStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 24/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRJobCategory;

@interface MRJobSkillStepTVC : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *context;

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) MRJobCategory *category;

- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end
