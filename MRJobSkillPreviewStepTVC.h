//
//  MRJobSkillPreviewStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 29/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRJobSkillPreviewStepTVC : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *context;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cvTitleLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@end
