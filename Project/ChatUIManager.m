//
//  ChatUIManager.m
//  tilechat
//
//  Created by Andrea Sponziello on 06/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "ChatUIManager.h"

static ChatUIManager *sharedInstance = nil;

@implementation ChatUIManager

+(ChatUIManager *)getInstance {
    if (!sharedInstance) {
        sharedInstance = [[ChatUIManager alloc] init];
    }
    return sharedInstance;
}

@end
