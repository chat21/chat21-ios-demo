//
//  ChatSpeaker.h
//  tilechat
//
//  Created by Andrea Sponziello on 20/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSpeaker : NSObject

@property (strong, nonatomic) NSString *speakerId;
@property (strong, nonatomic) NSString *name;

- (id)initWithId:(NSString *)speakerId name:(NSString *)name;

@end
