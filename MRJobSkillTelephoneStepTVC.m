//
//  MRJobSkillTelephoneStepTVC.m
//  misterlupo
//
//  Created by Andrea Sponziello on 25/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "MRJobSkillTelephoneStepTVC.h"

@interface MRJobSkillTelephoneStepTVC ()

@end

@implementation MRJobSkillTelephoneStepTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nextButton.title = NSLocalizedString(@"next", nil);
    self.titleLabel.text = NSLocalizedString(@"telephone title", nil);
    self.subtitleLabel.text = NSLocalizedString(@"telephone subtitle", nil);
    self.telephoneTextView.placeholder = NSLocalizedString(@"telephone placeholder", nil);
    self.navigationItem.title = NSLocalizedString(@"telephone view title", nil);
    
    self.telephoneTextView.delegate = self;
    [self.telephoneTextView addTarget:self
                               action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingChanged];
    
    NSString *telephone = [self.context objectForKey:@"telephone"];
    if (telephone) {
        self.telephoneTextView.text = telephone;
    }
    [self validateText];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.telephoneTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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
        NSString *tel = self.telephoneTextView.text;
        [vc setValue:self.context forKey:@"context"];
        [self.context setObject:tel forKey:@"telephone"];
        [self saveTel:tel];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString *tel = self.telephoneTextView.text;
    [self saveTel:tel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *lastTel = [self loadTel];
    if (lastTel) {
        self.telephoneTextView.text = lastTel;
        [self validateText];
    }
}

//-(void)viewWillDisappear:(BOOL)animated {
//    NSString *cap = self.capTextView.text;
//    [self saveTel:cap];
//}
//
//-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSString *lastPosition = [self loadPosition];
//    if (lastPosition) {
//        self.capTextView.text = lastPosition;
//        [self validateText];
//    }
//}

- (IBAction)nextAction:(id)sender {
    NSLog(@"next");
    [self performSegueWithIdentifier:@"next" sender:self];
}

#pragma mark - Validate text

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing...");
    // Clear the message text when the user starts editing
    //    if ([self.capTextView.text isEqualToString:kPlaceholderDescription]) {//|| [textView.text isEqualToString:kPlaceholderDescription]
    //        self.capTextView.text = @"";
    //        self.capTextView.textColor = [UIColor blackColor];
    //    }
}

static NSInteger MAX_CHARACTERS_TEXT= 10;
static NSInteger MIN_CHARACTERS_TEXT = 10;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textViewDidEndEditing...");
    [self validateText];
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
    //    if ([self.descriptionTextView.text isEqualToString:@""]) {
    //        [self resetDescription];
    //    }
}

-(void)textFieldDidChange:(UITextField *)textField {
    NSLog(@"TEXT CHANGED %@", textField.text);
    [self validateText];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    NSLog(@"shouldChangeCharactersInRange %@:%@", textField.text, string);
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > MAX_CHARACTERS_TEXT) ? NO : YES;
}

-(void)validateText {
    NSLog(@"validateText");
    NSString *trimmed = [self.telephoneTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger characterCount = [trimmed length];
    BOOL valid = true;
    if([trimmed isEqualToString:@""]){
        NSLog(@"INVALID");
        valid = false;
    } else if (characterCount < MIN_CHARACTERS_TEXT) {
        NSLog(@"INVALID");
        valid = false;
    } else {
        NSLog(@"VALID!");
        valid = true;
    }
    
    if (valid == false) {
        self.nextButton.enabled = NO;
    } else {
        self.nextButton.enabled = YES;
    }
    
}

-(void)saveTel:(NSString *)cap {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:self.telephoneTextView.text forKey:@"jobWizardTelephone"];
    [userPreferences synchronize];
}

-(NSString *)loadTel {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    return [userPreferences stringForKey:@"jobWizardTelephone"];
}

@end
