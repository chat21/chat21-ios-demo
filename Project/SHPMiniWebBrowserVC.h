//
//  SHPMiniWebBrowserVC.h
//  Eurofood
//
//  Created by Dario De Pascalis on 01/10/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface SHPMiniWebBrowserVC : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>
{
    UIBarButtonItem *refreshButtonItem;
    UIActivityIndicatorView *activityIndicator;
    UIBarButtonItem *activityButtonItem;
    UIColor *tintColor;
    UIColor *colorBackground;
    
    enum actionSheetButtonIndex {
        kSafariButtonIndex,
        kChromeButtonIndex,
    };
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, strong) NSString *urlPage;
@property (nonatomic, strong) NSString *titlePage;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (assign, nonatomic) BOOL hiddenToolBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

- (IBAction)actionCloseView:(id)sender;
- (IBAction)forwardLink:(id)sender;
- (IBAction)reloadPage:(id)sender;
- (IBAction)nextPage:(id)sender;
- (IBAction)backPage:(id)sender;
@end
