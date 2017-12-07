//
//  SHPModifyProfileTVC.m
//  Mercatino
//
//  Created by Dario De Pascalis on 26/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPModifyProfileTVC.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPHomeProfileTVC.h"
#import "SHPSigninServiceDC.h"

//int MIN_CHARS_PASSWORD = 6;

@interface SHPModifyProfileTVC ()

@end

@implementation SHPModifyProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = self.applicationContext.loggedUser;
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"did appear %@ basic", self.modifyType);
    if ([self.modifyType isEqualToString:@"fullName"]) {
        [self.textFullName becomeFirstResponder];
    }
    else if ([self.modifyType isEqualToString:@"password"]) {
        [self.textPasswordOld becomeFirstResponder];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.textFullName.text = self.user.fullName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize
{
    NSString *headerMessage = [[NSString alloc] init];
    if([self.modifyType isEqualToString:@"fullName"]){
        headerMessage =  NSLocalizedString(@"PROFILE-modify name header", nil);
        self.textFullName.placeholder = self.user.fullName;
    }
    else{
        headerMessage =  NSLocalizedString(@"PROFILE-modify password header", nil);
    }
    self.labelHeaderMessage.text =  headerMessage;
    
    // name
    self.textFullName.placeholder = NSLocalizedString(@"PROFILE-fullname new", nil);
    [self.buttonSaveName setTitle:NSLocalizedString(@"PROFILE-fullname save", nil) forState:UIControlStateNormal];
    // passoword
    self.textPasswordOld.placeholder = NSLocalizedString(@"PROFILE-password current", nil);
    self.textPasswordNew.placeholder = NSLocalizedString(@"PROFILE-password new", nil);
    self.textPasswordNewConfirm.placeholder = NSLocalizedString(@"PROFILE-password confirm", nil);
    [self.buttonSavePassword setTitle:NSLocalizedString(@"PROFILE-password save", nil) forState:UIControlStateNormal];
}

-(void)updated {
    NSLog(@"unwinding...");
    [self performSegueWithIdentifier:@"unwindToChatSettingsTVC" sender:self];
}

//----------------------------------------------------------------//
//START FUNCTION VIEW
//----------------------------------------------------------------//
//-(void)savePassword:(NSString *)password {
//    NSLog(@"*************** SAVE PASSWORD: %@ ***************",password);
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    [userPreferences setObject:password forKey:@"PASSWORD"];
//    [userPreferences synchronize];
//}

-(void)showAlertMessageError:(NSString *)title msg:(NSString *)msg{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


-(void)showWaiting:(NSString *)label {
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:hud];
    }
    hud.center = self.view.center;
    hud.labelText = label;
    hud.animationType = MBProgressHUDAnimationZoom;
    [hud show:YES];
}

-(void)hideWaiting {
    [hud hide:YES];
}
//----------------------------------------------------------------//
//END FUNCTION VIEW
//----------------------------------------------------------------//

