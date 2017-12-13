//
//  SHPHomeProfileTVC.m
//  Italiacamp
//
//  Created by dario de pascalis on 08/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "SHPHomeProfileTVC.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPImageRequest.h"
#import "SHPImageUtil.h"
#import "ChatManager.h"
#import "ChatConversationsVC.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPServiceUtil.h"
#import "ChatImageCache.h"
#import "ChatImageWrapper.h"
#import "ChatSettingsTVC.h"
#import "ChatRootNC.h"
#import "ChatConversationsVC.h"
#import "SHPMiniWebBrowserVC.h"
#import "ChatUtil.h"
#import "ChatMessagesVC.h"

@interface SHPHomeProfileTVC ()
@end

@implementation SHPHomeProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"+++++ SHPHomeProfileTVC.viewDidLoad");
//    if(!self.applicationContext) {
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
//    }
    isLoadingData = NO;
    if ([self imTheLoggedUser]) {
        self.navigationItem.title = NSLocalizedString(@"ChatProfile", nil);
    } else {
//        self.navigationItem.title = self.user.fullName;
        self.navigationItem.title = self.user.fullname;
    }
    defaultH = self.imageBckDw.frame.size.height;
    [self initImageCache];
    [self buildMenuWithRemovePhotoButton];
    [self initializeUI];
}

-(BOOL)imTheLoggedUser {
//    return [self.user.username isEqualToString:self.applicationContext.loggedUser.username];
//    NSLog(@"self.otherUser %@", self.otherUser.username);
    return !self.otherUser;
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"**** HomeProfileTVC.viewWillAppear. self.user = %@", self.user);
    ChatUser *loggedUser = [ChatManager getInstance].loggedUser;
    [super viewWillAppear:animated];
    if (!self.user && self.otherUser) {
        NSLog(@"SONO UN UTENTE OSPITE DI QUESTA PROFILE VIEW!!");
        self.user = self.otherUser;
        NSLog(@"self.otherUser.fullname: %@", self.otherUser.fullname);
        [self setProfileImage];
        [self completeProfile];
        [self setupUser];
    }
//    else if (self.user && ![self.user.username isEqualToString:self.applicationContext.loggedUser.username]) {
    else if (self.user && ![self.user.userId isEqualToString:loggedUser.userId]) {
        NSLog(@"Previusly logged with user: %@. Changing to user: %@", self.user.userId, loggedUser.userId);
//        self.user = self.applicationContext.loggedUser;
        self.user = loggedUser;
        [self setProfileImage];
        [self completeProfile];
        [self setupUser];
    }
    else if (!self.user && loggedUser) {
        NSLog(@"Just logged in...");
//        self.user = self.applicationContext.loggedUser;
        self.user = loggedUser;
        [self setProfileImage];
        [self completeProfile];
        [self setupUser];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.loaderUser.delegate = nil;
//    [self.loaderUser cancelConnection];
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self showWaiting:@"ciao..."];
//}

-(void)initImageCache {
//    // cache setup
//    self.imageCache = (ChatImageCache *) [self.applicationContext getVariable:@"chatUserIcons"];
//    if (!self.imageCache) {
//        self.imageCache = [[ChatImageCache alloc] init];
//        self.imageCache.cacheName = @"chatUserIcons";
//        // test
//        //        [self.imageCache listAllImagesFromDisk];
//        //        [self.imageCache empty];
//        [self.applicationContext setVariable:@"chatUserIcons" withValue:self.imageCache];
//    }
}

-(void)initializeUI {
    self.labelSettings.text = NSLocalizedString(@"ChatSettingsMenuOption", nil);
    self.labelHelp.text = NSLocalizedString(@"ChatHelpMenuOption", nil);
    self.labelLogout.text = NSLocalizedString(@"ChatLogoutMenuOption", nil);
    [self customizeImageProfile];
}

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

