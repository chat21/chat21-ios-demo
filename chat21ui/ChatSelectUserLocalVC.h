//
//  ChatSelectUserLocalVC.h
//  bppmobile
//
//  Created by Andrea Sponziello on 13/09/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"
#import "ChatSynchDelegate.h"

@class ChatImageCache;
@class ChatGroup;
@class ChatUser;

@interface ChatSelectUserLocalVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SHPImageDownloaderDelegate, ChatSynchDelegate>

@property (strong, nonatomic) ChatUser *userSelected;
@property (strong, nonatomic) NSArray<ChatUser *> *users;
@property (strong, nonatomic) NSMutableArray<ChatUser *> *recentUsers;
@property (strong, nonatomic) NSMutableArray *allUsers;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchBarPlaceholder;
@property (strong, nonatomic) NSString *textToSearch;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSString *lastUsersTextSearch;
@property (strong, nonatomic) ChatGroup *group;
@property (strong, nonatomic) ChatImageCache *imageCache;
@property (assign, nonatomic) BOOL synchronizing;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

-(void)networkError;
- (IBAction)CancelAction:(id)sender;

@end