// -------------------------------------
// ******* UPLOAD USER SECTION ********
// -------------------------------------
-(void)sendUpdate
{
    [self showWaiting:@"Sto salvando..."];
    NSString *boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString *boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    NSMutableData *postData = [[NSMutableData alloc] init];
    NSString *actionUrl;
    if([self.modifyType isEqualToString:@"fullName"]){
        actionUrl = [SHPServiceUtil serviceUrl:@"service.uploaduser"];
        NSString *fullNameParam = [self stringParameter:@"fullName" withValue:self.textFullName.text];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[fullNameParam dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if([self.modifyType isEqualToString:@"password"]){
        actionUrl = [SHPServiceUtil serviceUrl:@"service.uploaduserchangepassword"];
        NSString *changed_password_param = [self stringParameter:@"new_password" withValue:self.changed_password];
        NSString *old_password_param = [self stringParameter:@"old_password" withValue:self.old_password];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[changed_password_param dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[old_password_param dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        return;
    }
    NSLog(@"\n actionUrl: %@", actionUrl);
    
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSString * dataLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    NSLog(@"HTTP body data: %@", [[NSString alloc] initWithData:postData encoding:NSASCIIStringEncoding]);
    NSLog(@"BASIC AUTH FOR USER %@: %@",self.user.username, self.user.httpBase64Auth);
    NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.user.httpBase64Auth];
    [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.currentConnection = theConnection;
    if (theConnection) {
        self.receivedData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"\n Could not connect to the network");
    }

}


-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

- (void)cancelConnection {
    NSLog(@"\n Canceling service for Product ");
    [self.currentConnection cancel];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.currentConnection = nil;
}


// CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"\n Response ready to be received.");
    int code = (int)[(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"\n Received data.");
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"\n Error!");
    [self hideWaiting];
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    // inform the user
    NSLog(@"\n Connection failed! Error - %@ %@ %ld",
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideWaiting];
    
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    NSLog(@"\n Response: %@", responseString);
    NSLog(@"Connection status code: %d.", (int)self.statusCode);
    if (self.statusCode >= 400) {
        [self showAlertMessageError:@"Errore generico" msg:@"Contattare l'amministratore."];
        return;
    }
    
    
    
    if ([self.modifyType isEqualToString:@"fullName"]) {
        // TODO update current fullName
        self.applicationContext.loggedUser.fullName = self.fullName;
        NSLog(@"FULLNAME: %@", self.fullName);
        NSLog(@"full name successfully saved: %@", self.applicationContext.loggedUser.fullName);
    } else if([self.modifyType isEqualToString:@"password"]) {
        NSLog(@"password successfully changed.");
//        [self savePassword:newPassword];
        [self signinWithNewPassword:self.changed_password];
    }
    [self updated];
}

-(void)signinWithNewPassword:(NSString *)_password {
    NSLog(@"Resignin with new password.");
    SHPUser *user = self.applicationContext.loggedUser;
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", user.username, _password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *basicAuth64 = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:80]];
    user.httpBase64Auth = basicAuth64;
    user.password = _password;
    [self.applicationContext signin:user];
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

// --------------------------------------
// ******** SEND USER  *********
// --------------------------------------


//----------------------------------------------------------------//
//START BUILD TABLEVIEW
//----------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return NSLocalizedString(@"PROFILE-fullname section", nil);
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
       return NSLocalizedString(@"PROFILE-password section", nil);
    }
    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return 40;
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
        return 40;
    }
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"password"] && section == 0){
        return 0;
    }
    else if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return 2;
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
        return 4;
    }
    else if([self.modifyType isEqualToString:@"fullName"] && section == 1){
        return 0;
    }
    return 0;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"preparing for segue...");
//    if ([[segue identifier] isEqualToString:@"unwindToChatSettingsTVC"]) {
//        SHPHomeProfileTVC *vc = (SHPHomeProfileTVC *)[segue destinationViewController];
//        vc.applicationContext = self.applicationContext;
//        vc.user = self.user;
//    }
}

static int MIN_CHARS_PASSWORD = 8;

- (IBAction)actionSavePassword:(id)sender
{
//    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
//    NSString *password = [userPreferences valueForKey:@"PASSWORD"];
    NSString *current_password = self.applicationContext.loggedUser.password;
    
    NSString *error;
    
    NSString *old_password = self.textPasswordOld.text;
    NSString *changed_password_trimmed = [self.textPasswordNew.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"old %@ current %@", old_password, current_password);
    if(![old_password isEqualToString:current_password]) {
        error = NSLocalizedString(@"PROFILE-password incorrect", nil);
        [self showAlertMessageError:nil msg:error];
    }
    else if(changed_password_trimmed.length<MIN_CHARS_PASSWORD){
        error = [NSString stringWithFormat:NSLocalizedString(@"PROFILE-password wrong length", nil), MIN_CHARS_PASSWORD];
        [self showAlertMessageError:nil msg:error];
    }
    else if(![changed_password_trimmed isEqualToString:self.textPasswordNewConfirm.text]){
        error = NSLocalizedString(@"PROFILE-password different passwords", nil);
        [self showAlertMessageError:nil msg:error];
    }
    else {
         self.changed_password = [changed_password_trimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.old_password = [old_password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self sendUpdate];
    }
}

- (IBAction)actionSaveFullName:(id)sender {
    
    NSString *error;
    
    NSString *changed_fullname_trimmed = [self.textFullName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(![self validFullname:changed_fullname_trimmed]) {
        error = NSLocalizedString(@"PROFILE-fullname invalid", nil);
        [self showAlertMessageError:nil msg:error];
        return;
    }
    self.fullName = changed_fullname_trimmed;
    [self sendUpdate];
}

-(BOOL)validFullname:(NSString *) fullname {
    NSString *regex = @"[A-Z0-9a-z._ ]+";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:fullname];
}

@end
