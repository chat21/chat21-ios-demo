//
//  CZSignInEmailVC.m
//  AboutMe
//
//  Created by Dario De pascalis on 29/03/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "CZSignInEmailVC.h"
#import "CZSignInTVC.h"

@interface CZSignInEmailVC ()
@end

@implementation CZSignInEmailVC

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textEmail.delegate = self;
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

-(void)initialize{
    [self.buttonNext setTitle:NSLocalizedStringFromTable(@"Avanti", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    self.textEmail.placeholder = NSLocalizedStringFromTable(@"InserisciEmail", @"CZ-AuthenticationLocalizable", @"");
    [self disableButton:self.buttonNext];
    //[self.textEmail becomeFirstResponder];
    [self addControllChangeTextField:self.textEmail];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear SIGNEMAIL");
}

//--------------------------------------------------------------------//
//START TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//
-(void)addControllChangeTextField:(UITextField *)textField
{
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if ([self.textEmail.text length]>0) {
        [self enableButton:self.buttonNext];
    }else{
        [self disableButton:self.buttonNext];
    }
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

-(void)dismissKeyboard{
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    if(viewError.alpha == 0){
        [self goNextStep];
    }
    return YES;
}
//--------------------------------------------------------------------//
//END TEXTFIELD CONTROLLER
//--------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START FUNCTIONS
//--------------------------------------------------------------------//
-(BOOL)validEmail:(NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

-(void)animationMessageError:(NSString *)msg{
    //startedAnimation = YES;
    [self disableButton:self.buttonNext];
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
                                              [self enableButton:self.buttonNext];
                                          }];
                     }];
}


//--------------------------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------------------------//

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toSignInUser"]) {
        NSLog(@"prepareForSegue toSignInUser");
        UINavigationController *nc = [segue destinationViewController];
        CZSignInTVC *vc = (CZSignInTVC *)[[nc viewControllers] objectAtIndex:0];
        vc.stringEmail = self.textEmail.text;
    }
}

-(void)goNextStep{
     NSLog(@"goNextStep");
    if([self validEmail:self.textEmail.text]){
        [self performSegueWithIdentifier:@"toSignInUser" sender:self];
    }else{
        errorMessage =  [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"EmailError", @"CZ-AuthenticationLocalizable", @"")];//[error localizedDescription];
        [self animationMessageError:errorMessage];
    }
}


- (IBAction)actionNext:(id)sender {
    if(viewError.alpha == 0){
        [self goNextStep];
    }
}

- (void)dealloc{
    self.textEmail.delegate = nil;
}

@end
