//
//  MRJobSkillPositionStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 12/07/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRJobSkillPositionStepTVC : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *context;

@property (weak, nonatomic) IBOutlet UITextField *capTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitle2Label;
- (IBAction)nextAction:(id)sender;

@end
