//
//  MRPreviewStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 07/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRPreviewStepTVC : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *context;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
