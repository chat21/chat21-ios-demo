//
//  CZAuthenticationDC.m
//  AboutMe
//
//  Created by Dario De pascalis on 11/04/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "CZAuthenticationDC.h"
//#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "SHPSendTokenDC.h"
#import "SHPAppDelegate.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import <FirebaseStorage/FirebaseStorage.h>

NSString *NAME_IMAGE_PROFILE = @"imageProfile.png";
NSString *KEY_IMAGE_PROFILE = @"image";
int MIN_CHARS_USERNAME = 6;
int MIN_CHARS_PASSWORD = 8;
int MIN_CHARS_NAMECOMPLETE = 2;

@implementation CZAuthenticationDC


-(void)loadImageFromUrlDispatch_async:(NSString *)imageURL {
    NSURL *url = [NSURL URLWithString:imageURL];
    NSLog(@"loadImageFromUrl: %@", url);
//    NSData *data = [FTWCache objectForKey:key];
//    //NSData *data = [FTWCache objectForKey:imageURL];
//    if (imageData) {
//        //UIImage *image = [UIImage imageWithData:data];
//        [self.delegate refreshImage:imageData name:imageURL];
//    } else {
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//        dispatch_async(queue, ^{
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
             NSLog(@"loadImageFromUrl: %@", imageData);
            //[FTWCache setObject:data forKey:imageURL];
            //UIImage *image = [UIImage imageWithData:data];
            [self.delegate refreshImage:imageData name:@"imageCover"];
        });
    //}
}


-(void)loadImageFromUrl:(NSString *)imageURL {
    NSURL *url = [NSURL URLWithString:imageURL];
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       NSData *imageData = [NSData dataWithContentsOfURL:location];
                                                        //NSLog(@"loadImageFromUrl: %@", imageData);
                                                       [self.delegate refreshImage:imageData name:@"imageCover"];
                                                   }];
    [downloadPhotoTask resume];
}
//----------- END LOAD IMAGE ---------------//

//-(void)loadImage:(PFFile *)imageFile
//{
//    NSLog(@"loadImage: %@", imageFile.name);
//    [imageFile getDataInBackgroundWithBlock:^(NSData *fileData, NSError *error) {
//        if (!error) {
//            //PFFile *image = [PFFile fileWithName:@"image Profile" data:fileData];
//            [self.delegate refreshImage:fileData name:imageFile.name];
//        }
//        else {
//            NSLog(@"error load image: %@", error);
//        }
//    } progressBlock:^(int percentDone) {
//        float progress=percentDone/100;
//        NSLog(@"progress %f", progress);
//        [self.delegate setProgressBar:nil progress:progress];
//    }];
//}

//-(void)saveImage:(NSData *)imageData classParse:(PFObject *)classe
//{
//    PFFile *image = [PFFile fileWithName:@"imageProfile" data:imageData];
//    [[PFUser currentUser] setObject:image forKey:@"imageProfile"];
//    [[PFUser currentUser] saveInBackground];
//}


-(void)saveImageWithoutDelegate:(UIImage *)image nameImage:(NSString *)nameImage key:(NSString *)key {
//    NSLog(@"saveImageWithoutDelegate %@ - %@", nameImage, key);
//    NSData *imageData = UIImagePNGRepresentation(image);
//    // Get a reference to the storage service using the default Firebase App
//    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
//    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
//    NSString * imagePath = [NSString stringWithFormat:@"%@/%@/photo.png", app.tenant, app.loggedUser.username];
//    FIRStorageReference *imageRef = [storageRef child:imagePath];
//    FIRStorageUploadTask *uploadTask = [imageRef putData:imageData
//                                                 metadata:nil
//                                               completion:^(FIRStorageMetadata *metadata,
//                                                            NSError *error) {
//                                                   if (error != nil) {
//                                                       NSLog(@"Uh-oh, an error occurred! %@", error);
//                                                   } else {
//                                                       // Metadata contains file metadata such as size, content-type, and download URL.
//                                                       NSURL *downloadURL = metadata.downloadURL;
//                                                       NSLog(@"download url: %@", downloadURL);
//                                                   }
//                                               }];
    
    // OLD PARSE
//    PFFile *imageFile = [PFFile fileWithName:nameImage data:imageData];
//    [[PFUser currentUser] setObject:imageFile forKey:key];
//    [[PFUser currentUser] saveInBackground];
}


