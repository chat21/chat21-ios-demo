//
//  CZAuthenticationDC.h
//  AboutMe
//
//  Created by Dario De pascalis on 11/04/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import <Parse/Parse.h>
#import "SHPAuthServiceDC.h"

@class SHPApplicationContext;

extern NSString *NAME_IMAGE_PROFILE;
extern NSString *KEY_IMAGE_PROFILE;
extern int MIN_CHARS_USERNAME;
extern int MIN_CHARS_PASSWORD;
extern int MIN_CHARS_NAMECOMPLETE;

@protocol CZAuthenticationDelegate
//- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress;
- (void)refreshImage:(NSData *)fileData name:(NSString*)name;
- (void)animationMessageError:(NSString *)errorMessage;
- (void)performSegueWithIdentifier:(NSDictionary *)my;
- (void)dismissViewControllerAnimated;
- (void)hideWaiting;
@end


@interface CZAuthenticationDC : NSObject <SHPAuthServiceDCDelegate>{
    NSURLConnection *currentConnection;
    NSMutableData *receivedData;
    NSInteger statusCode;
}

@property (nonatomic, assign) id <CZAuthenticationDelegate> delegate;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPAuthServiceDC *authDC;

@property (strong, nonatomic) NSString *fbUserEmail;
@property (strong, nonatomic) NSString *fbNameComplete;
@property (strong, nonatomic) NSString *fbUserId;
@property (strong, nonatomic) NSString *fbUsername;
@property (strong, nonatomic) NSString *fbPictureUrl;
@property (strong, nonatomic) UIImage *fbProfileImage;
@property (strong, nonatomic) NSString *fbAccessToken;
@property (strong, nonatomic) NSString *fbPassword;


//-(void)facebookLoginParse;
-(void)facebookLogin;
//+(void)saveSessionToken;
+(void)deleteSessionToken;
//-(void)checkAutenticate;

-(void)loadImageFromUrl:(NSString *)imageURL;
//-(void)loadImage:(PFFile *)imageFile;
//-(void)saveImage:(NSData *)imageData classParse:(PFObject *)classe;
-(void)saveImageWithoutDelegate:(UIImage *)image nameImage:(NSString *)nameImage key:(NSString *)key;
-(void)animationAlpha:(UIView *)viewAnimated;

+(void)arroundImage:(float)borderRadius borderWidth:(float)borderWidth layer:(CALayer *)layer;
+(UIColor *)colorWithHexString:(NSString *)colorString;
+(void)setTrasparentBackground:(UINavigationController *)navigationController;
+(void)setAlphaBackground:(UINavigationController *)navigationController bckColor:(UIColor *)bckColor alpha:(CGFloat)alpha;

- (UIImage *)blur:(UIImage*)theImage radius:(CGFloat)radius;
//http://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view

-(void)sendRegistrationWithFormData:(UIImage *)imageProfile textNameComplete:(NSString *)textNameComplete textUsername:(NSString*)textUsername textEmail:(NSString*)textEmail textPassword:(NSString*)textPassword;
@end
