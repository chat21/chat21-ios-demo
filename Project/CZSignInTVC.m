//
//  CZSignInTVC.m
//  AboutMe
//
//  Created by Dario De pascalis on 29/03/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "CZSignInTVC.h"
//#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MBProgressHUD.h"
#import "DDPWebPagesVC.h"
#import "SHPImageRequest.h"
#import "SHPApplicationContext.h"
#import "SHPUser.h"
#import "SHPConstants.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"

@interface CZSignInTVC ()
@end

@implementation CZSignInTVC

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
     NSLog(@"\n viewDidLoad CZSignInTVC:");
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.textNameComplete.delegate = self;
    self.textPassword.delegate = self;
    self.textEmail.delegate = self;
    self.textUsername.delegate = self;
    DC = [[CZAuthenticationDC alloc] init];
    DC.delegate = self;
    //-------------------------------------------//
    //custom navibation bar, button
    [CZAuthenticationDC setTrasparentBackground:self.navigationController];
    [CZAuthenticationDC setAlphaBackground:self.navigationController bckColor:[UIColor blackColor] alpha:1];
    UIColor *itemColor = [CZAuthenticationDC colorWithHexString:@"FFFFFF"];
    [self.navigationItem.titleView setTintColor:itemColor];
    [self.navigationItem.rightBarButtonItem setTintColor:itemColor];
    [self customBackButton];
    //[self customNextButton];
    //-------------------------------------------//
    //add view message
    [self initialize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     NSLog(@"viewWillAppearxxx");
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self facebookUnlink];
}

-(void)initialize{
    settings_config = [self readerPlistForSettings];
    self.imageProfile.userInteractionEnabled = TRUE;
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapImage)];
    [self.imageProfile addGestureRecognizer:tapRec];
    
    self.textNameComplete.placeholder = NSLocalizedStringFromTable(@"NomeCompleto", @"CZ-AuthenticationLocalizable", @"");
    self.textUsername.placeholder = NSLocalizedStringFromTable(@"Username", @"CZ-AuthenticationLocalizable", @"");
    self.textEmail.placeholder = NSLocalizedStringFromTable(@"Email", @"CZ-AuthenticationLocalizable", @"");
    self.textPassword.placeholder = NSLocalizedStringFromTable(@"Password", @"CZ-AuthenticationLocalizable", @"");
    [self.buttonPrivacy setTitle:NSLocalizedStringFromTable(@"AccettaPrivacy", @"CZ-AuthenticationLocalizable", @"") forState:UIControlStateNormal];
    //self.buttonNext.title = NSLocalizedStringFromTable(@"Indietro", @"CZ-AuthenticationLocalizable", @"");
    self.buttonNext.title = NSLocalizedStringFromTable(@"Avanti", @"CZ-AuthenticationLocalizable", @"");
    self.labelPhoto.text =  NSLocalizedStringFromTable(@"Foto", @"CZ-AuthenticationLocalizable", @"");
    
    if(self.stringEmail){
        self.textEmail.text = self.stringEmail;
    }
    if(self.stringFullName){
        self.textNameComplete.text = self.stringFullName;
    }
    [self loadImageProfileFB:self.idFacebookProfile];
    //[self loadImageCoverFB:self.fbUserId];
    
    [self addGestureRecognizerToView];
    [self addControllChangeTextField:self.textNameComplete];
    [self addControllChangeTextField:self.textEmail];
    [self addControllChangeTextField:self.textPassword];
    //self.buttonNext.enabled = NO;

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

-(NSDictionary *)readerPlistForSettings{
    NSString *plistCatPath = [[NSBundle mainBundle] pathForResource:@"settingsAuthentication" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistCatPath];
    return [plistDictionary objectForKey:@"Settings"];
}

//--------------------------------------------------------------------//
//START FUNCTIONS
//--------------------------------------------------------------------//
-(void)animationMessageError:(NSString *)msg{
    //startedAnimation = YES;
    //self.buttonNext.enabled = NO;
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
                                              self.buttonNext.enabled = YES;
                                          }];
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

