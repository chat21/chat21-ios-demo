//
//  DocNavigatorTVC.m
//  misterlupo
//
//  Created by Andrea Sponziello on 17/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocNavigatorTVC.h"
#import "AlfrescoSession.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoOAuthUILoginViewController.h"
#import "AlfrescoDocumentFolderService.h"
#import "SHPAppDelegate.h"
#import "AlfrescoDocumentFolderService.h"
#import "DocNodeCell.h"
#import "SHPApplicationContext.h"
#import "DocMiniBrowserVC.h"
#import "SHPUser.h"
#import "AlfrescoSearchDC.h"
#import "AlfrescoRequest.h"
#import "DocSearchResultsTVC.h"
#import "DocAuthTVC.h"
#import "DocFileUploadDC.h"
#import "HelpFacade.h"

@interface DocNavigatorTVC ()

//@property (nonatomic, strong) AlfrescoRepositorySession *session;
//@property (nonatomic, strong) AlfrescoRepositoryInfo *info;
@property (nonatomic, strong) SHPApplicationContext *app;
@property (nonatomic, strong) NSArray *nodes;
@property (nonatomic, strong) NSArray *searchNodes;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) DocSearchResultsTVC *resultsVC;
@property (nonatomic, strong) AlfrescoDocumentFolderService *docFolderService;
@property (nonatomic, strong) AlfrescoRequest *currentRequest;
@property (nonatomic, strong) AlfrescoRequest *currentSearchRequest;
@property BOOL isCloudTest;

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

//- (void)helloFromRepository;
//- (void)helloFromCloud;
//- (void)loadRootFolder;

@end

@implementation DocNavigatorTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.app = [SHPApplicationContext getSharedInstance];
    self.isCloudTest = NO;
    if (self.nodesCache == nil) {
        self.nodesCache = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"selectionMode = %d", self.selectionMode);
    if (self.selectionMode == YES) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Annulla"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(cancelAction:)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
    if (self.folder) {
        self.navigationItem.title = self.folder.name;
    }
    else {
        self.navigationItem.title = @"Home";
    }
    self.firstAppear = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    [self configureSearchController];
    if (!self.folder) {
        [[HelpFacade sharedInstance] activateSupportBarButton:self];
    }
    //    [self helloFromCloud];
}

-(void) configureSearchController {
    
    // CUSTOM RESULTS CONTROLLER
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DocNavigator" bundle:nil];
    UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"search-results-vc"];
    self.resultsVC = (DocSearchResultsTVC *)[[nc viewControllers] objectAtIndex:0];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nc];
    self.resultsVC.tableView.delegate = self;
    // FINE CUSTOM RESULTS CONTROLLER
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.definesPresentationContext = YES;
    // SCOPE SEARCH: self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Cartelle",@"Documenti"), NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    self.searchController.searchBar.delegate = self;
    //    UISearchContainerViewController *container = [[UISearchContainerViewController alloc] initWithSearchController:self.searchController];
    [self.tableView setTableHeaderView:self.searchController.searchBar];
    
    // bar style
    UISearchBar *bar = self.searchController.searchBar;
    // gray background for bar's textField
    for (UIView *subView in bar.subviews) {
        for (UIView *subView1 in subView.subviews) {
            if ([subView1 isKindOfClass:[UITextField class]]) {
                subView1.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
            }
        }
    }
    if (!self.folder) {
        bar.placeholder = @"Cerca nei tuoi file";
    }
    else {
        bar.placeholder = @"Cerca in questa cartella";
    }
    bar.barTintColor = [UIColor whiteColor]; // white background of all the searchbar
    //    bar.backgroundColor = [UIColor whiteColor];
    //    bar.barStyle = UIBarStyleDefault;
    //    bar.searchBarStyle = UISearchBarStyleMinimal;
    bar.translucent = NO;
    // alternate method to set background color that never works
    //        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0]];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *text = searchController.searchBar.text;
    if ([self.resultsVC.textToSearch isEqualToString:text]) {
        return;
    }
    else if ([text isEqualToString:@""]) {
        self.searchNodes = nil;
        self.resultsVC.searchNodes = nil;
        [self reloadResultsData];
        return;
    }
    NSLog(@"searching: %@", text);
    
    //    if ([text isEqualToString:@""]) {
    //        self.searchController.obscuresBackgroundDuringPresentation = YES;
    //    }
    //    else {
    //        self.searchController.obscuresBackgroundDuringPresentation = NO;
    //    }
    
    [self.currentSearchRequest cancel];
    if (self.searchTimer) {
        if ([self.searchTimer isValid]) {
            [self.searchTimer invalidate];
        }
        self.searchTimer = nil;
    }
    NSLog(@"Scheduling new search for: %@", text);
    NSString *preparedText = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![preparedText isEqualToString:@""]) {
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
    }
}

