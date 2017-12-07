//
//  CZswapvc.h
//  AboutMe
//
//  Created by Dario De pascalis on 04/04/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Parse/Parse.h>
//#import "CZLoginVC.h"
//#import "CZSignInEmailVC.h"
#import "CZAuthenticationDC.h"
@class MBProgressHUD;
@class SHPApplicationContext;


@interface CZAuthenticationVC : UIViewController< CZAuthenticationDelegate>{
    MBProgressHUD *HUD;
    CZAuthenticationDC *DC;
    //CZLoginVC *contentLoginVC;
    bool animationActive;
    NSString *errorMessage;
    UIView *viewError;
    UILabel *labelError;
    CGFloat posXTriangleStart;
    NSDictionary *dicHeader;
    NSDictionary *myUser;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (nonatomic, weak) IBOutlet UIView *containerA;//login
@property (nonatomic, weak) IBOutlet UIView *containerB;//signin
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imageHeaderBackgroundUP;
@property (strong, nonatomic) IBOutlet UIImageView *imageHeaderBackground;
@property (strong, nonatomic) IBOutlet UIView *viewBackgroundHeader;
@property (weak, nonatomic) IBOutlet UIButton *buttonIscriviti;
@property (weak, nonatomic) IBOutlet UIButton *buttonAccedi;
//@property (weak, nonatomic) IBOutlet UIView *viewError;
//@property (weak, nonatomic) IBOutlet UILabel *labelError;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIButton *buttonFacebookLogin;
@property (strong, nonatomic) IBOutlet UIImageView *imageTriangle;
@property (strong, nonatomic) IBOutlet UIButton *buttonExit;
@property (nonatomic, assign) BOOL exitEnabled;
@property (weak, nonatomic) IBOutlet UIView *boxFacebookConnect;
@property (weak, nonatomic) IBOutlet UILabel *claimLabel;


- (IBAction)actionLogin:(id)sender;
- (IBAction)actionSignin:(id)sender;
- (IBAction)actionFacebookLogin:(id)sender;
- (IBAction)actionExit:(id)sender;

- (IBAction)unwindToAuthenticationVC:(UIStoryboardSegue*)sender;
- (void)animationMessageError:(NSString *)msg;

@end
