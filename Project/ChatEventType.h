//
//  ChatEventType.h
//  tilechat
//
//  Created by Andrea Sponziello on 21/12/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#ifndef ChatEventType_h
#define ChatEventType_h

#import <Foundation/Foundation.h>
//#import "FIRDatabaseSwiftNameSupport.h"

/**
 * This enum is the set of events that you can observe in a Conversation.
 */
typedef NS_ENUM(NSInteger, ChatEventType) {
    /// A new child node is added to a location.
    ChatEventMessageAdded,
    /// A child node is removed from a location.
    ChatEventMessageDeleted,
    /// A child node at a location changes.
    ChatEventMessageChanged,
};// FIR_SWIFT_NAME(DataEventType);

#endif /* ChatEventType_h */
