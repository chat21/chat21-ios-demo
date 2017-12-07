//
//  CZswapvc.m
//  AboutMe
//
//  Created by Dario De pascalis on 04/04/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "CZAuthenticationVC.h"
//#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "MBProgressHUD.h"
#import "CZSignInTVC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "DDPWebPagesVC.h"


@interface CZAuthenticationVC ()
@end

@implementation CZAuthenticationVC

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"CZAuthenticationVC.viewDidLoad");
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    [CZAuthenticationDC deleteSessionToken];
    DC = [[CZAuthenticationDC alloc] init];
    DC.delegate = self;
    DC.applicationContext = self.applicationContext;
    self.imageHeaderBackground.image = nil;
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     NSLog(@"viewWillAppear");
    if(!posXTriangleStart){
        [self setStartPosition];
    }
//    [self updateParseInstallation];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setStartPosition];
    NSLog(@"viewDidAppear %f",self.containerB.frame.origin.x);
}

//-(void)updateParseInstallation {
//    NSLog(@"Removing username from current parse installation");
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation removeObjectForKey:@"username"];
//    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSInteger errCode = [error code];
//        if (errCode == 0) {
//            NSLog(@"Installation successfully saved. username removed.");
//        } else {
//            NSLog(@"Installation saved with error: %d Username not removed?", (int) errCode);
//        }
//    }];
//    
//}
//--------------------------------------------------------------------//
//START INITIALIZE VIEW
//--------------------------------------------------------------------//
-(void)initialize{
    animationActive = NO;
    dicHeader =[self readerPlistForHeader];
    [self setMessageError];
    [self setHeader];
    self.claimLabel.text = NSLocalizedString(@"authentication claim", nil);
    [self.buttonAccedi setTitle:NSLocalizedStringFromTable(@"Accedi", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    [self.buttonIscriviti setTitle:NSLocalizedStringFromTable(@"Iscriviti", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    [self.buttonFacebookLogin setTitle:NSLocalizedStringFromTable(@"AccediConFacebook", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    //contentLoginVC = [self.childViewControllers objectAtIndex:1];
    //contentLoginVC.delegate = self;
    [self addGestureRecognizerToView];
    
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    NSDictionary *plistSettings = [plistDictionary objectForKey:@"Settings"];
    //NSLog(@"\n ----------- plistSettings: %@",plistSettings);
    BOOL enableButtonFacebook = [[plistSettings objectForKey:@"enableButtonFacebook"] boolValue];
    BOOL enableButtonExit = [[plistSettings objectForKey:@"enableButtonExit"] boolValue];
    NSLog(@"\n enableButtonFacebook %d", enableButtonFacebook);
    NSLog(@"\n enableButtonExit %d",enableButtonExit);
    if(enableButtonFacebook == NO){
        //self.buttonFacebookLogin.alpha = 0;
        //self.buttonFacebookLogin.hidden = YES;
        self.boxFacebookConnect.alpha = 0;
        self.boxFacebookConnect.hidden = YES;
    }
    if(enableButtonExit == NO){
        self.buttonExit.alpha = 0.00;
        self.buttonExit.enabled = NO;
    }
}



-(void)setMessageError
{
    viewError = [[UIView alloc] init];
    viewError.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    viewError.backgroundColor = [UIColor redColor];
    viewError.alpha = 0;
    labelError = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, (self.view.frame.size.width-10), 50)];
    [labelError setTextColor:[UIColor whiteColor]];
    [labelError setBackgroundColor:[UIColor clearColor]];
    [labelError setFont:[UIFont fontWithName: @"Helvetica Neue" size: 12.0f]];
    labelError.text = errorMessage;
    labelError.textAlignment = NSTextAlignmentCenter;
    [viewError addSubview:labelError];
    [[[UIApplication sharedApplication] keyWindow] addSubview:viewError];
}

-(void)setHeader{
    dicHeader = [self readerPlistForHeader];
    NSString *title =  NSLocalizedStringFromTable(@"titleAuthentication", @"CZ-AuthenticationLocalizable", @"");
    NSString *description = NSLocalizedStringFromTable(@"descriptionAuthentication", @"CZ-AuthenticationLocalizable", @"");
    
//    NSString *titleFont = [dicHeader objectForKey:@"titleFont"];
//    CGFloat titleFontSize = [[dicHeader objectForKey:@"titleFontSize"] floatValue];
//    NSString *titleFontColor = [dicHeader objectForKey:@"titleFontColor"];
//    NSString *descriptionFont = [dicHeader objectForKey:@"descriptionFont"];
//    CGFloat descriptionFontSize = [[dicHeader objectForKey:@"descriptionFontSize"] floatValue];
//    NSString *descriptionFontColor = [dicHeader objectForKey:@"descriptionFontColor"];
//    NSString *buttonFont = [dicHeader objectForKey:@"buttonFont"];
//    CGFloat buttonFontSize = [[dicHeader objectForKey:@"buttonFontSize"] floatValue];
//    NSString *buttonFontColor = [dicHeader objectForKey:@"buttonFontColor"];
    
    self.labelHeaderTitle.text = title;
    self.labelHeaderDescription.text = description;
//    [self customFontLabel:self.labelHeaderTitle font:titleFont fontSize:titleFontSize color:titleFontColor];
//    [self customFontLabel:self.labelHeaderDescription font:descriptionFont fontSize:descriptionFontSize color:descriptionFontColor];
    
//    [self.buttonAccedi setTitleColor:[CZAuthenticationDC colorWithHexString:buttonFontColor] forState:UIControlStateNormal];
//    self.buttonAccedi.titleLabel.font = [UIFont fontWithName:buttonFont size:buttonFontSize];
//    [self.buttonIscriviti setTitleColor:[CZAuthenticationDC colorWithHexString:buttonFontColor] forState:UIControlStateNormal];
//    self.buttonIscriviti.titleLabel.font = [UIFont fontWithName:buttonFont size:buttonFontSize];
    
    NSString *colorViewHeader = [dicHeader objectForKey:@"colorViewHeader"];
    NSString *alphaViewHeader = [dicHeader objectForKey:@"alphaViewHeader"];
    if(colorViewHeader){
        self.viewBackgroundHeader.backgroundColor = [CZAuthenticationDC colorWithHexString:colorViewHeader];
        self.viewBackgroundHeader.alpha = [alphaViewHeader floatValue];
    }
    NSString *colorBackground = [dicHeader objectForKey:@"colorBackground"];
    NSString *imageBackground = [dicHeader objectForKey:@"imageBackground"];
    NSLog(@"auth background: %@ - %@",colorBackground,imageBackground);
    if(colorBackground && colorBackground.length > 2){
       self.imageHeaderBackground.backgroundColor = [CZAuthenticationDC colorWithHexString:colorBackground];
    }
    if(imageBackground && imageBackground.length > 2){
        self.imageHeaderBackground.image = [UIImage imageNamed:imageBackground];
    }
    
}


-(void)setStartPosition{
    NSLog(@"setStartPosition");
    posXTriangleStart = (self.buttonAccedi.frame.origin.x+self.buttonAccedi.frame.size.width/2)-self.imageTriangle.frame.size.width/2;
    self.imageTriangle.frame = CGRectMake(posXTriangleStart, self.imageTriangle.frame.origin.y, self.imageTriangle.frame.size.width, self.imageTriangle.frame.size.height);
    self.containerB.frame = CGRectMake(-self.view.frame.size.width, self.containerB.frame.origin.y, self.containerB.frame.size.width, self.containerB.frame.size.height);
    NSLog(@"setStartPosition %f",posXTriangleStart);
}

-(NSDictionary *)readerPlistForHeader{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    return [plistDictionary objectForKey:@"HeaderAuthentication"];
}

-(void)customFontLabel:(UILabel*)label font:(NSString*)font fontSize:(CGFloat)fontSize color:(NSString*)color {
    [label setFont:[UIFont fontWithName:font size:fontSize]];
    UIColor *textColor = [CZAuthenticationDC colorWithHexString:color];
    [label setTextColor:textColor];
}
//--------------------------------------------------------------------//
//END INITIALIZE VIEW
//--------------------------------------------------------------------//

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//START DELEGATE FUNCTIONS DC
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//-(void)refreshImage:(NSData *)imageData name:(NSString*)name
//{
//    UIImage *image = [UIImage imageWithData:imageData];
//    NSLog(@"IMAGES DATA: %@",name);
//    if([name isEqualToString:@"imageCover"]){
//        //UIImageView *imageUploaded = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.containerA.frame.origin.y)];
//        //self.imageHeaderBackgroundUP.image = [UIImage imageNamed:@"CZ-background009.jpg"];
//        self.imageHeaderBackgroundUP.alpha = 1.0;
//        [self.imageHeaderBackgroundUP setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.containerA.frame.origin.y)];
//        self.imageHeaderBackgroundUP.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageHeaderBackgroundUP.image = image;
//        [DC animationAlpha:self.imageHeaderBackgroundUP];
//    }
//}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"progress %f", progress);
}

-(void)performSegueWithIdentifier:(NSDictionary *)my
{
    NSLog(@"\n performSegueWithIdentifier %@", my);
    myUser = [NSDictionary dictionaryWithDictionary:my];
    [self hideWaiting];
    [self enableAllButton];
    [self performSegueWithIdentifier:@"toSignInUser" sender:self];
}

-(void)dismissViewControllerAnimated
{
    [self hideWaiting];
    [self enableAllButton];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//END DELEGATE FUNCTIONS DC
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//




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
    NSLog(@"dismissing keyboard %f",self.containerA.frame.origin.x);
    [self.view endEditing:YES];
}
//--------------------------------------------------------------------//
//END TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START FUNCTIONS
//--------------------------------------------------------------------//
-(void)animationAlpha:(UIView *)viewAnimated{
    NSLog(@"START animationAlpha %f",viewAnimated.alpha);
    viewAnimated.alpha = 0.0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         viewAnimated.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"START animationAlpha %f",viewAnimated.alpha);
                     }];
}

