//
//  SHPHomeProfileTVC.h
//  Italiacamp
//
//  Created by dario de pascalis on 08/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"

@class SHPApplicationContext;
//@class SHPUser;
@class MBProgressHUD;
@class ChatImageCache;
@class ChatUser;

@interface SHPHomeProfileTVC : UITableViewController <SHPUserDCDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//< SHPUserDCDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *listMode;
    NSString *rowSelected;
    BOOL isLoadingData;
    NSMutableArray *listProducts;
    NSMutableArray *listProductsLiked;
    NSMutableArray *listProductsCreated;
    CGFloat defaultH;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) ChatUser *user;
@property (strong, nonatomic) ChatUser *otherUser;
//@property (strong, nonatomic) SHPUserDC *loaderUser;
@property (strong, nonatomic) UITapGestureRecognizer* tapRec;

//@property (weak, nonatomic) IBOutlet UILabel *labelCreati;
//@property (weak, nonatomic) IBOutlet UILabel *labelNumberCreated;
//@property (weak, nonatomic) IBOutlet UILabel *labelPiaciuti;
//@property (weak, nonatomic) IBOutlet UILabel *labelNumberLiked;
//@property (weak, nonatomic) IBOutlet UILabel *labelHookFacebook;
@property (weak, nonatomic) IBOutlet UILabel *labelModificaProfilo;
@property (weak, nonatomic) IBOutlet UILabel *labelLogout;
@property (weak, nonatomic) IBOutlet UIImageView *imageBckDw;
@property (weak, nonatomic) IBOutlet UIImageView *imageBckUp;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelUserNameComplete;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelChat;
@property (strong, nonatomic) ChatImageCache *imageCache;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UILabel *labelSettings;
@property (weak, nonatomic) IBOutlet UILabel *labelHelp;
@property (strong, nonatomic) UIImage *user_image;

// user photo section
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIImage *backupUserImage;
//@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIActionSheet *takePhotoMenu;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, assign) NSInteger statusCode;
// end user photo section

@end