-(void)customBackButton{
    UIImage *faceImage = [UIImage imageNamed:@"buttonArrowLeft.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    [face addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)customNextButton{
    UIImage *faceImage = [UIImage imageNamed:@"buttonArrowRight.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    [face addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.rightBarButtonItem = nextButton;
}

-(void)loadImageProfileFB:(NSString *)idFacebook
{
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    NSString *fbProfilePictureURL = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large", idFacebook];
    [imageRequest downloadImage:fbProfilePictureURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             self.imageProfile.image = image;
             self.imageBackground.image = image;
             [DC animationAlpha:self.imageProfile];
             [DC animationAlpha:self.imageBackground];
             [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
         } else {
             NSLog(@"Image not loaded!");
             //self.imageProfile.image = [UIImage imageNamed:@"noProfile"];
             //put an image that indicates "no image profile"
         }
     }];
}
//--------------------------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------------------------//


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
//    if(self.textUsername.text.length==0 || self.textNameComplete.text.length==0 || self.textEmail.text==0){//|| self.textPassword.text.length==0
//        self.buttonNext.enabled = NO;
//    }else{
//        self.buttonNext.enabled = YES;
//    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    
    //self.tableView.contentOffset = CGPointMake(0, - (self.tableView.contentInset.top) animated:YES);
    CGFloat yOffset = - (self.tableView.contentInset.top);
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    
    if(self.textUsername.text.length==0){
        self.imageUsername.image = [UIImage imageNamed:@"username"];
    }
    if(self.textNameComplete.text.length==0){
        self.imageNameComplete.image = [UIImage imageNamed:@"badge"];
    }
    if(self.textPassword.text.length==0){
        self.imagePassword.image = [UIImage imageNamed:@"password"];
    }
    if(self.textEmail.text==0){
        self.imageEmail.image = [UIImage imageNamed:@"mail"];
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [self goToNext];
    //[textField resignFirstResponder];
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

-(BOOL)validateForm {
    NSLog(@"switchTermOfUse STATE: %u", self.switchTermOfUse.on);
    NSString *usernameValue = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nameValue = [self.textNameComplete.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![self validEmail:emailValue]) {
        self.imageEmail.image = [UIImage imageNamed:@"mail_red"];
        errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"EmailError", @"CZ-AuthenticationLocalizable", @"")];
        [self animationMessageError:errorMessage];
        return false;
    }else{
        self.imageEmail.image = [UIImage imageNamed:@"mail_green"];
    }
//    if ([usernameValue isEqualToString:@""] || usernameValue.length<MIN_CHARS_USERNAME || ![self isUsernameValid:usernameValue]) {
    if (![self isUsernameValid:usernameValue]) {
        self.imageUsername.image = [UIImage imageNamed:@"username_red"];
        errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"UsernameNonValido", @"CZ-AuthenticationLocalizable", @""), MIN_CHARS_USERNAME];
        [self animationMessageError:errorMessage];
        return false;
    }else{
        self.imageUsername.image = [UIImage imageNamed:@"username_green"];
    }
    if(facebookId.length<=0 && ([passwordValue isEqualToString:@""] || passwordValue.length<MIN_CHARS_PASSWORD)) {
        self.imagePassword.image = [UIImage imageNamed:@"password_red"];
        errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"PasswordNonValida", @"CZ-AuthenticationLocalizable", @""), MIN_CHARS_PASSWORD];
        [self animationMessageError:errorMessage];
        return false;
    }else{
        self.imagePassword.image = [UIImage imageNamed:@"password_green"];
    }
    if ([nameValue isEqualToString:@""] || nameValue.length<MIN_CHARS_NAMECOMPLETE) {
        self.imageNameComplete.image = [UIImage imageNamed:@"badge_red"];
        errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"NomeNonValido", @"CZ-AuthenticationLocalizable", @"")];
        [self animationMessageError:errorMessage];
        return false;
    }else{
        self.imageNameComplete.image = [UIImage imageNamed:@"badge_green"];
    }
    if (self.switchTermOfUse.on==NO) {
        errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"AccettaTermini", @"CZ-AuthenticationLocalizable", @"")];
        [self animationMessageError:errorMessage];
        return false;
    }
    return true;
}

-(BOOL)isUsernameValid:(NSString *)username {
    NSString * const regularExpression = @"^[A-Za-z0-9_]{6,}$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                        options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:username
                                                        options:0
                                                        range:NSMakeRange(0, [username length])];
    NSLog(@"USERNAME VALID (0 = NO): %ld", numberOfMatches);
    
    
    return numberOfMatches > 0;
}

