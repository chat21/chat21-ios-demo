//
//  DDPWebPagesVC.m
//  minijob
//
//  Created by Dario De pascalis on 09/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPWebPagesVC.h"
//#import "SHPComponents.h"

@interface DDPWebPagesVC ()

@end

@implementation DDPWebPagesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
//    [SHPComponents titleLogoForViewController:self];
//    self.navigationItem.title = nil;
    [self initialize];
}

-(void)initialize{
    //inizializzo un'activity indicator view
    refreshButtonItem = self.navigationItem.rightBarButtonItem;
    actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndicator.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    activityButtonItem = [[UIBarButtonItem alloc]initWithCustomView:actIndicator];
    self.navigationItem.rightBarButtonItem = nil;
    /***********************************************************************************/
    NSURL *url = [NSURL URLWithString:self.urlPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [actIndicator startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    //[self.activityIndicator stopAnimating];
    //[self.activityIndicator setHidden:YES];
    [actIndicator stopAnimating];
    [actIndicator setHidden:YES];
    self.navigationItem.rightBarButtonItem = self.buttonItemRefresh;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
    //[self.activityIndicator stopAnimating];
    //[self.activityIndicator setHidden:YES];
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitle", nil) message:NSLocalizedString(@"NetworkError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionRefresh:(id)sender {
    [self.webView reload];
}

- (void)dealloc{
    self.webView.delegate = nil;
}
@end
