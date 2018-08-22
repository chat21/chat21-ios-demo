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
#import "ChatImageCache.h"

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
    [alert addAction:delete];
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
    self.imagePickerController.allowsEditing = NO;
}

-(void)initializePhotoLibrary {
    NSLog(@"initializePhotoLibrary...");
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;// SavedPhotosAlbum;
    self.photoLibraryController.allowsEditing = NO;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // TODO apri showImagePreview
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self afterPickerCompletion:picker withInfo:info];
}

-(void)afterPickerCompletion:(UIImagePickerController *)picker withInfo:(NSDictionary *)info {
    UIImage *bigImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    for(id i in info.allKeys) {
    //        NSLog(@"k: %@, v: %@ [class:%@]", i, info[i], NSStringFromClass([info[i] class]));
    //    }
    NSURL *local_image_url = [info objectForKey:@"UIImagePickerControllerImageURL"];
    NSString *image_original_file_name = [local_image_url lastPathComponent];
    NSLog(@"image_original_file_name: %@", image_original_file_name);
    self.scaledImage = bigImage;
    // save image in photos
    //    if (picker == self.imagePickerController) {
    //        UIImageWriteToSavedPhotosAlbum(self.bigImage, self,
    //                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //    }
    NSLog(@"image: %@", self.scaledImage);
    self.scaledImage = [ChatImageUtil adjustEXIF:self.scaledImage];
    self.scaledImage = [ChatImageUtil scaleImage:self.scaledImage toSize:CGSizeMake(1200, 1200)];
    [self performSegueWithIdentifier:@"imagePreview" sender:nil];
}

- (IBAction)unwindToProfileVC:(UIStoryboardSegue*)sender {
    NSLog(@"exited");
    [self dismissViewControllerAnimated:YES completion:nil];
    UIViewController *sourceViewController = sender.sourceViewController;
    if ([sourceViewController isKindOfClass:[ChatImagePreviewVC class]]) {
        ChatImagePreviewVC *vc = (ChatImagePreviewVC *) sourceViewController;
        if (vc.image) {
            UIImage *imageToSend = vc.image;
            NSLog(@"image to send: %@", imageToSend);
            [self sendImage:imageToSend];
        }
        else {
            NSLog(@"operation canceled");
        }
    }
}

-(void)sendImage:(UIImage *)image {
    NSLog(@"Sending image...");
    // save image to cache
//    [[ChatImageCache getSharedInstance] addImage:image withKey:@""];
    HelloUser *loggedUser = [HelloApplicationContext getSharedInstance].loggedUser;
    [self uploadProfileImage:image userId:loggedUser.userid completion:^(NSURL *downloadURL, NSError *error) {
            NSLog(@"Image uploaded. Download url: %@", downloadURL);
            if (error) {
                NSLog(@"Error during image upload.");
            }
            else {
                self.profilePhotoImageView.image = image;
                // TODO:
                // cache photo on file (with expiration date)
                // update photo url in user's contact entry
                // get photo from cache
                // get photo from remote
                
                
//                NSString *image_text = [ChatMessage imageTextPlaceholder:downloadURL.absoluteString];
//                message.metadata.src = downloadURL.absoluteString;
//                message.text = image_text;
//                message.status = MSG_STATUS_SENDING;
//                [self.conversationHandler sendImagePlaceholderMessage:message completion:^(ChatMessage *m, NSError *e) {
//                    NSLog(@"Image message successfully sent.");
//                }];
            }
        } progressCallback:^(double fraction) {
            //            NSLog(@"progress: %f", fraction);
        }];
}

-(void)uploadProfileImage:(UIImage *)image userId:(NSString *)userId completion:(void(^)(NSURL *downloadURL, NSError *error))callback progressCallback:(void(^)(double fraction))progressCallback {
    NSData *data = UIImagePNGRepresentation(image);
    // Get a reference to the storage service using the default Firebase App
    FIRStorage *storage = [FIRStorage storage];
    // Create a root reference
    FIRStorageReference *storageRef = [storage reference];
    NSString * uuid = [[NSUUID UUID] UUIDString];
    NSString *file_path = [[NSString alloc] initWithFormat:@"profiles/%@/photo.png", uuid];
    NSLog(@"image remote file path: %@", file_path);
    // Create a reference to the file you want to upload
    FIRStorageReference *storeRef = [storageRef child:file_path];
    // Create file metadata including the content type
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    // Upload the file to the path
//    FIRStorageUploadTask *uploadTask =
    [storeRef putData:data metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
          if (error != nil) {
              NSLog(@"an error occurred!");
              callback(nil, error);
          } else {
              // Metadata contains file metadata such as size, content-type, and download URL
              [storeRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                  if (error != nil) {
                      NSLog(@"an error occurred! %@", error);
                      callback(nil, error);
                  } else {
                      NSLog(@"Download url: %@", URL);
                      callback(URL, error);
                  }
              }];
          }
      }];
//    FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
//                                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
//                                                      //                                                      NSLog(@"uploading %@", snapshot);
//                                                      //                                                      NSLog(@"completion: %f, %lld", snapshot.progress.fractionCompleted, snapshot.progress.completedUnitCount);
//                                                      progressCallback(snapshot.progress.fractionCompleted);
//                                                  }];
}

-(void)deleteImage {
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"(SHPTakePhotoViewController) Error saving image to camera roll.");
    }
    else {
        //NSLog(@"(SHPTakePhotoViewController) Image saved to camera roll. w:%f h:%f", self.image.size.width, self.image.size.height);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"imagePreview"]) {
        ChatImagePreviewVC *vc = (ChatImagePreviewVC *)[segue destinationViewController];
        NSLog(@"vc %@", vc);
        vc.image = self.scaledImage;
    }
}

// **************************************************
// *************** END PHOTO SECTION ****************
// **************************************************

@end
