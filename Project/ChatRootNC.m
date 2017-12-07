//
//  ChatRootNC.m
//  Chat21
//
//  Created by Andrea Sponziello on 28/12/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "ChatRootNC.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "ChatConversationsVC.h"
#import "NotConnectedVC.h"
//#import "CZAuthenticationVC.h"

@interface ChatRootNC ()

@end

@implementation ChatRootNC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DIDLOADINGROOTNC");
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.chatConfig = [self.applicationContext.plistDictionary valueForKey:@"Chat21"];
    self.startupLogin = [[self.chatConfig valueForKey:@"startupLogin"] boolValue];
    NSLog(@"STARTUP LOGIN %d", self.startupLogin);
    [self setupNC];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"**** SetupNC.viewDidAppear...");
    if (self.startupLogin && !self.applicationContext.loggedUser) {
        NSLog(@"strtupLogin = YES");
        [self goToAuthentication];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"**** SetupNC.viewWillAppear...");
    [self setupNC];
}

-(void)goToAuthentication {
//    NSLog(@"PRESENTING AUTHENTICATION VIEW.");
    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
//    CZAuthenticationVC *vc = (CZAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
//    vc.applicationContext = self.applicationContext;
//    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentViewController:vc animated:NO completion:nil];
}


-(void)setupNC {
    [self loadViewIfNeeded];
    NSLog(@"setupNC. self.applicationContext.loggedUser: %@", self.applicationContext.loggedUser);
    if (self.applicationContext.loggedUser) {
        [self linkChatNC];
    }
    else if (self.startupLogin) {
        [self linkWhiteView];
    }
    else {
        [self linkConnectView];
    }
}

-(void)openConversationWithRecipient:(ChatUser *)recipient {
    [self openConversationWithRecipient:recipient orGroup:nil sendMessage:nil attributes:nil];
}

-(void)openConversationWithRecipient:(ChatUser *)recipient sendMessage:(NSString *)message {
    [self openConversationWithRecipient:recipient orGroup:nil sendMessage:message attributes:nil];
}

-(void)openConversationWithGroup:(NSString *)groupid {
    [self openConversationWithRecipient:nil orGroup:groupid sendMessage:nil attributes:nil];
}

-(void)openConversationWithGroup:(NSString *)groupid sendMessage:(NSString *)message {
    [self openConversationWithRecipient:nil orGroup:groupid sendMessage:nil attributes:nil];
}

-(void)openConversationWithRecipient:(ChatUser *)recipient orGroup:(NSString *)groupid sendMessage:(NSString *)text attributes:(NSDictionary *)attributes {
    [self setupNC];
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[ChatConversationsVC class]]) {
        NSLog(@"Chat linked. Opening conversation with user: %@", recipient.userId);
        ChatConversationsVC *vc = self.viewControllers[0];
//        vc.selectedRecipientTextToSend = text;
        NSLog(@"vc.view.window %@", vc.view.window);
        
//        if (!vc.view.window) { // SE WINDOW != NIL LA VISTA E' VISIBILE! IL SENSO DI QUESTO CODICE E' IL SEGUENTE: SE LA VISTA NON E' ANCORA VISIBILE IMPOSTO LE VARIABILI E FACCIO IN MODO DI RICHIAMARE IL METODO "openConversationWithRecipient" DAL VIEWDIDAPPEAR UTILIZZANDO LE VARIABILI IMPOSTATE. SE ALTRIMENTI E' VISIBILE LO RICHIAMO DIRETTAMENTE. PER ADESSO DISABILITO QUESTO COMPORTAMENTO E LO RICHIAMO DIRETTAMENTE. MA PRIMA DI CHIAMARE "openConversationWithRecipient" SPOSTO SEMPRE LA TABBAR SULLA VISTA CORRISPONDENTE ALLA CHAT PER CUI DOVREBBE ESSERE SEMPRE VISIBILE LA VISTA CONVERSAZIONI (REPETITA IUVANT).
        
//            NSLog(@"conversation view not visible. Switch to conversation view using conversationsView.viewDidAppear.");
//            vc.selectedRecipient = userid;
//            // viewDidAppear will do the job!
//            [self popToRootViewControllerAnimated:NO];
//        } else {
        
            // the conversationsView is selected (no conversation is on)
            // and viewDidAppear will not work if the tab is already on the chat.
            NSLog(@"no conversation selected. conversations view is visible. switching manually.");
            [vc openConversationWithRecipient:recipient orGroup:groupid sendMessage:text attributes:attributes];
        
//        }
        
    } else {
        NSLog(@"Chat not linked. This is a problem. Am I receiving notification as logged out? Or something else?");
    }
}

-(void)linkChatNC {
    NSLog(@"Initializing linkChatNC");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[ChatConversationsVC class]]) {
        NSLog(@"Chat already linked");
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    UINavigationController *chatNC = [sb instantiateViewControllerWithIdentifier:@"ChatNavigationController"];
    [self setViewControllers:chatNC.viewControllers];
}

-(void)linkConnectView {
    NSLog(@"Initializing linkConnectView");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[NotConnectedVC class]]) {
        NSLog(@"ConnectView already linked");
        return;
    }
    UIStoryboard *sb = [self storyboard];
    UIViewController *connectView = [sb instantiateViewControllerWithIdentifier:@"NotConnectedVC"];
    [self setViewControllers:@[connectView]];
}

-(void)linkWhiteView { // for startupLogin
    NSLog(@"Initializing linkWhiteView");
    if (self.viewControllers.count > 0 && [self.viewControllers[0] isKindOfClass:[UIViewController class]]) {
        NSLog(@"WhiteView already linked");
        return;
    }
    UIStoryboard *sb = [self storyboard];
    UIViewController *connectView = [sb instantiateViewControllerWithIdentifier:@"WhiteView"];
    [self setViewControllers:@[connectView]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
