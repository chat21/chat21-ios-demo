//
//  ChatSpeaker.m
//  tilechat
//
//  Created by Andrea Sponziello on 20/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "ChatSpeaker.h"

@implementation ChatSpeaker

- (id)initWithId:(NSString *)speakerId name:(NSString *)name {
    if (self = [super init]) {
        self.speakerId = speakerId;
        self.name = name;
    }
    return self;
}

@end