//--------------------------------------------------------------------//
//END FUNCTIONS
//--------------------------------------------------------------------//



//-------------------------------------------------------------------//
//START FUNCTION IMAGE PROFILE
//-------------------------------------------------------------------//
-(void)didTapImage {
    NSLog(@"tapped");
    [self dismissKeyboard];
    
    // sostituire con UIAlertController * view =   [UIAlertController...
    takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Annulla", @"CZ-AuthenticationLocalizable", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"TakePhoto", @"CZ-AuthenticationLocalizable", @""), NSLocalizedStringFromTable(@"PhotoFromGallery", @"CZ-AuthenticationLocalizable", @""), NSLocalizedStringFromTable(@"RemoveProfilePhoto", @"CZ-AuthenticationLocalizable", @""), nil];
    takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [takePhotoMenu showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert Button!");
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:NSLocalizedStringFromTable(@"TakePhoto", @"CZ-AuthenticationLocalizable", @"")]) {
        NSLog(@"Take Photo");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self takePhoto];
        }];
    }
    else if ([option isEqualToString:NSLocalizedStringFromTable(@"PhotoFromGallery", @"CZ-AuthenticationLocalizable", @"")]) {
        NSLog(@"Choose from Gallery");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self chooseExisting];
        }];
    }
    else if ([option isEqualToString:NSLocalizedStringFromTable(@"RemoveProfilePhoto", @"CZ-AuthenticationLocalizable", @"")]) {
        NSLog(@"Choose from Gallery");
        [self resetUserPhoto];
    }
}

-(void)resetUserPhoto {
    self.imageProfile.image = nil;
    self.imageBackground.image = nil;
}

