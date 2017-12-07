//
//  CZLoginVC.m
//  AboutMe
//
//  Created by Dario De pascalis on 04/04/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "CZLoginVC.h"
//#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "DDPWebPagesVC.h"
#import "CZAuthenticationDC.h"
#import "SHPUser.h"
#import "MBProgressHUD.h"
#import "SHPApplicationContext.h"
#import "SHPSendTokenDC.h"
#import "SHPAppDelegate.h"

@interface CZLoginVC ()
@end

@implementation CZLoginVC

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"CZLoginVC.viewDidLoad");
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    //-------------------------------------------//
    //custom navibation bar, button
    [CZAuthenticationDC setTrasparentBackground:self.navigationController];
    [CZAuthenticationDC setAlphaBackground:self.navigationController bckColor:[UIColor blackColor] alpha:1];
    UIColor *itemColor = [CZAuthenticationDC colorWithHexString:@"ffffff"];
    [self.navigationItem.titleView setTintColor:itemColor];
    //[self customBackButton];
    //-------------------------------------------//

    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear LOGIN");
}

-(void)initialize{
    self.textUsername.placeholder = NSLocalizedStringFromTable(@"NomeUtente", @"CZ-AuthenticationLocalizable", @"");
    self.textPassword.placeholder = NSLocalizedStringFromTable(@"Password", @"CZ-AuthenticationLocalizable", @"");
    [self.buttonRememberPassword setTitle:NSLocalizedStringFromTable(@"PasswordDimenticata", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textUsername];
    [self addControllChangeTextField:self.textPassword];
    self.buttonRememberPassword.hidden = NO;
    self.buttonEnter.hidden = YES;
}

-(void)setMessageError:(NSString*)msgError
{
    //errorMessage =  [NSString stringWithFormat:@"%@",NSLocalizedString(@"Email non corretta", nil)];//[error localizedDescription];
    viewError = [[UIView alloc] init];
    viewError.frame = CGRectMake(0, 0, self.view.frame.size.width, 66);
    viewError.backgroundColor = [UIColor redColor];
    viewError.alpha = 0;
    labelError = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, (self.view.frame.size.width-10), 56)];
    [labelError setTextColor:[UIColor whiteColor]];
    [labelError setBackgroundColor:[UIColor clearColor]];
    [labelError setFont:[UIFont fontWithName: @"Helvetica Neue" size: 14.0f]];
    labelError.text = msgError;
    labelError.textAlignment = NSTextAlignmentCenter;
    labelError.numberOfLines = 3;
    [viewError addSubview:labelError];
    [[[UIApplication sharedApplication] keyWindow] addSubview:viewError];
}

//--------------------------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//
-(void)addGestureRecognizerToView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)
                                   ];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard{
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

-(void)addControllChangeTextField:(UITextField *)textField
{
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if (textField.tag == 2 && ([self.textPassword.text length]>0) && ([self.textUsername.text length]>0)) {
        self.buttonRememberPassword.hidden = YES;
        self.buttonEnter.hidden = NO;
    }
    else if(([self.textPassword.text length]>0) && ([self.textUsername.text length]>0)){
        self.buttonRememberPassword.hidden = YES;
        self.buttonEnter.hidden = NO;
    }else{
        self.buttonRememberPassword.hidden = NO;
        self.buttonEnter.hidden = YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [self actionLogin];
    //[textField resignFirstResponder];
    return YES;
}
-(UIButton *)enableButton:(UIButton *)button{
    button.enabled = YES;
    //button.hidden = NO;
    [button setAlpha:1];
    return button;
}

-(UIButton *)disableButton:(UIButton *)button{
    button.enabled = NO;
    //button.hidden = YES;
    [button setAlpha:0.5];
    return button;
}
//--------------------------------------------------------------------//
//END TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START FUNCTIONS
//--------------------------------------------------------------------//
//-(NSString*)getUrlPageRememberPassword{
//    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
//    NSString *urlPageForgotPassword = [settingsDictionary valueForKey:@"urlPageForgotPassword"];
//    NSString *urlWeb=[NSString stringWithFormat:@"%@%@/%@?tenant=%@&domain=%@", hostSite, path, urlPageForgotPassword, tenant, domain];
//    NSString *urlForgotPassword = [urlWeb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"urlForgotPassword:%@", urlForgotPassword);
//    return urlForgotPassword;
//}

-(void)animationMessageError:(NSString *)msg{
    //startedAnimation = YES;
    [self disableButton:self.buttonEnter];
    [self setMessageError:msg];
    viewError.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         viewError.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:2.5
                                             options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                                          animations:^{
                                              viewError.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished){
                                              //startedAnimation = NO;
                                              [self enableButton:self.buttonEnter];
                                          }];
                     }];
}

-(void)showWaiting:(NSString *)label {
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:hud];
    }
    hud.center = self.view.center;
    hud.labelText = label;
    hud.animationType = MBProgressHUDAnimationZoom;
    [hud show:YES];
}

-(void)hideWaiting {
    [hud hide:YES];
}

