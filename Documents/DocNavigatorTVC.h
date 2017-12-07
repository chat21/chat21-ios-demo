//
//  DocNavigatorTVC.h
//
//  Created by Andrea Sponziello on 17/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfrescoRepositorySession.h"

@protocol DocSelectionDelegate <NSObject>
@required
-(void)selectedDocument:(AlfrescoNode *)document;
@end

#warning ENTER YOUR API AND SECRET KEY

// Enter the api Key and secret key in the #define below
#define APIKEY @""
#define SECRETKEY @""

@interface DocNavigatorTVC : UITableViewController <UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UIDocumentPickerDelegate>

@property(nonatomic, strong) AlfrescoFolder *folder;
@property(nonatomic, strong) NSMutableDictionary *nodesCache;
@property(nonatomic, strong) NSString *documentURL;
@property(nonatomic, strong) NSString *documentName;
@property(nonatomic, assign) BOOL selectionMode;
@property(nonatomic, strong) id<DocSelectionDelegate> selectionDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *helpButton;
- (IBAction)helpAction:(id)sender;
- (IBAction)addAction:(id)sender;

+(NSString *)documentURLByNode:(AlfrescoNode *)node;

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSTimer *searchTimer;

@end
