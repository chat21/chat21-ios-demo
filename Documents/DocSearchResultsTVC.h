//
//  DocSearchResultsTVC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 21/08/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocNavigatorTVC.h"

@interface DocSearchResultsTVC : UITableViewController

@property (nonatomic, strong) NSArray *searchNodes;
@property(nonatomic, strong) NSMutableDictionary *nodesCache;
@property(nonatomic, assign) BOOL selectionMode;
@property(nonatomic, strong) id<DocSelectionDelegate> selectionDelegate;
@property(nonatomic, strong) NSString *documentURL;
@property(nonatomic, strong) NSString *documentName;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) NSString *textToSearch;

@end