//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    self.searchNodes = nil;
////    self.resultsVC.searchNodes = nil;
//    self.searchController.active = NO;
//    [self.tableView reloadData];
//}

-(void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"didDismissSearchController");
    self.searchNodes = nil;
    //    self.resultsVC.searchNodes = nil;
    //    [self.tableView reloadData];
}

-(void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearchController");
    //    [self.tableView reloadData];
}

-(void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"willDismissSearchController");
}

-(void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearchController");
}

//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    self.searchController.active = NO;
//    [self.tableView reloadData];
//}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"self.searchController.active %d", self.searchController.active);
}

-(void)reloadResultsData {
    if (self.resultsVC) {
        self.resultsVC.textToSearch = self.searchController.searchBar.text;
        [self.resultsVC.tableView reloadData];
    }
    else {
        [self.tableView reloadData];
    }
}

-(void) userPaused:(NSTimer *)timer {
    NSLog(@"(SHPSearchViewController) userPaused.");
    NSString *textToSearch = self.searchController.searchBar.text;
    NSString *text = [self prepareTextToSearch:textToSearch];
    NSLog(@"timer on userPaused: searching for %@", text);
    AlfrescoSearchDC *service = [[AlfrescoSearchDC alloc] init];
    //    self.searching = YES;
    self.resultsVC.searching = YES;
    [self reloadResultsData];
    self.currentSearchRequest = [service documentsByText:text folder:self.folder completion:^(NSArray<AlfrescoNode *> *nodes) {
        NSLog(@"NODES FOUND OK! %@",nodes);
        //        self.searching = NO;
        self.resultsVC.searching = NO;
        self.searchNodes = nodes;
        if (!self.resultsVC) {
            //            self.searchNodes = nodes;
            [self reloadResultsData];
        }
        else {
            self.resultsVC.searchNodes = nodes;
            [self reloadResultsData];
        }
    }];
}

-(NSString *)prepareTextToSearch:(NSString *)text {
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    [self loadFolder:self.folder];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.currentRequest) { // and level != 0
        [self.currentRequest cancel];
    }
    if (self.currentSearchRequest) {
        [self.currentSearchRequest cancel];
    }
    [self.refreshControl endRefreshing];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"DocNavigator.viewWillAppear");
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    SHPUser *loggedUser = appDelegate.applicationContext.loggedUser;
    if (!loggedUser) {
        [self.navigationController popToRootViewControllerAnimated:true];
        [self showLoginView];
        return;
    }
    
    if (self.firstAppear) {
        self.firstAppear = NO;
        // refresh control
        
        NSArray *nodes = [self.nodesCache objectForKey:self.folder.identifier];
        if (nodes) {
            self.nodes = nodes;
            [self.tableView reloadData];
        }
        else {
            [self openRefreshControl];
        }
        
        //        self.docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.app.docSession];
        SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
        __weak DocNavigatorTVC *weakSelf = self;
        if (!self.app.docSession) {
            [DocAuthTVC repositoryReSignin:app.loggedUser.username password:app.loggedUser.password completion:^(NSError *error) {
                if (error) {
                    NSLog(@"Error connecting to repository: %@", error);
                    [weakSelf showAlert:@"Errore durante l'accesso."];
                    [self.refreshControl endRefreshing];
                    // potresti sollevare la modale di login (DocAuthTVC) per sollecitare il signin
                }
                else {
                    [self loadData];
                }
            }];
        } else {
            [self loadData];
        }
        //        else {
        //            [self repositoryInit];
        //        }
    }
}