-(void)animationAlpha:(UIView *)viewAnimated{
    NSLog(@"animationAlphaSTART: %f",viewAnimated.alpha);
    viewAnimated.alpha = 0.0;
    [UIView animateWithDuration:1.5
                     animations:^{
                         viewAnimated.alpha = 1.0;
                         NSLog(@"animationAlphaEND: %f",viewAnimated.alpha);
                     }
                     completion:^(BOOL finished){
                     }];
}


+(void)arroundImage:(float)borderRadius borderWidth:(float)borderWidth layer:(CALayer *)layer
{
    CALayer * l = layer;
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor lightGrayColor].CGColor];
    [l setBorderWidth:borderWidth];
    [l setCornerRadius:borderRadius];
}

+ (UIColor *)colorWithHexString:(NSString *)colorString
{
    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (colorString.length == 3)
        colorString = [NSString stringWithFormat:@"%c%c%c%c%c%c",
                       [colorString characterAtIndex:0], [colorString characterAtIndex:0],
                       [colorString characterAtIndex:1], [colorString characterAtIndex:1],
                       [colorString characterAtIndex:2], [colorString characterAtIndex:2]];
    if (colorString.length == 6)
    {
        int r, g, b;
        sscanf([colorString UTF8String], "%2x%2x%2x", &r, &g, &b);
        return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    }
    return nil;
}

+(void)setTrasparentBackground:(UINavigationController *)navigationController
{
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = YES;
}

+(void)setAlphaBackground:(UINavigationController *)navigationController bckColor:(UIColor *)bckColor alpha:(CGFloat)alpha
{
    navigationController.navigationBar.tintColor = bckColor;
    navigationController.navigationBar.alpha = alpha;
    navigationController.navigationBar.translucent = YES;
}

- (UIImage *)blur:(UIImage*)theImage radius:(CGFloat)radius
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    if(!radius){
        radius = 15.0f;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}


//--------------------------------------------------------------------//
//START FACEBOOK LOGIN PARSE
//--------------------------------------------------------------------//
/*
- (void)facebookLoginParse {
    NSLog(@"facebookLogin -------------------------------");
    NSArray *permissionsArray = @[@"email", @"user_friends",@"public_profile"];//@"public_profile", @"email", @"user_friends"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        NSLog(@"facebookLogin -------------------------------%@ - %@", user, error);
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            NSString *errorMessage = nil;
            
            if (!error) {
                errorMessage = NSLocalizedStringFromTable(@"FacebookLoginCancellato", @"CZ-AuthenticationLocalizable", @"");
            } else {
                errorMessage =  [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"FacebookConnectionError", @"CZ-AuthenticationLocalizable", @"")];
                //[error localizedDescription];
            }
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:errorMessage];
        } else {
            NSLog(@"User now has publish permissions!");
            if (user.isNew) {
                 NSLog(@"user.isNew %d", user.isNew);
                //[self performSegueWithIdentifier:@"toSignInUser" sender:self];
                [self.delegate performSegueWithIdentifier];
            } else {
                NSLog(@"NO user.isNew %d", user.isNew);
                //[self saveSessionToken];
                //[self.delegate dismissViewControllerAnimated:YES completion:^{
                //}];
                [self.delegate dismissViewControllerAnimated];
            }
        }
    }];
}
 */
//--------------------------------------------------------------------//
//END FACEBOOK LOGIN PARSE
//--------------------------------------------------------------------//



//--------------------------------------------------------------------//
//START FACEBOOK LOGIN
//--------------------------------------------------------------------//

 -(void)facebookLogin{
    NSLog(@"opening facebook session...");
    __weak CZAuthenticationDC *weakSelf = self;
    [FBSession openActiveSessionWithReadPermissions:
     [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", nil]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      if (error) {
                                          NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                          NSString *errorMessage = nil;
                                          
                                          if (!error) {
                                              errorMessage = NSLocalizedStringFromTable(@"FacebookLoginCancellato", @"CZ-AuthenticationLocalizable", @"");
                                          } else {
                                              errorMessage =  [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"FacebookConnectionError", @"CZ-AuthenticationLocalizable", @"")];
                                          }
                                          [self.delegate hideWaiting];
                                          [self.delegate animationMessageError:errorMessage];
                                      } else {
                                          NSLog(@"User now has publish permissions!");
                                          [weakSelf sessionStateChanged:session state:state error:error];
                                      }
                                 }];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    NSString *errorFacebook;
    NSLog(@"----------------sessionStateChanged------------>: %@", errorFacebook);
    switch (state) {
        case FBSessionStateOpen: {
                NSLog(@"facebookAccessToken ---------------------------->: %@", session.accessTokenData);
                self.fbAccessToken = session.accessTokenData.accessToken;
                SHPUser *fbUser = [[SHPUser alloc] init];
                fbUser.facebookAccessToken = self.fbAccessToken;
                self.authDC = [[SHPAuthServiceDC alloc] init];
                self.authDC.authServiceDelegate = self;
                [self.authDC findFacebookUser:fbUser];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    if (error) {
        NSLog(@"Alerting the error with a popup... %@", error);
        [self.delegate hideWaiting];
        NSString *errorFacebook =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"FacebookConnectionError", nil), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
        [self.delegate animationMessageError:errorFacebook];
    }
}


