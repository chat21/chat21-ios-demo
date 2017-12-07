//
//  MRJobSkillTelephoneStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 25/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRJobSkillTelephoneStepTVC : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *context;

@property (weak, nonatomic) IBOutlet UITextField *telephoneTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

- (IBAction)nextAction:(id)sender;

@end
