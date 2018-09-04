//
//  HelloMyProfileTVC.h
//  chat21
//
//  Created by Andrea Sponziello on 19/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "HelloMyProfileTVC.h"
#import "HelloApplicationContext.h"
#import "ChatManager.h"
//#import "ChatRootNC.h"
#import "HelloUser.h"
#import "HelloAppDelegate.h"
#import "ChatUtil.h"
#import "ChatManager.h"
#import "ChatUser.h"
#import "HelpFacade.h"
#import "ChatImageUtil.h"
#import "ChatImagePreviewVC.h"
#import "ChatDiskImageCache.h"
#import "SVProgressHUD.h"

@interface HelloMyProfileTVC ()

@end

@implementation HelloMyProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"ver. %@ build %@", version, build];
    HelloAppDelegate *app = (HelloAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.appNameLabel.text = [app.applicationContext.settings objectForKey:@"app-name"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfilePhoto:)];
    singleTap.numberOfTapsRequired = 1;
    [self.profilePhotoImageView setUserInteractionEnabled:YES];
    [self.profilePhotoImageView addGestureRecognizer:singleTap];
    
    [[HelpFacade sharedInstance] activateSupportBarButton:self];
}

-(void)setupProfileImage {
    self.currentProfilePhoto = nil;
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.width / 2;
    self.profilePhotoImageView.clipsToBounds = YES;
    self.imageCache = [ChatManager getInstance].imageCache;
    ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
    NSString *imageURL = loggedUser.profileImageURL;
    NSLog(@"profile image url: %@", imageURL);
    [self.imageCache getImage:imageURL completionHandler:^(NSString *imageURL, UIImage *image) {
        [self setupCurrentProfileViewWithImage:image];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupProfileImage];
}

-(void)setupCurrentProfileViewWithImage:(UIImage *)image {
    self.currentProfilePhoto = image;
    if (image == nil) {
        [self resetProfilePhoto];
    }
    else {
        self.profilePhotoImageView.image = image;
    }
}

-(void)resetProfilePhoto {
    self.profilePhotoImageView.image = [UIImage imageNamed:@"user-profile-man.jpg"];
}

-(void)tapProfilePhoto:(UITapGestureRecognizer *)gestureRecognizer {
    UIAlertController * alert =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:NSLocalizedString(@"Change Profile Photo", nil)
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* delete = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"Remove Current Photo", nil)
                              style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * action)
                              {
                                  [self deleteImage];
                              }];
    
    UIAlertAction* show = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Show Photo", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                NSLog(@"Show photo");
                                [self showPhoto];
                            }];
    
    UIAlertAction* photo = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Photo", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                NSLog(@"Open photo");
                                [self takePhoto];
                            }];
    UIAlertAction* photo_from_library = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"Photo from library", nil)
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             NSLog(@"Open photo");
                                             [self chooseExisting];
                                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"cancel");
                             }];
    if (self.currentProfilePhoto != nil) {
        [alert addAction:delete];
        [alert addAction:show];
    }
    [alert addAction:photo];
    [alert addAction:photo_from_library];
    [alert addAction:cancel];
    UIPopoverPresentationController *popPresenter = [alert
                                                     popoverPresentationController];
    UIView *view = gestureRecognizer.view;
    popPresenter.sourceView = view;
    popPresenter.sourceRect = view.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) { // cella supporto
        if (![HelpFacade sharedInstance].supportEnabled) {
            return 0;
        }
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (IBAction)logoutAction:(id)sender {
    NSLog(@"Logout");
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Vuoi uscire?"
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* logout = [UIAlertAction
                             actionWithTitle:@"Si"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"Sending request");
                                 [self confirmLogout];
                             }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Annulla"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 NSLog(@"action canceled");
                             }];
    [view addAction:logout];
    [view addAction:cancel];
    // for ipad
    view.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    [self presentViewController:view animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    HelloUser *loggedUser = [HelloApplicationContext getSharedInstance].loggedUser;
    self.usernameLabel.text = loggedUser.username;
    self.useridLabel.text = loggedUser.userid;
    self.emailLabel.text = loggedUser.email;
    self.fullNameLabel.text = loggedUser.displayName;
}

