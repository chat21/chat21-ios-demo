//
//  CZSignInEmailVC.h
//  AboutMe
//
//  Created by Dario De pascalis on 29/03/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>


//@protocol CZSigninEmailDelegate
//-(void)animationMessageError:(NSString *)msg;
//-(void)showWaiting:(NSString *)label;
//-(void)hideWaiting;
//@end

@interface CZSignInEmailVC : UIViewController <UITextFieldDelegate>{
    NSString *errorMessage;
    UIView *viewError;
    UILabel *labelError;
}

//@property (nonatomic, assign) id <CZSigninEmailDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UIButton *buttonNext;

- (IBAction)actionNext:(id)sender;

@end