-(void)customizeImageProfile {
    [SHPImageUtil arroundImage:(self.imageViewProfile.frame.size.height/2) borderWidth:2.0 layer:[self.imageViewProfile layer]];
    UIColor *borderColor = [SHPImageUtil colorWithHexString:@"FFFFFF"];
    [[self.imageViewProfile layer] setBorderColor:[borderColor CGColor]];
    self.imageViewProfile.hidden = YES;
}

-(void)setProfileImage {
//    NSString *imageURL = [SHPUser photoUrlByUsername:self.user.username];
//    NSLog(@"LOADING PROFILE IMAGE %@", imageURL);
//    ChatImageWrapper *cached_image_wrap = (ChatImageWrapper *)[self.imageCache getImage:imageURL];
//    self.user_image = cached_image_wrap.image;
//    if(!cached_image_wrap) { // user_image == nil if image saving gone wrong!
//        NSLog(@"NOT CACHED IMAGE WRAP! LOADING IMAGE...");
//        [self loadImageProfile];
//        // if a download is deferred or in progress, return a placeholder image
        UIImage *avatar_image = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
        [self setProfilePhoto:avatar_image];
//    } else {
//        NSLog(@"CACHED IMAGE WRAP! SETTING UP.");
//        [self setProfilePhoto:self.user_image];
//        // update too old images
//        double now = [[NSDate alloc] init].timeIntervalSince1970;
//        double reload_timer_secs = 86400; // 86400 one day
//        if (now - cached_image_wrap.createdTime.timeIntervalSince1970 > reload_timer_secs) {
//            [self loadImageProfile];
//        }
//    }
}

-(void)setProfilePhoto:(UIImage *)image {
//    self.imageBckDw.image = image;
//    self.imageBckUp.image = [SHPImageUtil blur:image radius:14];
    self.imageBckDw.backgroundColor = [UIColor colorWithRed:0.09 green:0.38 blue:0.929 alpha:1.0];
    self.imageViewProfile.image = image;
    self.imageViewProfile.hidden = NO;
    self.imageViewProfile.alpha = 1.0;
}

-(void)changeProfilePhoto:(UIImage *)image {
    [self setProfilePhoto:image];
    
//    self.imageBckDw.image = image;
//    self.imageBckUp.image = [SHPImageUtil blur:image radius:14];
//    
//    if (!self.user_image) {
//        self.user_image = image;
//        self.imageBckDw.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageBckDw.alpha = 0.0;
//        self.imageBckUp.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageBckUp.alpha = 0.0;
//        [UIView animateWithDuration:1.0
//                         animations:^{
//                             self.imageBckUp.alpha = 1.0;
//                             self.imageViewProfile.image = image;
//                             self.imageViewProfile.alpha = 0.0;
//                             self.imageViewProfile.hidden = NO;
//                             self.imageViewProfile.alpha = 1.0;
//                         }
//                         completion:nil];
//    }
//    else {
//        self.user_image = image;
//        self.imageBckUp.alpha = 1.0;
//        self.imageViewProfile.image = image;
//        self.imageViewProfile.alpha = 1.0;
//        self.imageViewProfile.hidden = NO;
//        self.imageViewProfile.alpha = 1.0;
//    }
}

-(void)completeProfile {
//    NSLog(@"self.user: %@ - %@", self.user, self.user.photoUrl);
    self.labelUserNameComplete.text = self.user.fullname;
    NSLog(@"fullname: %@", self.user.fullname);
    self.labelUsername.text = self.user.userId;
    [self.tableView reloadData];
}

//-(void)configNavigationBar{
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.contentMode = UIViewContentModeScaleAspectFill;
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    defaultH = self.imageBckDw.frame.size.height;
//    //self.imageViewBckUP.image = [DC blur:self.imageViewBckUP.image radius:16];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//----------------------------------------------------------------//
//START SCROLL VIEW CONTROLLER
//----------------------------------------------------------------//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollView: %@",scrollView);
//    CGFloat scrollOffset = scrollView.contentOffset.y;
//    CGRect headerImageFrame = self.imageBckUp.frame;
   