-(void)showLoginView {
    NSLog(@"PRESENTING LOGIN VIEW.");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DocNavigator" bundle:nil];
    DocAuthTVC *vc = (DocAuthTVC *)[sb instantiateViewControllerWithIdentifier:@"login-vc"];
    NSLog(@"vc = %@", vc);
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

-(void)loadData {
    if (self.folder) {
        [self loadFolder:self.folder];
    }
    else {
        [self loadHomeFolder];
    }
}

-(void)openRefreshControl {
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:NO];
}

-(void)showAlert:(NSString *)msg {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"action canceled");
                             }];
    [view addAction:cancel];
    // for ipad
    view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:view animated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"DocNavigator.viewDidAppear");
    if (self.selectedIndexPath && !self.searchController.active) {
        [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    }
    else {
        [self.resultsVC.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    }
}


//-(void)loadContents {
//    NSArray *nodes = [self.nodesCache objectForKey:self.folder.identifier];
//    if (nodes) {
//        self.nodes = nodes;
//        [self.tableView reloadData];
//    }
//    else {
//        [self.refreshControl beginRefreshing];
//        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:NO];
//    }
//}

#pragma mark - Repository methods

//- (void)helloFromCloud
//{
//    NSLog(@"*********** helloFromCloud");
//
//    __weak AlfrescoHomeTVC *weakSelf = self;
//    AlfrescoOAuthCompletionBlock completionBlock = ^void(AlfrescoOAuthData *oauthdata, NSError *error){
//        if (nil == oauthdata)
//        {
//            NSLog(@"Failed to authenticate: %@:", error);
//        }
//        else
//        {
//            [AlfrescoCloudSession connectWithOAuthData:oauthdata parameters:nil completionBlock:^(id<AlfrescoSession> session, NSError *error){
//                if (nil == session)
//                {
//                    NSLog(@"Failed to create session: %@:", error);
//                }
//                else
//                {
//                    weakSelf.session = session;
//                    [weakSelf loadRootFolder];
//                }
//                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
//            }];
//        }
//    };
//
//
//    // check the API key and secret have been defined
//    NSString *apiKey = APIKEY;
//    NSString *secretKey = SECRETKEY;
//    if (apiKey.length == 0 || secretKey.length == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"Either the API key or secret key is missing. Please provide the keys and re-start the app."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//    else
//    {
//        AlfrescoOAuthUILoginViewController *webLoginController = [[AlfrescoOAuthUILoginViewController alloc] initWithAPIKey:APIKEY secretKey:SECRETKEY completionBlock:completionBlock];
//        [self.navigationController pushViewController:webLoginController animated:YES];
//    }
//}

- (void)loadFolder:(AlfrescoFolder *)folder
{
    NSLog(@"*********** loading Folder: %@", folder.identifier);
    
    // create service
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.app.docSession];
    __weak DocNavigatorTVC *weakSelf = self;
    // retrieve the nodes from the given folder
    self.currentRequest = [docFolderService retrieveChildrenInFolder:folder completionBlock:^(NSArray *array, NSError *error) {
        if (error)
        {
            NSLog(@"Failed to retrieve folder: %@", error);
            [self.refreshControl endRefreshing];
            if (error.code != 110) { // request canceled
                [self showAlert:@"Si è verificato un errore durante l'operazione"];
            }
        }
        else
        {
            NSLog(@"Retrieved folder. %lu children", (unsigned long)array.count);
            weakSelf.nodes = [NSArray arrayWithArray:array];
            NSLog(@"children found for folder %@", weakSelf.folder.identifier);
            [weakSelf.nodesCache setValue:array forKey:weakSelf.folder.identifier];
            [weakSelf.refreshControl endRefreshing];
            // Note the UI must only be updated on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)loadHomeFolder {
//    NSString *path = @"/Sites";
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    SHPUser *loggedUser = appDelegate.applicationContext.loggedUser;
    NSString *path = [[NSString alloc] initWithFormat:@"/User Homes/%@", loggedUser.username];
    NSLog(@"*********** loading Home Folder with path: %@", path);
    
    // create service
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.app.docSession];
    __weak DocNavigatorTVC *weakSelf = self;
    // retrieve the nodes from the given folder
    [docFolderService retrieveNodeWithFolderPath:(NSString *)path completionBlock:^(AlfrescoNode *node, NSError *error) {
        AlfrescoFolder *folder = nil;
        if (node) {
            folder = (AlfrescoFolder *)node;
        }
        self.app.docStartFolder = folder;
        self.folder = folder;
        [weakSelf loadFolder:_folder];
    }];
    
}

//-(void)sitesNode {
////    AlfrescoDocumentFolderService *documentFolderService = self.session.rootFolder.getDocumentFolderService();
//    NSLog(@"sitesnode");
//    AlfrescoFolder *sitesFolder = (AlfrescoFolder *) [self.docFolderService retrieveNodeWithFolderPath:@"/Sites" completionBlock:^(AlfrescoNode *node, NSError *error) {
//        NSLog(@"Sites folder: %@", node.name);
//    }];
//    NSLog(@"sitesFolder: %@", sitesFolder);
//    //        Folder sitesFolder = (Folder) documentFolderService.getChildByPath("/Sites")
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of nodes.
    //    if (!self.searchController.active) {
    return [self.nodes count];
    //    }
    //    else {
    //        if (self.searching || self.searchNodes.count == 0) {
    //            return 1;
    //        }
    //        else {
    //            return self.searchNodes.count;
    //        }
    //    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    static NSString *NodeCellIdentifier = @"node-cell";
    UITableViewCell *cell;
    DocNodeCell *nodeCell = (DocNodeCell *) [tableView dequeueReusableCellWithIdentifier:NodeCellIdentifier forIndexPath:indexPath];
    cell = nodeCell;
    AlfrescoNode *node = nil;
    node = [self.nodes objectAtIndex:indexPath.row];
    nodeCell.nodeName.text = node.name;
    if (node.isFolder) {
        nodeCell.nodeIcon.image = [UIImage imageNamed:@"cartella.png"];
        nodeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        nodeCell.nodeIcon.image = [UIImage imageNamed:@"ic_unknown.png"];
        nodeCell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected node %ld", (long)indexPath.row);
    self.selectedIndexPath = indexPath;
    
    AlfrescoNode *node = nil;
    if (!self.searchController.active) {
        node = self.nodes[indexPath.row];
    }
    else {
        node = self.searchNodes[indexPath.row];
    }
    
    if (node.isFolder) {
        AlfrescoFolder *folder = (AlfrescoFolder *)node;
        //        NSLog(@"Retrieved children (%lu) of folder %@", (unsigned long)array.count, folder.name);
        DocNavigatorTVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"navigator-vc"];
        vc.folder = folder;
        vc.nodesCache = self.nodesCache;
        vc.selectionMode = self.selectionMode;
        vc.selectionDelegate = self.selectionDelegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (node.isDocument) {
        if (self.selectionMode) {
            if (!self.searchController.active) {
                [self.selectionDelegate selectedDocument:node];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [self.searchController dismissViewControllerAnimated:NO completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.selectionDelegate selectedDocument:node];
                }];
            }
            
        }
        else {
            self.documentURL = [DocNavigatorTVC documentURLByNode:node];
            self.documentName = @"";//node.name;
            NSLog(@"decoded url %@", self.documentURL);
            [self performSegueWithIdentifier:@"webView" sender:self];
        }
    }
}