// DELEGATE from: self.authDC findFacebookUser
-(void)authServiceDCFacebookUser:(SHPUser *)user found:(BOOL)found {
    if (found) {
        NSLog(@"User found...USER : %@ ",user);
        [self prepareSignedUser:user];
        //[self requestUserDataForRegistration];
    } else {
        NSLog(@"User not found...request user data > register...USER : %@ ",user.photoUrl);
        [self requestUserDataForRegistration];
    }
}

-(void)prepareSignedUser:(SHPUser *)user {
    NSLog(@"\n\n ********* prepareSignedUser. %@ - %@",self.applicationContext, user.httpBase64Auth);
    [self.applicationContext signin:user];
    // start notifications
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate startPushNotifications];
    // end
    [self.delegate hideWaiting];
    [self.delegate dismissViewControllerAnimated];
}

//-(void)savePassword:(NSString *)password {
//    NSLog(@"*************** SAVE PASSWORD: %@ ***************",password);
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    [userPreferences setObject:password forKey:@"PASSWORD"];
//    [userPreferences synchronize];
//}

-(void)authServiceDCErrorWithCode:(NSString *)code{
    NSLog(@"authServiceDCErrorWithCode : %@ ",code);
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


-(void)requestUserDataForRegistration {
    NSString *requestPath = @"me/?fields=name,id,email,location,picture";
    FBRequest *me = [FBRequest requestForGraphPath:requestPath];
    [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                      NSDictionary<FBGraphUser> *my,
                                      NSError *error) {
        if (!error) {
            NSLog(@"User data retriving successfull: %@", my);
            [self.delegate performSegueWithIdentifier:my];
            //[self performSegueWithIdentifier:@"toSignInUser" sender:self];
        } else {
            NSString *errorFacebook =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"A Request Error occurred:", nil), error];
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:errorFacebook];
        }
    }];
}

//--------------------------------------------------------------------//
//END FACEBOOK LOGIN
//--------------------------------------------------------------------//

//--------------------------------------------------------------------//
//START SESSION
//--------------------------------------------------------------------//
//+(void)saveSessionToken{
//    NSLog(@"saveSessionToken");
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *sessionToken = [PFUser currentUser].sessionToken;
//    [defaults setObject:sessionToken forKey:@"sessionToken"];
//    [defaults synchronize];
//}

+(void)deleteSessionToken{
    NSLog(@"deleteSessionToken");
//    [PFUser enableRevocableSessionInBackground];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionToken"];
//    [defaults synchronize];
}

//- (void)checkAutenticate{
//    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionToken"];
//    NSLog(@"initialize current user ----> : %@", sessionToken);
//    if (!sessionToken) {
//        NSLog(@"toLogin %@",self);
//        if([PFUser currentUser]){
//            //[self showWaiting:nil];
//            [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                [PFUser logOut];
//                //[self dismissViewControllerAnimated:YES completion:nil];
//            }];
//        }else{
//            //[self hideWaiting];
//            //[self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }else{
//        // [self hideWaiting];
//        //[self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

//--------------------------------------------------------------------//
//END SESSION
//--------------------------------------------------------------------//

//-----------------------------------------------------------//
//START REGISTRATION FORM DATA
//-----------------------------------------------------------//


