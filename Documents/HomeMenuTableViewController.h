//
//  HomeMenuTableViewController.h
//  misterlupo
//
//  Created by Andrea Sponziello on 18/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeMenuTableViewController : UITableViewController

- (IBAction)helpAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *helpButton;

@end