- (void)confirmLogout {
    NSLog(@"LOGOUT");
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    HelloAppDelegate *app = (HelloAppDelegate *) [[UIApplication sharedApplication] delegate];
    HelloApplicationContext *context = app.applicationContext;
    [context signout];
    [self resetTab];
    
    // LOGOUT FIREBASE...
    //START SIGNOUT
    ChatManager *chatm = [ChatManager getInstance];
    [chatm dispose];
    //signout firebase
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    NSLog(@"logut status %d, error: %@", status, signOutError);
    if (!status) {
        NSLog(@"Error signing out from Firebase: %@", signOutError);
    }
    else {
        NSLog(@"Successfully signed out from Firebase");
    }
}

-(void)resetTab {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UITabBarController *tabController = (UITabBarController *)window.rootViewController;
    tabController.selectedIndex = 0;
}

- (IBAction)helpAction:(id)sender {
    NSLog(@"Help in %@ view.", NSStringFromClass([self class]));
    [[HelpFacade sharedInstance] openSupportView:self];
}

-(void)helpWizardEnd:(NSDictionary *)context {
    NSLog(@"helpWizardEnd");
    [context setValue:NSStringFromClass([self class]) forKey:@"section"];
    [[HelpFacade sharedInstance] handleWizardSupportFromViewController:self helpContext:context];
}

-(void)showPhoto {
    [self performSegueWithIdentifier:@"imagePreview" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"imagePreview"]) {
        ChatImagePreviewVC *vc = (ChatImagePreviewVC *)[segue destinationViewController];
        NSLog(@"vc %@", vc);
        vc.image = self.currentProfilePhoto;
    }
}

// **************************************************
// **************** TAKE PHOTO SECTION **************
// **************************************************

- (void)takePhoto {
    //    NSLog(@"taking photo with user %@...", self.applicationContext.loggedUser);
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:^{}];
}

- (void)chooseExisting {
    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    NSLog(@"cinitializeCamera...");
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // TODO apri showImagePreview
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    UIImage *bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSURL *local_image_url = [info objectForKey:@"UIImagePickerControllerImageURL"];
    NSString *image_original_file_name = [local_image_url lastPathComponent];
    NSLog(@"image_original_file_name: %@", image_original_file_name);
    self.scaledImage = bigImage;
    NSLog(@"image: %@", self.scaledImage);
    self.scaledImage = [ChatImageUtil adjustEXIF:self.scaledImage];
    self.scaledImage = [ChatImageUtil scaleImage:self.scaledImage toSize:CGSizeMake(1200, 1200)];
//    [self performSegueWithIdentifier:@"imagePreview" sender:nil];
    [self sendImage:self.scaledImage];
}

-(void)sendImage:(UIImage *)image {
    NSLog(@"Sending image...");
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    // save image to cache
    ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
    [[ChatManager getInstance] uploadProfileImage:image profileId:loggedUser.userId completion:^(NSString *downloadURL, NSError *error) {
            NSLog(@"Image uploaded. Download url: %@", downloadURL);
            [SVProgressHUD dismiss];
            if (error) {
                NSLog(@"Error during image upload.");
            }
            else {
                [self setupCurrentProfileViewWithImage:image];
                [self.imageCache addImageToCache:image withKey:[self.imageCache urlAsKey:[NSURL URLWithString:downloadURL]]];
                // group profile photo
            }
        } progressCallback:^(double fraction) {
            // NSLog(@"progress: %f", fraction);
        }];
}

-(void)deleteImage {
    NSLog(@"deleting profile image");
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
    [[ChatManager getInstance] deleteProfileImageOfUser:loggedUser.userId completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        // remove this three lines of code
        self.currentProfilePhoto = nil;
        [self resetProfilePhoto];
        ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
        [self.imageCache deleteImageFromCacheWithKey:[self.imageCache urlAsKey:[NSURL URLWithString:loggedUser.profileImageURL]]];
        if (error) {
            NSLog(@"Error while deleting profile image.");
        }
        else {
            self.currentProfilePhoto = nil;
            [self resetProfilePhoto];
            ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
            [self.imageCache deleteImageFromCacheWithKey:[self.imageCache urlAsKey:[NSURL URLWithString:loggedUser.profileImageURL]]];
        }
    }];
}

// **************************************************
// *************** END PHOTO SECTION ****************
// **************************************************

@end