//    self.imageViewProfile.alpha = 1+(scrollOffset)/120;
//    self.imageBckUp.alpha = 1+(scrollOffset)/120;
//    self.imageBckDw.alpha = -(scrollOffset)/100;
//    self.labelUsername.alpha = 1+(scrollOffset)/120;
//    self.labelUserNameComplete.alpha = 1+(scrollOffset)/120;
//    if (scrollOffset < 0) {
//        headerImageFrame.origin.y = (scrollOffset);
//        headerImageFrame.size.height = defaultH-(scrollOffset);
//    }
//    else{
//        if(scrollOffset==0){
//           self.imageViewProfile.hidden = NO;
//           self.imageViewProfile.alpha = 1;
//        }
//    }
//    self.imageBckDw.frame = headerImageFrame;
//    self.imageBckUp.frame = headerImageFrame;
}
//----------------------------------------------------------------//
//END SCROLL VIEW CONTROLLER
//----------------------------------------------------------------//


//--------------------------------------------------------------------//
//START DELEGATE self.loaderUser facebookConnect e facebookDisconnect
//--------------------------------------------------------------------//
-(void)setupUser {
//    self.loaderUser.delegate = nil;
//    [self.loaderUser cancelConnection];
//    
//    self.loaderUser = [[SHPUserDC alloc]init];
//    self.loaderUser.delegate = self;
//    
//    NSLog(@"self.loaderUser %@ delegate: %@", self.loaderUser, self.loaderUser.delegate);
//    [self.loaderUser findByUsername:self.user.username];
//    // profile image
//    if ([self imTheLoggedUser] && !self.tapRec) {
//        self.imageViewProfile.userInteractionEnabled = TRUE;
//        self.tapRec = [[UITapGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(didTapImage)];
//        self.tapRec.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
//        [self.imageViewProfile addGestureRecognizer:self.tapRec];
//    }
}

//DELEGATE
//--------------------------------------------------------------------//
-(void)usersDidLoad:(NSArray *)__users error:(NSError *)error
{
//    NSLog(@"usersDidLoad::: %@ - %@",__users, error);
//    SHPUser *tmp_user;
//    if(__users.count > 0) {
//        tmp_user = [__users objectAtIndex:0];
//        self.user = tmp_user;
//        [self completeProfile];
//    }
}
//---------------------------------------------------------------------//
//END DELEGATE self.loaderUser facebookConnect e facebookDisconnect
//---------------------------------------------------------------------//


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            break;
        }
        case 1:
        {
            NSLog(@"ESCI");
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            SHPAppDelegate *app = (SHPAppDelegate *) [[UIApplication sharedApplication] delegate];
            SHPApplicationContext *context = app.applicationContext;
            [context signout];
            
            //START LOGOUT CHAT
            ChatManager *chat = [ChatManager getInstance];
            [chat dispose];
            //END LOGOUT CHAT
            
            //signout firebase
            NSError *signOutError;
            BOOL status = [[FIRAuth auth] signOut:&signOutError];
            NSLog(@"logut status %d", status);
            if (!status) {
                NSLog(@"Error signing out from Firebase: %@", signOutError);
            }
            else {
                NSLog(@"Successfully signed out from Firebase");
            }
            
            [self toConversationsTab];
        }
    }
}

-(void)toConversationsTab {
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController"];
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        [nc popToRootViewControllerAnimated:NO];
        tabController.selectedIndex = chat_tab_index;
    }
}
//-(void)agganciaSganciaFacebook
//{
//    NSLog(@"agganciaSganciaFacebook - self.applicationContext.loggedUser.facebookAccessToken::: %@",self.applicationContext.loggedUser.facebookAccessToken);
//    if(self.applicationContext.loggedUser.facebookAccessToken){
//        //sgancia
//        [self showWaiting:NSLocalizedString(@"operazione in corso...", nil)];
//        [self.loaderUser facebookDisconnect:self.applicationContext.loggedUser];
//    }else{
//        //aggancia
//        [self showWaiting:NSLocalizedString(@"operazione in corso...", nil)];
//        [self.loaderUser facebookConnect:self.applicationContext.loggedUser];
//    }
//}