- (void)takePhoto {
    if (imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)chooseExisting {
    if (photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    photoLibraryController = [[UIImagePickerController alloc] init];
    photoLibraryController.delegate = self;
    photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoLibraryController.allowsEditing = YES;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"imagePickerController");
    //self.image = selectedImage;
    UIImage *image = [[UIImage alloc] init];
    //image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    CGSize size = CGSizeMake(320, 320); // using facebook type=large image size.
    userImage = [SHPImageUtil scaleImage:image toSize:size];
//    if (!image) {
//        image = [UIImage imageNamed:@"noProfile.jpg"];
//    }
    [CZAuthenticationDC arroundImage:(self.imageProfile.frame.size.height/2) borderWidth:0.0 layer:[self.imageProfile layer]];
    self.imageProfile.image = userImage;
    self.imageBackground.alpha = 0;
    self.imageBackground.image = [DC blur:image radius:5];
    [DC animationAlpha:self.imageBackground];
//    [DC saveImageWithoutDelegate:userImage nameImage:NAME_IMAGE_PROFILE];
}

//-------------------------------------------------------------------//
//END FUNCTION IMAGE PROFILE
//-------------------------------------------------------------------//


//--------------------------------------------------------------------//
//START SIGNIN
//--------------------------------------------------------------------//

//-(void)getCoverImage
//{
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                                  initWithGraphPath:@"me?fields=cover"
//                                  parameters:nil
//                                  HTTPMethod:@"GET"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                          id result,
//                                          NSError *error) {
//        /* handle the result */
//        NSDictionary *userCover = [result valueForKey:@"cover"];
//        NSString *coverURL = [userCover valueForKey:@"source"];
//        NSLog(@"result! %@",coverURL);
//        //NSURL *coverURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/?fields=cover", facebookId]];
//        NSURL *url = [NSURL URLWithString:coverURL];
//        NSData *imageData = [NSData dataWithContentsOfURL:url];
//        PFFile *imageView = (PFFile *)[PFFile fileWithName:@"imageCover" data:imageData];
//        [DC loadImage:imageView];
//    }];
//}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//DELEGATE FUNCTIONS DC
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
-(void)refreshImage:(NSData *)imageData name:(NSString*)name
{
    UIImage *image = [UIImage imageWithData:imageData];
    NSLog(@"IMAGES DATA: %@",name);//[HUD hide:YES];
    if([name isEqualToString:@"imageCover"]){
        self.imageBackground.image = image;
        [DC animationAlpha:self.imageBackground];
    }
    else{
        self.imageProfile.image = image;
        [CZAuthenticationDC arroundImage:(self.imageProfile.frame.size.height/2) borderWidth:0.0 layer:[self.imageProfile layer]];
        
        self.imageBackground.alpha = 0;
        self.imageBackground.image = [DC blur:image radius:5];
        [DC animationAlpha:self.imageBackground];
//        [DC saveImageWithoutDelegate:image nameImage:NAME_IMAGE_PROFILE key:KEY_IMAGE_PROFILE];
    }
}

- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress
{
    HUD.progress = progress;
    NSLog(@"progress %f", progress);
}
//- (void)performSegueWithIdentifier{}

//-(void)completeProfile {
//    NSLog(@"completeProfile +++++++++++++++++++++++++ ");
//    [self showWaiting:NSLocalizedStringFromTable(@"RegistrazioneInCorso", @"CZ-AuthenticationLocalizable", @"")];
//    NSString *nameValue = [self.textNameComplete.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *usernameValue = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    PFUser *user = [PFUser currentUser];
//    user.username = usernameValue;
//    user.password = passwordValue;
//    user.email = emailValue;
//   
//    if(userName)user[@"fullName"] = nameValue;
//    if(facebookId)user[@"facebookId"] = facebookId;
//    if(userCity)user[@"city"] = userCity;
//    
//    NSLog(@"------------ > completeProfile : %@ - %@ - %@",user,user[@"fullName"],nameValue);
//    //[user saveEventually];
//    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        //[self hideWaiting];
//        if (!error) {
//            NSLog(@"ENTRATO");
//            [self hideWaiting];
//            [self performSegueWithIdentifier:@"unwindToAuthenticationVC" sender:self];
//        } else {
//            [self hideWaiting];
//            errorMessage = [error userInfo][@"error"];
//            NSNumber *errorCode = [error userInfo][@"code"];
//            if([errorCode  isEqual: @202]){
//                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"UsernameGiaPresente", @"CZ-AuthenticationLocalizable", @""), usernameValue];
//                self.imageUsername.image = [UIImage imageNamed:@"username_red"];
//            }else if([errorCode  isEqual: @203]){
//                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"EmailGiaPresente", @"CZ-AuthenticationLocalizable", @""), emailValue];
//                self.imageEmail.image = [UIImage imageNamed:@"email_red"];
//            }
//            [self animationMessageError:errorMessage];
//        }
//    }];
//}


//-(void)registrationUser {
//    [self showWaiting:NSLocalizedStringFromTable(@"RegistrazioneInCorso", @"CZ-AuthenticationLocalizable", @"")];
//    NSString *nameValue = [self.textNameComplete.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *usernameValue = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *emailValue = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *passwordValue = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    PFUser *user = [PFUser user];
//    user.username = usernameValue;
//    user.password = passwordValue;
//    user.email = emailValue;
//    if(nameValue)user[@"fullName"] = nameValue;
//    NSData *imageData = UIImagePNGRepresentation(self.imageProfile.image);
//    PFFile *imageFile = [PFFile fileWithName:NAME_IMAGE_PROFILE data:imageData];
//    user[@"image"] = imageFile;
//    if(self.imageProfile.image){
//        [DC saveImageWithoutDelegate:self.imageProfile.image nameImage:NAME_IMAGE_PROFILE key:KEY_IMAGE_PROFILE];
//    }
//    NSLog(@"user::::::::: %@ - %@", user, self.imageProfile.image);
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        [self hideWaiting];
//        if (!error) {
//            NSLog(@"ENTRATO");
//            //[self saveSessionToken];
//            [self savePassword:user.password];
//            [self performSegueWithIdentifier:@"unwindToAuthenticationVC" sender:self];
//        } else {
//            errorMessage = [error userInfo][@"error"];
//            NSNumber *errorCode = [error userInfo][@"code"];
//            if([errorCode  isEqual: @202]){
//                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"UsernameGiaPresente", @"CZ-AuthenticationLocalizable", @""), usernameValue];
//                self.imageUsername.image = [UIImage imageNamed:@"username_red"];
//            }else if([errorCode  isEqual: @203]){
//                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTable(@"EmailGiaPresente", @"CZ-AuthenticationLocalizable", @""), emailValue];
//                self.imageEmail.image = [UIImage imageNamed:@"email_red"];
//            }
//            [self animationMessageError:errorMessage];
//        }
//    }];
//}


//-(void)savePassword:(NSString *)password {
//    NSLog(@"*************** SAVE PASSWORD: %@ ***************",password);
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    [userPreferences setObject:password forKey:@"PASSWORD"];
//    [userPreferences synchronize];
//}

-(void)singInViewController{
    NSLog(@"*************** singInViewController: %@ ***************", self.textPassword.text);
    [self.view endEditing:YES];
    if([self validateForm]){
        [self.buttonNext setEnabled:NO];
        [self dismissKeyboard];
        [self showWaiting:NSLocalizedString(@"Authenticating", nil)];
        
        DC.applicationContext = self.applicationContext;
        DC.fbUsername = self.textUsername.text;
        DC.fbUserEmail = self.textEmail.text;
        DC.fbProfileImage = self.imageProfile.image;
        DC.fbNameComplete = self.textNameComplete.text;
        DC.fbPassword = self.textPassword.text;
        [DC sendRegistrationWithFormData:self.imageProfile.image textNameComplete:self.textNameComplete.text textUsername:self.textUsername.text textEmail:self.textEmail.text textPassword:self.textPassword.text];
    }
}

//--------------------------------------------------------------------//
//END SIGNIN
//--------------------------------------------------------------------//


//-------------------------------------------------------------------//
//START FUNCTION BUILD TABLE
//-------------------------------------------------------------------//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
//    if([identifierCell isEqualToString:@"idCellPassword"]){
//        if([PFUser currentUser]){
//            return 0.0;
//       }
//    }
    if([identifierCell isEqualToString:@"idCellHeader"]){
        return 190.0;
    }
    return 40.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toWebView"]) {
        NSLog(@"prepareForSegue toWebView");
        UINavigationController *nc = [segue destinationViewController];
        DDPWebPagesVC *vc = (DDPWebPagesVC *)[[nc viewControllers] objectAtIndex:0];
        
        NSString *lang = [self getLangCode];
        // default language = "en"
        if (![lang isEqualToString:@"en"] && ![lang isEqualToString:@"it"]) {
            lang = @"en";
        }
        NSLog(@"SELECTED LANG = %@",lang);
        NSString *url_no_lang = [settings_config objectForKey:@"urlTermsPage"];
        vc.urlPage = [[NSString alloc] initWithFormat:@"%@-%@",url_no_lang, lang];
    }
}
//-------------------------------------------------------------------//
//END FUNCTION BUILD TABLE
//-------------------------------------------------------------------//