-(void)sendUserPhoto:(UIImage *)imageProfile {
    //[self showWaiting:@"Sto salvando..."];
    
    NSString *actionUrl = [SHPServiceUtil serviceUrl:@"service.uploaduserphoto"];
    NSLog(@"Change user photo. Action url: %@", actionUrl);
    
    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    //    NSLog(@"randomString: -%@-", randomString);
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:imageProfile];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    
    UIImage *scaledImage = [SHPImageUtil scaleImage:imageEXIFAdjusted toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", scaledImage.size.width, scaledImage.size.height);
    
    //    NSLog(@"IMAGE DATA::::::::::::::::::::::::::::::::::::::::::::::::::: %@", imageData);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    //    NSLog(@"POST DATA:::::: %@", postData);
    
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo_file\"; filename=\"photofile.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%lu", [postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    // auth
    SHPUser *__user = self.applicationContext.loggedUser;
    NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", __user.httpBase64Auth];
    [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    currentConnection = conn;
    if (conn) {
        receivedData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"Could not connect to the network");
    }
}

-(void)sendRegistrationWithFormData:(UIImage *)imageProfile textNameComplete:(NSString *)textNameComplete textUsername:(NSString*)textUsername textEmail:(NSString*)textEmail textPassword:(NSString*)textPassword{
    NSString *actionUrl = [SHPServiceUtil serviceUrl:@"service.signupwithphoto"];
    NSLog(@"/n Signup with photo. Action url: APPLICATION CONTEXT:: %@ - %@", self.applicationContext, actionUrl);
    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    //NSLog(@"randomString: -%@-", randomString);
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:imageProfile];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
//    NSLog(@"IMAGE DATA::::::::::::::::::::::::::::::::::::::::::::::::::: %@", imageData);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    NSLog(@"POST DATA:::::: %@", postData);
    
    NSString *fullNameString = [self stringParameter:@"fullName" withValue:textNameComplete];
    NSString *usernameString = [self stringParameter:@"username" withValue:textUsername];
    NSString *emailString = [self stringParameter:@"email" withValue:textEmail];
    NSString *passwordString;
    if(textPassword){
        passwordString = [self stringParameter:@"password" withValue:textPassword];
    }else{
        passwordString = [self stringParameter:@"password" withValue:@""];
    }
    NSString *facebookTokenString;
    if (self.fbAccessToken) {
        facebookTokenString= [self stringParameter:@"facebookToken" withValue:self.fbAccessToken];
    } else {
        facebookTokenString = [self stringParameter:@"facebookToken" withValue:@""];
    }
    
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[fullNameString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[usernameString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[emailString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[passwordString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[facebookTokenString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photofile\"; filename=\"photofile.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    currentConnection = conn;
    if (conn) {
        receivedData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"Could not connect to the network");
    }
}


-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

- (void)cancelConnection {
    [currentConnection cancel];
    currentConnection = nil;
}

// CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    statusCode = code;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    receivedData = nil;
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@ %d",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
          (int)error.code);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *msg = NSLocalizedString(@"NetworkError", nil);
    [self.delegate hideWaiting];
    [self.delegate animationMessageError:msg];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"\n\n ************ connectionDidFinishLoading %d", (int)statusCode);
    if (statusCode < 400) {
//        [self savePassword:self.fbPassword];
        SHPUser *justRegisteredUser = [[SHPUser alloc] init];
        justRegisteredUser.username = self.fbUsername;
        justRegisteredUser.fullName = self.fbNameComplete;
        justRegisteredUser.httpBase64Auth = [self httpBase64FromJson:receivedData];
        [self registered:justRegisteredUser];
    } else {
        NSLog(@"HTTP Error %d", (int)statusCode);
        if (statusCode == ERROR_HTTP_USERNAME_USED) {
            NSString *msg = NSLocalizedString(@"UsernameAlreadyUsedLKey", nil);
            //self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:msg];
        } else if (statusCode == ERROR_HTTP_EMAIL_USED) {
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"EmailAlreadyUsedLKey", nil);
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:msg];
        } else if (statusCode == ERROR_HTTP_USERNAME_INVALID) {
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"UsernameInvalidLKey", nil);
            //self.imageUsername.image = [UIImage imageNamed:@"real_name_red"];
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:msg];
        } else {
            NSLog(@"Unknown error!");
            //NSString *title = NSLocalizedString(@"RegistrationErrorTitleLKey", nil);
            NSString *msg = NSLocalizedString(@"UnknownRegistrationErrorLKey", nil);
            //currentValidationError = @"unknown";
            [self.delegate hideWaiting];
            [self.delegate animationMessageError:msg];
        }
    }
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


-(void)registered:(SHPUser *)justRegisteredUser {
    NSLog(@"\n\n\n +++++++++++++++++++ Registration successfull! %@", justRegisteredUser);
    [self prepareSignedUser:justRegisteredUser];
}

//-----------------------------------------------------------//
//END REGISTRATION FORM DATA
//-----------------------------------------------------------//

@end