-(void)showWaiting:(NSString *)label {
    NSLog(@"Preparing hud with label %@...", label);
    if (!self.hud) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        self.hud = [[MBProgressHUD alloc] initWithWindow:window];
        NSLog(@"hud ok hud: %@ on window: %@", self.hud, window);
        [self.view.window addSubview:self.hud];
    }
//    hud.alpha = 1;
    self.hud.center = self.view.center;
    self.hud.labelText = label;
    self.hud.animationType = MBProgressHUDAnimationZoom;
    [self.hud show:YES];
}

-(void)hideWaiting {
    NSLog(@"hud hiding...");
    [self.hud hide:YES];
}

-(void)sendMessage {
    
    UIViewController *backVC = [self backViewController];
    
    NSLog(@">>>>>> Back VC Class: %@", NSStringFromClass(backVC.class));
    if([backVC isKindOfClass:[ChatMessagesVC class]]) {
        NSLog(@"IS MESSAGES!!!!");
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else {
        NSLog(@"NOT MESSAGES");
    }
    
    [ChatUtil moveToConversationViewWithUser:self.user];
    
}

//-------------------------------------------------------------------//
//END FUNCTION
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
//START FUNCTION LOAD IMAGE
//-------------------------------------------------------------------//
-(void)loadImageProfile
{
//    NSLog(@"loadImageProfile %@", self.user.photoUrl);
//    SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
//     __weak SHPHomeProfileTVC *weakSelf = self;
//    [imageRquest downloadImage:weakSelf.user.photoUrl
//             completionHandler:
//     ^(UIImage *image, NSString *imageURL, NSError *error) {
//         if (image) {
//             //[self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
//             [weakSelf.imageCache addImage:image withKey:imageURL];
//             
//             [weakSelf changeProfilePhoto:image];
//         } else {
//             // optionally put an image that indicates an error
//         }
//     }];
}

//-------------------------------------------------------------------//
//END FUNCTION LOAD IMAGE
//-------------------------------------------------------------------//

//----------------------------------------------------------------//
//START BUILD TABLEVIEW
//----------------------------------------------------------------//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    //NSLog(@"=== : %@ - %@",self.applicationContext.loggedUser.username, self.user.username);
    
    
    if([identifierCell isEqualToString:@"idCellChat"]){
        if([self imTheLoggedUser]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellSettings"]){
        if (![self imTheLoggedUser]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellHelp"]){
        if (![self imTheLoggedUser]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellLogout"]){
        if (![self imTheLoggedUser]){
            return 0.0;
        }
    }
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    
    if([theString isEqualToString:@"idCellSettings"]){
        //        listMode = @"LIKED";
        //        rowSelected =  self.labelPiaciuti.text;
        //        listProducts = listProductsLiked;
        [self performSegueWithIdentifier:@"Settings" sender:self];
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
//        ChatSettingsTVC *settingsVC = [sb instantiateViewControllerWithIdentifier:@"ChatSettings"];
//        [self.navigationController pushViewController:settingsVC animated:YES];
    }
//    else if([theString isEqualToString:@"idCellCreated"]){
//        listMode = @"CREATED";
//        rowSelected =  self.labelCreati.text;
//        listProducts = listProductsCreated;
//        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
//    }
//    else if([theString isEqualToString:@"idCellLiked"]){
//        listMode = @"LIKED";
//        rowSelected =  self.labelPiaciuti.text;
//        listProducts = listProductsLiked;
//        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
//    }
//    else if([theString isEqualToString:@"idCellFacebook"]){
//        //[self agganciaSganciaFacebook];
//    }
    else if([theString isEqualToString:@"idCellChat"]) {
        [self sendMessage];
    }
    else if([theString isEqualToString:@"idCellHelp"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"MainStoryboard" bundle:[NSBundle mainBundle]];
        SHPMiniWebBrowserVC *browserVC = [storyboard instantiateViewControllerWithIdentifier:@"MiniWebBrowser"];
//        browserVC.applicationContext = self.applicationContext;
        browserVC.hiddenToolBar = YES;
        browserVC.titlePage = NSLocalizedString(@"ChatHelpMenuOption", nil);
        browserVC.urlPage = @"http://www.labot.org/support";
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else if([theString isEqualToString:@"idCellLogout"]) {
        NSLog(@"LOGOUT");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ChatSignoutAlert", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ChatCancel", nil) otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Settings"]) {
        ChatSettingsTVC *vc = (ChatSettingsTVC *)[segue destinationViewController];
//        vc.applicationContext = self.applicationContext;
    }
}

//----------------------------------------------------------------//
//END BUILD TABLEVIEW
//----------------------------------------------------------------//



// -----------------------------
// **** USER PHOTO MENU ****
// -----------------------------

-(void)didTapImage {
    NSLog(@"tapped");
    [self.takePhotoMenu showInView:self.view];
}

-(void)resetUserPhoto {
    self.userImage = nil;
//    self.userImageView.image = [UIImage imageNamed:@"no-profile"];
    [self setProfilePhoto:[UIImage imageNamed:@"avatar"]];
    [self buildMenuWithoutRemovePhotoButton];
}

-(void)buildMenuWithRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemoveProfilePhotoLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)buildMenuWithoutRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.takePhotoMenu) {
        NSLog(@"Alert Button!");
        NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([option isEqualToString:NSLocalizedString(@"TakePhotoLKey", nil)]) {
            NSLog(@"Take Photo");
            [self takePhoto];
        }
        else if ([option isEqualToString:NSLocalizedString(@"PhotoFromGalleryLKey", nil)]) {
            NSLog(@"Choose from Gallery");
            [self chooseExisting];
        }
        else if ([option isEqualToString:NSLocalizedString(@"RemoveProfilePhotoLKey", nil)]) {
            NSLog(@"RemoveProfilePhoto");
            [self removeUserPhoto];
        }
    }
}