-(NSString *)getLangCode {
    NSString *localeId = [[NSLocale currentLocale] localeIdentifier];
    NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:localeId];
    NSLog(@"[NSLocale componentsFromLocaleIdentifier:localeId] = %@", components);
    NSString *languagecode = components[@"kCFLocaleLanguageCodeKey"];
    NSString *countrycode = components[@"kCFLocaleCountryCodeKey"];
    NSLog(@"languagecode (kCFLocaleLanguageCodeKey) = %@", languagecode);
    NSLog(@"countrycode (kCFLocaleCountryCodeKey) = %@", countrycode);
    return languagecode;
}

-(void)dismissViewControllerAnimated
{
    [self hideWaiting];
     NSLog(@"\n dismissViewControllerAnimated");
    [self performSegueWithIdentifier:@"unwindToAuthenticationVC" sender:self];
    //[self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)goToBack{
    NSLog(@"\n goToBack");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goToNext{
    [self singInViewController];
}


- (IBAction)actionPrivacy:(id)sender {
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}

- (IBAction)actionPreviou:(id)sender {
    [self goToBack];
}

- (IBAction)actionNext:(id)sender {
    [self goToNext];
}


- (void)dealloc {
    NSLog(@"DEALLOC");
    //[DC setDelegate:nil];
    self.textPassword.delegate = nil;
    self.textUsername.delegate = nil;
    self.textNameComplete.delegate = nil;
    self.textEmail.delegate = nil;
}
@end
