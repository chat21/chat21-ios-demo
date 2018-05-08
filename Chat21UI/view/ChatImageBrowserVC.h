//
//  ChatImageBrowserVC.h
//  chat21
//
//  Created by Andrea Sponziello on 04/05/2018.
//  Copyright © 2018 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatImageBrowserVC : UIViewController<UIWebViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    UIBarButtonItem *activityButtonItem;
}

@property (nonatomic, strong) NSString *imageURL;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