// CAMERA ...

// TAKE PHOTO SECTION

- (void)takePhoto {
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)chooseExisting {
    //    NSLog(@"choose existing...");
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // enable to crop
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // enable to crop
    self.photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
//        self.backupUserImage = self.userImageView.image;
        self.backupUserImage = self.imageViewProfile.image;
        self.userImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // enable to crop
        self.userImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if (!self.userImage) {
            UIImage *photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            CGSize size = CGSizeMake(180, 180); // using facebook type=large image size.
            self.userImage = [SHPImageUtil scaleImage:photo toSize:size];
            //        self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        }
        
        [self sendUserPhoto];
        
        // adds the remove photo option to the menu.
        [self buildMenuWithRemovePhotoButton];
    }];
    
//    self.backupUserImage = self.userImageView.image;
//    self.userImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    
//    // enable to crop
//    self.userImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    if (!self.userImage) {
//        UIImage *photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//        CGSize size = CGSizeMake(180, 180); // using facebook type=large image size.
//        self.userImage = [SHPImageUtil scaleImage:photo toSize:size];
//        //        self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    }
//    self.userImageView.image = self.userImage;
//    
//    [self sendUserPhoto];
//    
//    // adds the remove photo option to the menu.
//    [self buildMenuWithRemovePhotoButton];
    // end
}

-(void)removeUserPhoto {
    self.userImage = nil;
//    self.userImageView.image = [UIImage imageNamed:@"no-profile"];
    [self setProfilePhoto:[UIImage imageNamed:@"avatar"]];
//    self.backupUserImage = self.applicationContext.loggedUser.photoImage;
    // service to remove user-photo?
    [self sendUserPhoto];
}

// -----------------------------
// **** USER PHOTO MENU END ****
// -----------------------------

// -------------------------------------
// ******* UPLOAD PHOTO SECTION ********
// -------------------------------------

