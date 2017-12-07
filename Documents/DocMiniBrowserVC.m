//
//  DocMiniBrowserVC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 27/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "DocMiniBrowserVC.h"
#import "SHPApplicationContext.h"
//#import "SHPSelectUserVC.h"
#import "SHPUser.h"
#import "ChatRootNC.h"
#import "ChatConversationsVC.h"
#import "ChatUtil.h"
#import "DocFileDownloadDC.h"
#import "DocChatUtil.h"

@interface DocMiniBrowserVC ()

@end

@implementation DocMiniBrowserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL::: %@", self.urlPage);
    
    self.applicationContext = [SHPApplicationContext getSharedInstance];
    
    //    [self.tabBarController.tabBar setHidden:YES];
    self.webView.delegate=self;
    
    //    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    
    [self.toolBar setBarTintColor:colorBackground];
    /***********************************************************************************/
    //inizializzo un'activity indicator view
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    
    //    bool statusBarStyle = [[settingsDictionary objectForKey:@"setStatusBarStyle"] boolValue];
    //    if(statusBarStyle == YES){
    //        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    }else{
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    }
    activityIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    /***********************************************************************************/
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [self loadUrl];
}

//-(void)viewWillDisappear:(BOOL)animated{
//    NSLog(@"viewWillDisappear");
//    [super viewWillDisappear:animated];
//    [self.tabBarController.tabBar setHidden:NO];
//}

-(void)dealloc {
    NSLog(@"webView deallocated.");
}

- (void)loadUrl {
    //    NSLog(@"test...");
    //    DocFileDownloadDC *d = [[DocFileDownloadDC alloc] init];
    //    [d downloadFile:@"pippo" from:self.urlPage in:@"file" username:self.username password:self.password];
    NSLog(@"loadUrl %@", self.urlPage);
    self.urlPage = [self.urlPage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:self.urlPage];
    //    NSURL *url = [NSURL URLWithString:@"https://bppmobile.bpp.it/alfresco/api/-default-/public/cmis/versions/1.0/atom/content/Test%20sito%20di%20documenti%20gestiti%20tramite%20appovazione.doc?id=6e168c2f-5ee2-4dfd-bca6-dfcd72dba6da;1.0"];
    NSLog(@"URL:'%@'", url);
    
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSLog(@"requestObj (timeout 5 sec): %@", requestObj);
    if (self.username && ![self.username isEqualToString:@""] && self.password && ![self.password isEqualToString:@""]) {
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
        NSLog(@"basicAuthCredentials: %@", basicAuthCredentials);
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(basicAuthCredentials)];
        NSLog(@"authValue: %@", authValue);
        [requestObj setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    ////    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
    ////    NSLog(@"authStr %@", authStr);
    ////    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    ////    NSLog(@"authData %@", authData);
    ////    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    ////    NSLog(@"authValue %@", authValue);
    //    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    //    NSLog(@"mutableRequest.headers: %@", [mutableRequest allHTTPHeaderFields]);
    ////    [mutableRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    //    NSURLRequest *request = [mutableRequest copy];
    //    NSLog(@"request: %@", request);
    //    NSLog(@"headers: %@", [request allHTTPHeaderFields]);
    //    NSLog(@"Loading document...");
    
    [self.webView loadRequest:requestObj];
    if(self.titlePage){
        self.navigationItem.title = self.titlePage;
    }
    //    [self.toolBar setHidden:self.hiddenToolBar];
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    return NO;
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSLog(@"response: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
//    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//        NSLog(@"response headers: %@", [httpResponse allHeaderFields]);
//    }
//    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        NSLog(@"%s request to %@, statusCode=%ld", __FUNCTION__, response.URL.absoluteString, (long)statusCode);
//        [self.webView loadRequest:connection.originalRequest];
//    }
//    [connection cancel];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    NSLog(@"Received data.");
//    // Append the new data to receivedData.
//    // receivedData is an instance variable declared elsewhere.
//    [self.receivedData appendData:data];
//}

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
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
    self.navigationItem.rightBarButtonItem = self.forwardButton;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error: %@",error);
    [activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitle", nil) message:NSLocalizedString(@"NetworkError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
}


-(void)showActionSheet {
    NSString *urlString = @"";
    
    NSURL* url = [self.webView.request URL];
    urlString = [url absoluteString];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Inoltra", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Copia URL", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    
    //    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
    //        // Chrome is installed, add the option to open in chrome.
    //        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", nil)];
    //    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    NSURL *theURL = [self.webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        //theURL = urlToLoad;
    }
    
    if (buttonIndex == kChatSendButtonIndex) {
        NSLog(@"chat send");
        [self performSegueWithIdentifier:@"selectUserSegue" sender:self];
    }
    else if (buttonIndex == kCopyURLButtonIndex) {
        NSString *urlString = @"";
        NSURL* url = [self.webView.request URL];
        urlString = [url absoluteString];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = urlString;
    }
    else if (buttonIndex == kSafariButtonIndex) {
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"selectUserSegue"]) {
//        UINavigationController *navigationController = [segue destinationViewController];
//        SHPSelectUserVC *vc = (SHPSelectUserVC *)[[navigationController viewControllers] objectAtIndex:0];
//        vc.applicationContext = self.applicationContext;
//        vc.modalCallerDelegate = self;
//    }
}

- (void)setupViewController:(UIViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {
    NSLog(@"setupViewController...");
//    if([controller isKindOfClass:[SHPSelectUserVC class]])
//    {
//        SHPUser *user = nil;
//        if ([setupInfo objectForKey:@"user"]) {
//            user = [setupInfo objectForKey:@"user"];
//            NSLog(@">>>>>> SELECTED: user %@", user.username);
//        }
//        [self dismissViewControllerAnimated:YES completion:^{
//            if (user) {
//                NSLog(@"Dismissed");
//                NSString *urlString = @"";
//                NSURL* url = [self.webView.request URL];
//                urlString = [url absoluteString];
//                [self sendMessage:urlString toUser:user];
//            }
//        }];
//    }
}

- (void)setupViewController:(UIViewController *)controller didCancelSetupWithInfo:(NSDictionary *)setupInfo {
//    if([controller isKindOfClass:[SHPSelectUserVC class]])
//    {
//        NSLog(@"User selection Canceled.");
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

-(void)sendMessage:(NSString *)text toUser:(SHPUser *)user {
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController"];
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        ChatUser *chatUser = [[ChatUser alloc] init];
        chatUser.userId = [DocChatUtil firebaseUserID:user.username];
        chatUser.fullname = user.fullName;
        NSLog(@"(username %@) chatUser: %@ firstn %@ lastn %@",user.username, chatUser.userId, chatUser.firstname, chatUser.lastname);
        
        [ChatUtil moveToConversationViewWithRecipient:chatUser sendMessage:text];
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
    //[self loadUrl];
}

- (IBAction)nextPage:(id)sender {
}

- (IBAction)backPage:(id)sender {
    [self.webView goBack];
}

@end

