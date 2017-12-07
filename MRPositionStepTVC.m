//
//  MRPositionStepTVC.m
//  misterlupo
//
//  Created by Andrea Sponziello on 06/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "MRPositionStepTVC.h"

@interface MRPositionStepTVC ()

@end

@implementation MRPositionStepTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capTextView.delegate = self;
    [self.capTextView addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.capTextView.placeholder = NSLocalizedString(@"quote where placeholder", nil);
    self.nextButton.title = NSLocalizedString(@"next", nil);
    self.titleLabel.text = NSLocalizedString(@"quote where", nil);
    self.subtitleLabel.text = NSLocalizedString(@"quote where subtitle", nil);
    self.subtitle2Label.text = NSLocalizedString(@"skill where subtitle2", nil);
    self.placeholderLabel.text = NSLocalizedString(@"quote where placeholder", nil);
    self.navigationItem.title = NSLocalizedString(@"quote where", nil);
    
    NSString *cap = [self.context objectForKey:@"position"];
    if (cap) {
        self.capTextView.text = cap;
    }
    [self validateText];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.capTextView becomeFirstResponder];
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
        UITableViewController *vc = (UITableViewController *)[segue destinationViewController];
        NSString *cap = self.capTextView.text;
        [self.context setObject:cap forKey:@"position"];
        [self savePosition:cap];
//        vc.context = self.context;
        [vc setValue:self.context forKey:@"context"];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    NSString *cap = self.capTextView.text;
    [self savePosition:cap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *lastPosition = [self loadPosition];
    if (lastPosition) {
        self.capTextView.text = lastPosition;
        [self validateText];
    }
}

- (IBAction)nextAction:(id)sender {
    NSLog(@"next");
//    [self.context setObject:self.capTextView.text forKey:@"cap"];
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

static NSInteger MAX_CHARACTERS_TEXT= 5;
static NSInteger MIN_CHARACTERS_TEXT = 5;

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
//    NSLog(@"shouldChangeCharactersInRange %@:%@", textField.text, string);
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > MAX_CHARACTERS_TEXT) ? NO : YES;
}

-(void)validateText {
    NSLog(@"validateText");
    NSString *trimmed = [self.capTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

-(void)savePosition:(NSString *)cap {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:self.capTextView.text forKey:@"jobWizardPosition"];
    [userPreferences synchronize];
}

-(NSString *)loadPosition {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    return [userPreferences stringForKey:@"jobWizardPosition"];
}

@end