-(void)sendUserPhoto {
//    [self showWaiting:NSLocalizedString(@"Saving", nil)];
//    
//    NSString *actionUrl = [SHPServiceUtil serviceUrl:@"service.uploaduserphoto"];
//    NSLog(@"Change user photo. Action url: %@", actionUrl);
//    
//    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
//    NSString *randomString = [SHPStringUtil randomString:16];
//    //    NSLog(@"randomString: -%@-", randomString);
//    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
//    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
//    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
//    
//    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.userImage];
//    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
//    
//    UIImage *scaledImage = [SHPImageUtil scaleImage:imageEXIFAdjusted toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
//    NSLog(@"SCALED IMAGE w:%f h:%f", scaledImage.size.width, scaledImage.size.height);
//    
//    //    NSLog(@"IMAGE DATA::::::::::::::::::::::::::::::::::::::::::::::::::: %@", imageData);
//    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
//    //    NSLog(@"POST DATA:::::: %@", postData);
//    
//    
//    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo_file\"; filename=\"photofile.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:imageData];
//    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    
//    [theRequest setHTTPMethod:@"POST"];
//    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
//    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
//    NSString * dataLength = [NSString stringWithFormat:@"%lu", [postData length]];
//    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
//    [theRequest setHTTPBody:(NSData*)postData];
//    
//    // auth
//    SHPUser *__user = self.applicationContext.loggedUser;
//    NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
//    [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
//    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    self.currentConnection = conn;
//    if (conn) {
//        self.receivedData = [NSMutableData data];
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    } else {
//        NSLog(@"Could not connect to the network");
//    }
}

-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

- (void)cancelConnection {
    //    NSLog(@"Canceling %@ service for Product %@ (%@)...", self.serviceName, self.product.oid, product.longDescription);
    [self.currentConnection cancel];
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.currentConnection = nil;
}


// CONNECTION DELEGATE


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    //    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //    for (NSString *key in headers) {
    //        NSLog(@"field: %@ value: %@", key, [headers objectForKey:key]);
    //    }
    long code = [(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    [self hideWaiting];
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    if (self.backupUserImage) {
        NSLog(@"BACKUPPING OLD USER IMAGE");
        self.userImage = self.backupUserImage;
        [self setProfilePhoto:self.userImage];
//        self.userImageView.image = self.userImage;
    } else {
        self.userImage = nil;
        [self setProfilePhoto:[UIImage imageNamed:@"avatar"]];
//        self.userImageView.image = [UIImage imageNamed:@"no-profile"];
    }
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@ %ld",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
          error.code);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // show alert!
    NSString *title = NSLocalizedString(@"NetworkErrorTitle", nil);
    NSString *msg = NSLocalizedString(@"NetworkError", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self hideWaiting];
//    
//    // the json charset encoding
//    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
//    NSLog(@"Response: %@", responseString);
//    
//    [self.imageCache addImage:self.userImage withKey:self.user.photoUrl];
//    [self changeProfilePhoto:self.userImage];
}

- (NSString *)httpBase64FromJson:(NSData *)jsonData {
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    NSString *basicAuth64 = [objects valueForKey:@"basicAuth"];
    return basicAuth64;
}

//-(void)showWaiting:(NSString *)msg {
//    NSLog(@"SHOW WAITING...");
//    if (!self.hud) {
//        NSLog(@"VIEW.................... %@", self.view);
//        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//        [self.navigationController.view addSubview:self.hud];
//    }
//    //    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"first.png"]];
//    //    hud.mode = MBProgressHUDModeCustomView;
//    self.hud.center = self.view.center;
//    self.hud.labelText = msg;
//    self.hud.animationType = MBProgressHUDAnimationZoom;
//    [self.hud show:YES];
//    //    self.navigationItem.backBarButtonItem.enabled = NO;
//    NSLog(@"END.");
//}
//
//-(void)hideWaiting {
//    [self.hud hide:YES];
//    //    self.navigationItem.backBarButtonItem.enabled = YES;
//}

// --------------------------------------
// ******** SEND USER PHOTO END *********
// --------------------------------------

-(void)dealloc {
    NSLog(@"SHPHomeProfileTVC DEALLOCATED.");
    //[self.verify setDelegate:nil];
}

@end