-(NSString*)getUrlPageRememberPassword {
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    NSDictionary *configDictionary = [self.applicationContext.plistDictionary objectForKey:@"Config"];
//    NSString *hostSite = [NSString stringWithFormat:@"http://%@",[configDictionary objectForKey:@"phpextensionsHost"]];
    NSString *tenant = app.tenant;
    NSString *domain = [configDictionary objectForKey:@"serviceDomain"];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [thisBundle localizedStringForKey:@"phpextensions.path_services" value:@"KEY NOT FOUND" table:@"services"];
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    NSString *urlPageForgotPassword = [settingsDictionary valueForKey:@"urlPageForgotPassword"];
    NSString *urlWeb=[NSString stringWithFormat:@"http://ext.smart21.it%@/%@?tenant=%@&domain=%@", path, urlPageForgotPassword, tenant, domain];
    NSString *urlForgotPassword = [urlWeb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlForgotPassword:%@", urlForgotPassword);
    return urlForgotPassword;
}

//--------------------------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START SEND LOGIN AND PSW
//--------------------------------------------------------------------//
-(void)actionLogin{
    self.buttonEnter.enabled = NO;
    if([self.textPassword.text length]>0 && [self.textUsername.text length]>0){
        NSLog(@"INVIA");
        [self sendLoginAndPsw];
    }else{
        NSString *msg = NSLocalizedString(@"UsernamePasswordInvalid", nil);
        [self animationMessageError:msg];
    }
}

-(void)sendLoginAndPsw{
    NSLog(@"\n actionEnter...");
    [self showWaiting:NSLocalizedString(@"Authenticating", nil)];
    [self.buttonEnter setEnabled:NO];
    SHPSigninServiceDC *dc = [[SHPSigninServiceDC alloc] init];
    dc.delegate = self;
    NSString *username = [self.textUsername.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.textPassword.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    SHPUser *user = [[SHPUser alloc] init];
    user.username = username;
    user.password = password;
    [dc signinWith:user andPassword:password];
}

//-(void)signedin:(SHPUser *)justSignedUser {
//    NSLog(@"Signin successfull! %@",justSignedUser);
//    [self hideWaiting];
//    [self didSignedIn:justSignedUser];
//}
//
//-(void)didSignedIn:(SHPUser *)user {
//    NSLog(@"didSignedIn........................%@", user.httpBase64Auth);
//    [self prepareSignedUser:user];
//}

//-(void)prepareSignedUser:(SHPUser *)user {
-(void)signin:(SHPUser *)user {
    NSLog(@"\n\n\n ********** prepareSignedUser. %@ - %@",self.applicationContext, user);
    [self hideWaiting];
    [self.applicationContext signin:user];
    // start notifications
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate startPushNotifications];
    // end
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

//-(void)registerOnProviderForNotifications {
//    SHPSendTokenDC *tokenDC = [[SHPSendTokenDC alloc] init];
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString *devToken = appDelegate.deviceToken;
//    if (devToken) {
//        [tokenDC sendToken:devToken withUser:self.applicationContext.loggedUser lang:langID completionHandler:^(NSError *error) {
//            if (!error) {
//                NSLog(@"Successfully registered DEVICE to Provider WITH USER.");
//            }
//            else {
//                NSLog(@"Error while registering devToken to Provider!");
//            }
//        }];
//    }
//}

//--------------------------------------------------------------------//
//END SEND LOGIN AND PSW
//--------------------------------------------------------------------//
//--------------------------------------------------------------------//
//DELEGATE CALLED BY [dc signinWith:user andPassword:password];
//--------------------------------------------------------------------//
-(void)signinServiceDCSignedIn:(SHPUser *)user error:(NSError *) error {
    if (!error) {
        NSLog(@"Signed in! %@", user);
        [self signin:user];
    } else if (error.code == 900) {
        NSLog(@"Signin error! %@", error);
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"UsernamePasswordInvalid", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    } else if (error.code == -1009 ) {
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"NetworkError", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    } else {
        [self hideWaiting];
        NSString *msg = NSLocalizedString(@"UnknownError", nil);
        [self animationMessageError:msg];
        //[self.buttonEnter setEnabled:YES];
    }
}
//--------------------------------------------------------------------//
//END DELEGATE
//--------------------------------------------------------------------//




//-(void)saveSessionToken {
//    NSLog(@"Updating current parse installation with username for chat...");
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    //[currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
//    // CORRETTO AL VOLO MENTRE CERCAVO QUESTO CODICE PER DARIO DA INTEGRARE IN ANCI RISPONDE
//    [currentInstallation setObject:self.applicationContext.loggedUser.username forKey:@"username"];
//    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSInteger errCode = [error code];
//        if (errCode == 0) {
//            NSLog(@"Installation successfully saved.");
//        } else {
//            NSLog(@"Installation saved with error: %d", (int) errCode);
//        }
//    }];
//}

-(void)savePassword:(NSString *)password {
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSLog(@"*************** SAVE PASSWORD: %@ ***************",password);
    [userPreferences setObject:password forKey:@"PASSWORD"];
    [userPreferences synchronize];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toResetPassword"]) {
        //
    } else if ([[segue identifier] isEqualToString:@"toWebView"]) {
        UINavigationController *nc = [segue destinationViewController];
        DDPWebPagesVC *vc = (DDPWebPagesVC *)[[nc viewControllers] objectAtIndex:0];
        //DDPWebPagesVC *vc = (DDPWebPagesVC *)[segue destinationViewController];
        vc.urlPage = [self getUrlPageRememberPassword];
    }
}

- (IBAction)actionEnter:(id)sender {
    [self actionLogin];
}

- (IBAction)actionRememberPassword:(id)sender {
    [self dismissKeyboard];
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

- (void)dealloc{
    self.textPassword.delegate = nil;
    self.textUsername.delegate = nil;
    self.delegate = nil;
}

@end
