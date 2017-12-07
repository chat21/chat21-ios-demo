//
//  CZSignInTVC.h
//  AboutMe
//
//  Created by Dario De pascalis on 29/03/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZAuthenticationDC.h"

@class MBProgressHUD;
@class SHPApplicationContext;

@interface CZSignInTVC : UITableViewController<CZAuthenticationDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>{
    UIActionSheet *takePhotoMenu;
    UIImagePickerController *imagePickerController;
    UIImagePickerController *photoLibraryController;
    CZAuthenticationDC *DC;
    MBProgressHUD *HUD;
    
    NSString *facebookId;
    UIImage *userImage;
    NSString *userCity;
    NSString *userName;
    NSString *userEmail;
    NSString *userUsername;
    
    NSString *errorMessage;
    UIView *viewError;
    UILabel *labelError;
    
    NSDictionary * settings_config;
}

//@property (weak, nonatomic) IBOutlet UIView *viewError;
//@property (weak, nonatomic) IBOutlet UILabel *labelError;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *stringEmail;
@property (strong, nonatomic) NSString *stringFullName;
@property (strong, nonatomic) NSString *idFacebookProfile;

@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;
@property (weak, nonatomic) IBOutlet UIView *viewPhotoUser;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imageUsername;
@property (weak, nonatomic) IBOutlet UITextField *textUsername;
@property (weak, nonatomic) IBOutlet UIImageView *imagePassword;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imageNameComplete;
@property (weak, nonatomic) IBOutlet UITextField *textNameComplete;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonPreviou;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonNext;
@property (strong, nonatomic) IBOutlet UISwitch *switchTermOfUse;
@property (strong, nonatomic) IBOutlet UIButton *buttonPrivacy;


- (IBAction)actionPrivacy:(id)sender;
- (IBAction)actionPreviou:(id)sender;
- (IBAction)actionNext:(id)sender;
@end
