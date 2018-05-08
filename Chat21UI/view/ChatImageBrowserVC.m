//
//  ChatImageBrowserVC.m
//  chat21
//
//  Created by Andrea Sponziello on 04/05/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import "ChatImageBrowserVC.h"
#import <Photos/Photos.h>

@interface ChatImageBrowserVC ()

@end

@implementation ChatImageBrowserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL: %@", self.imageURL);
    
    self.webView.delegate=self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.webView addGestureRecognizer:tap];
    
//    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    [self setNeedsStatusBarAppearanceUpdate];
//    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
//    activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    activityButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    /***********************************************************************************/
    self.navigationItem.rightBarButtonItem = activityButtonItem;
    [self initialize];
}

- (void)initialize {
    NSURL *url = [NSURL URLWithString:self.imageURL];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@",error);
}


-(void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Save image", nil)];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    NSLog(@"button: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Save image", nil)]) {
        NSLog(@"Saving image to camera roll.");
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.imageURL]];
        UIImage *image = [UIImage imageWithData: imageData];
        NSLog(@"Saving to camera roll... w:%f h:%f", image.size.width, image.size.height);
        
//        UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            changeRequest.creationDate          = [NSDate date];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"Image saved to camera roll.");
            }
            else {
                NSLog(@"Rrror saving image to camera roll: %@", error);
            }
        }];
    }
    
//    if (buttonIndex == kCopyURLButtonIndex) {
//        NSString *urlString = @"";
//        NSURL* url = [self.webView.request URL];
//        urlString = [url absoluteString];
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        pasteboard.string = urlString;
//    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"Error saving image to camera roll.");
    }
    else {
        NSLog(@"Image saved to camera roll. w:%f h:%f", image.size.width, image.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)onTap {
    NSLog(@"tapped");
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
}

@end
