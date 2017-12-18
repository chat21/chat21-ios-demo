//
//  SHPMiniWebBrowserVC.m
//  Eurofood
//
//  Created by Dario De Pascalis on 01/10/14.
//
//

#import "SHPMiniWebBrowserVC.h"
//#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPImageUtil.h"

@interface SHPMiniWebBrowserVC ()
@end

@implementation SHPMiniWebBrowserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL::: %@", self.urlPage);
    
    [self.tabBarController.tabBar setHidden:YES];
    self.webView.delegate=self;
    

    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarNavigation"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    colorBackground = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"colorBackground"]];
    
    [self.toolBar setBarTintColor:colorBackground];
    
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    self.navigationItem.rightBarButtonItem = nil;
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)initialize {
    NSLog(@"initialize %@", self.urlPage);
    /***********************************************************************************/
    if(![self.urlPage hasPrefix:@"http"]){
        self.urlPage = [NSString stringWithFormat:@"http://%@",self.urlPage];
    }
    /***************************************************************************************************************/
    NSLog(@"urlPage: %@", self.urlPage);
    self.urlPage = [self.urlPage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *encodedString=[self.urlPage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
   
    //NSURL *weburl = [NSURL URLWithString:encodedString];
    
    
    [self.webView loadRequest:requestObj];
    /***************************************************************************************************************/
    if(self.titlePage){
        self.navigationItem.title = self.titlePage;
    }
//    else {
//        [SHPComponents titleLogoForViewController:self];
//    }
    [self.toolBar setHidden:self.hiddenToolBar];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [activityIndicator startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
    //self.navigationItem.rightBarButtonItem = refreshButtonItem;
    if(self.hiddenToolBar==TRUE){
        self.navigationItem.rightBarButtonItem = self.forwardButton;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitle", nil) message:NSLocalizedString(@"NetworkError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
    //[alertView release];
}


- (void)showActionSheet {
    NSString *urlString = @"";
    
    NSURL* url = [self.webView.request URL];
    urlString = [url absoluteString];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        // Chrome is installed, add the option to open in chrome.
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", nil)];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    NSURL *theURL = [self.webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        //theURL = urlToLoad;
    }
    
    if (buttonIndex == kSafariButtonIndex) {
        [[UIApplication sharedApplication] openURL:theURL];
    }
    else if (buttonIndex == kChromeButtonIndex) {
        NSString *scheme = theURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"]) {
            chromeScheme = @"googlechrome";
        } else if ([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme) {
            NSString *absoluteString = [theURL absoluteString];
            NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionCloseView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forwardLink:(id)sender {
    [self showActionSheet];
}

- (IBAction)reloadPage:(id)sender {
    [self.webView reload];
    //[self initialize];
}

- (IBAction)nextPage:(id)sender {
}

- (IBAction)backPage:(id)sender {
    [self.webView goBack];
}
@end
