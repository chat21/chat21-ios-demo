//
//  MRDescriptionStepTVC.h
//  misterlupo
//
//  Created by Andrea Sponziello on 07/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRDescriptionStepTVC : UITableViewController<UITextViewDelegate> {
    NSString *kPlaceholderDescription;
}

@property (strong, nonatomic) NSMutableDictionary *context;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
//- (IBAction)nextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end
