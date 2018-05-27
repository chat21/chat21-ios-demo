//
//  Chat21SDK.h
//  Chat21SDK
//
//  Created by Andrea Sponziello on 26/05/2018.
//  Copyright © 2018 Frontiere21 SRL. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Chat21SDK.
FOUNDATION_EXPORT double Chat21SDKVersionNumber;

//! Project version string for Chat21SDK.
FOUNDATION_EXPORT const unsigned char Chat21SDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Chat21SDK/PublicHeader.h>

#import <Chat21/ChatChangeGroupNameVC.h>
#import <Chat21/ChatConversationsVC.h>
#import <Chat21/ChatCreateGroupVC.h>
#import <Chat21/ChatGroupInfoVC.h>
#import <Chat21/ChatGroupMembersVC.h>
#import <Chat21/ChatImageMessageCell.h>
#import <Chat21/ChatImageMessageLeftCell.h>
#import <Chat21/ChatImageMessageRightCell.h>
#import <Chat21/ChatImagePreviewVC.h>
#import <Chat21/ChatInfoMessageAttributesTVC.h>
#import <Chat21/ChatInfoMessageCell.h>
#import <Chat21/ChatInfoMessageTVC.h>
#import <Chat21/ChatMessageCell.h>
#import <Chat21/ChatMessagesTVC.h>
#import <Chat21/ChatMessagesVC.h>
#import <Chat21/ChatMiniBrowserVC.h>
#import <Chat21/ChatModalCallerDelegate.h>
#import <Chat21/ChatNYTPhoto.h>
#import <Chat21/ChatSelectGroupLocalTVC.h>
#import <Chat21/ChatSelectGroupMembersLocal.h>
#import <Chat21/ChatSelectUserLocalVC.h>
#import <Chat21/ChatStatusTitle.h>
#import <Chat21/ChatTextMessageLeftCell.h>
#import <Chat21/ChatTextMessageRightCell.h>
#import <Chat21/ChatTitleVC.h>
#import <Chat21/NotificationAlertVC.h>
#import <Chat21/NotificationAlertView.h>
#import <Chat21/UIView+Property.h>

#import <Chat21/CellConfigurator.h>
#import <Chat21/ChatCustomView.h>
#import <Chat21/ChatImageUtil.h>
#import <Chat21/ChatLocal.h>
#import <Chat21/ChatMessageComponents.h>
#import <Chat21/ChatProgressView.h>

#import <Chat21/ChatImageCache.h>
#import <Chat21/ChatImageWrapper.h>
#import <Chat21/ChatStringUtil.h>
#import <Chat21/ChatUpload.h>
#import <Chat21/ChatUploadsController.h>
#import <Chat21/ChatUtil.h>

#import <Chat21/ChatConversation.h>
#import <Chat21/ChatEventType.h>
#import <Chat21/ChatGroup.h>
#import <Chat21/ChatMessage.h>
#import <Chat21/ChatUser.h>

#import <Chat21/ChatAuth.h>
#import <Chat21/ChatConnectionStatusHandler.h>
#import <Chat21/ChatContactsSynchronizer.h>
#import <Chat21/ChatConversationHandler.h>
#import <Chat21/ChatConversationsHandler.h>
#import <Chat21/ChatGroupsHandler.h>
#import <Chat21/ChatGroupsSubscriber.h>
#import <Chat21/ChatImageDownloadManager.h>
#import <Chat21/ChatMessageMetadata.h>
#import <Chat21/ChatPresenceHandler.h>
#import <Chat21/ChatPresenceViewDelegate.h>
#import <Chat21/ChatSynchDelegate.h>
#import <Chat21/FirebaseCustomAuthHelper.h>

#import <Chat21/ChatContactsDB.h>
#import <Chat21/ChatDB.h>
#import <Chat21/ChatGroupsDB.h>