-(void)animationMessageError:(NSString *)msg{
    viewError.alpha = 0.0;
    labelError.text = msg;
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
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
                                          completion:nil];
                     }];
}


-(void)showWaiting:(NSString *)label {
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:HUD];
    }
    HUD.center = self.view.center;
    HUD.labelText = label;
    HUD.animationType = MBProgressHUDAnimationZoom;
    [HUD show:YES];
}

-(void)hideWaiting {
    [HUD hide:YES];
}
-(void)disableAllButton{
    self.buttonAccedi.enabled = NO;
    self.buttonFacebookLogin.enabled = NO;
    self.buttonIscriviti.enabled = NO;
}
-(void)enableAllButton{
    self.buttonAccedi.enabled = YES;
    self.buttonFacebookLogin.enabled = YES;
    self.buttonIscriviti.enabled = YES;
}
-(UIButton *)enableButton:(UIButton *)button{
    button.enabled = YES;
    button.hidden = NO;
    [button setAlpha:1];
    return button;
}
-(UIButton *)disableButton:(UIButton *)button{
    button.enabled = NO;
    button.hidden = YES;
    [button setAlpha:0.5];
    return button;
}

-(void)animationChangePage:(UIView *)containerON
{
    animationActive = YES;
    CGRect frameContainerON;
    CGRect frameContainerOFF;
    CGRect frameTriangle = self.imageTriangle.frame;
    if(containerON == self.containerA){
        NSLog(@"containerA ON");
        frameContainerON = CGRectMake(0, self.containerA.frame.origin.y, self.containerA.frame.size.width, self.containerA.frame.size.height);
        frameContainerOFF = CGRectMake(-self.containerB.frame.size.width, self.containerB.frame.origin.y, self.containerB.frame.size.width, self.containerB.frame.size.height);
        self.containerA.frame = CGRectMake(frameContainerON.size.width, frameContainerON.origin.y, frameContainerON.size.width, frameContainerON.size.height);
        CGFloat posXTriangle = (self.buttonAccedi.frame.origin.x+self.buttonAccedi.frame.size.width/2)-self.imageTriangle.frame.size.width/2;
        frameTriangle = CGRectMake(posXTriangle, self.imageTriangle.frame.origin.y, self.imageTriangle.frame.size.width, self.imageTriangle.frame.size.height);
    }
    else{
        NSLog(@"containerB ON");
        frameContainerON = CGRectMake(0, self.containerB.frame.origin.y, self.containerB.frame.size.width, self.containerB.frame.size.height);
        frameContainerOFF = CGRectMake(self.containerA.frame.size.width, self.containerA.frame.origin.y, self.containerA.frame.size.width, self.containerA.frame.size.height);
        self.containerB.frame = CGRectMake(-frameContainerON.size.width, frameContainerON.origin.y, frameContainerON.size.width, frameContainerON.size.height);
        [self.containerB setHidden:NO];
        CGFloat posXTriangle = (self.buttonIscriviti.frame.origin.x+self.buttonIscriviti.frame.size.width/2)-self.imageTriangle.frame.size.width/2;
        frameTriangle = CGRectMake(posXTriangle, self.imageTriangle.frame.origin.y, self.imageTriangle.frame.size.width, self.imageTriangle.frame.size.height);
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         if(containerON == self.containerA){
                             self.containerA.frame = frameContainerON;
                             self.containerB.frame = frameContainerOFF;
                         }else{
                             NSLog(@"containerB ON");
                             self.containerB.frame = frameContainerON;
                             self.containerA.frame = frameContainerOFF;
                         }
                         self.imageTriangle.frame = frameTriangle;
                     }
                     completion:^(BOOL finished){
                         animationActive = NO;
                     }];
}