//+(NSString *)documentURLByNode:(AlfrescoNode *)node {
//    NSLog(@"building document url for id: %@ / name: %@", node.identifier, node.name);
////    NSArray<NSString *> *parts = [node.identifier componentsSeparatedByString:@";"];
////    NSString *id = parts[0];
//    // CMIS URI
//    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
//    NSString *repoURL = app.plistDictionary[@"repoURL"];
//    // http://bppmobile.bpp.it/alfresco/api/-default-/public/cmis/versions/1.0/atom/content/Test%20sito%20di%20documenti%20gestiti%20tramite%20appovazione.doc?id=6e168c2f-5ee2-4dfd-bca6-dfcd72dba6da%3B1.0
//
//    NSString *name_escaped = [node.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSString *id_escaped = [node.identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSString *URL = [NSString stringWithFormat:@"%@/api/-default-/public/cmis/versions/1.0/atom/content/%@?id=%@", repoURL, name_escaped, id_escaped];
//    return URL;
//}

+(NSString *)documentURLByNode:(AlfrescoNode *)node {
    NSLog(@"building document url for id: %@ / name: %@", node.identifier, node.name);
    // CMIS URI
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    NSString *repoURL = app.plistDictionary[@"repoURL"];
    // http://bppmobile.bpp.it/alfresco/api/-default-/public/cmis/versions/1.0/atom/content/Test%20sito%20di%20documenti%20gestiti%20tramite%20appovazione.doc?id=6e168c2f-5ee2-4dfd-bca6-dfcd72dba6da%3B1.0
    
    NSString *name_escaped = [node.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *URL;
    BOOL bpp = true;
    if ([repoURL rangeOfString:@"bpp"].location == NSNotFound) {
        bpp = false;
    }
    if (bpp) {
        NSString *id_escaped = [node.identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        URL = [NSString stringWithFormat:@"%@/api/-default-/public/cmis/versions/1.0/atom/content/%@?id=%@", repoURL, name_escaped, id_escaped];
    }
    else {
        // DOC URL FOR OLD VERSION OF ALFRESCO:
        // http://54.155.246.42:8080/share/proxy/alfresco/api/node/content/workspace/SpacesStore/7bb9c846-fcc5-43b5-a893-39e46ebe94d4/coins.JPG?a=true
        NSArray *parts = [node.identifier componentsSeparatedByString:@"/"];
        NSString *DIRTY_ID = parts[parts.count-1];
        NSArray *parts2 = [DIRTY_ID componentsSeparatedByString:@";"];
        NSString *ID = parts2[0];
        NSString *id_escaped = [ID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"ID: %@", id_escaped);
        NSString *repo_url = [repoURL stringByReplacingOccurrencesOfString: @":8080/alfresco" withString:@":8080/share/proxy/alfresco"];
        URL = [NSString stringWithFormat:@"%@/api/node/content/workspace/SpacesStore/%@/%@", repo_url, id_escaped, name_escaped];
        NSLog(@"URL: %@", URL);
    }
    
    return URL;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue: %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"webView"]) {
        DocMiniBrowserVC *vc = (DocMiniBrowserVC *)[segue destinationViewController];
        vc.hiddenToolBar = YES;
        vc.titlePage = self.documentName;
        vc.username = self.app.loggedUser.username;
        vc.password = self.app.loggedUser.password;
        vc.urlPage = self.documentURL;
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

- (void)cancelAction:(id)sender {
    NSLog(@"canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)helpAction:(id)sender {
    NSLog(@"Help in Documents' navigator view");
    [[HelpFacade sharedInstance] openSupportView:self];
}

- (IBAction)addAction:(id)sender {
    NSLog(@"Adding item to this folder: %@", self.folder.name);
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSLog(@"document: %@", [NSString stringWithFormat:@"Successfully imported %@", url]);
        DocFileUploadDC *dc = [[DocFileUploadDC alloc] init];
        NSString *name = [url lastPathComponent];
        NSString *username = self.app.loggedUser.username;
        NSString *password = self.app.loggedUser.password;
        [dc createDocumentWithName:name fromURL:url folder:self.folder username:username password:password completion:^(BOOL error) {
            NSLog(@"Upload completed.");
        }];
    }
}

-(void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"document Picker Was Cancelled");
}

-(void)helpWizardEnd:(NSDictionary *)context {
    NSLog(@"helpWizardEnd");
    [context setValue:NSStringFromClass([self class]) forKey:@"section"];
    [[HelpFacade sharedInstance] handleWizardSupportFromViewController:self helpContext:context];
}

@end