//--------------------------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------------------------//



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString: @"firstTable"])
//    {
//        self.firstTableViewController = segue.destinationViewController;
//        self.firstTableViewController.delegate =self;
//    }
    if ([[segue identifier] isEqualToString:@"toSignInUser"]) {
        NSLog(@"prepareForSegue toSignInUser");
        UINavigationController *nc = [segue destinationViewController];
        CZSignInTVC *vc = (CZSignInTVC *)[[nc viewControllers] objectAtIndex:0];
        if(myUser){
            vc.stringFullName = [myUser objectForKey:@"name"];
            vc.stringEmail = [myUser objectForKey:@"email"];
            vc.idFacebookProfile = [myUser objectForKey:@"id"];
        } else{
//            vc.stringEmail = [PFUser currentUser].email;
        }
        
    } else if ([[segue identifier] isEqualToString:@"toWebView"]) {
    }
}



- (IBAction)actionLogin:(id)sender {
    NSLog(@"actionSignin %f - %f - %f",self.containerB.frame.origin.x, self.imageTriangle.frame.origin.x, posXTriangleStart );
    if(!(self.imageTriangle.frame.origin.x == posXTriangleStart)  && animationActive==NO ){
        [self animationChangePage:self.containerA];
    }
}

- (IBAction)actionSignin:(id)sender {
    NSLog(@"actionSignin %f - %f - %f",self.containerB.frame.origin.x, self.imageTriangle.frame.origin.x, posXTriangleStart );
    if((self.imageTriangle.frame.origin.x == posXTriangleStart) && animationActive==NO ){
        [self animationChangePage:self.containerB];
    }
}

- (IBAction)actionFacebookLogin:(id)sender {
    [self disableAllButton];
    [self showWaiting:NSLocalizedStringFromTable(@"AutenticazioneInCorso", @"CZ-AuthenticationLocalizable", @"")];
    [DC facebookLogin];
    

}

- (IBAction)actionExit:(id)sender {
    //se mi trovo in questa view sicuramente non sono loggato!!!
     [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:^{
//        //[self checkAutenticate];
//    }];
}

- (IBAction)unwindToAuthenticationVC:(UIStoryboardSegue*)sender{
     NSLog(@"unwindToAuthenticationVC");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// If ARC is used
- (void)dealloc {
     NSLog(@"DEALLOC");
    [DC setDelegate:nil];
    //[contentLoginVC setDelegate:nil];
}


@end
