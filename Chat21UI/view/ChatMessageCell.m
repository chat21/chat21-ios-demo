//
//  ChatMessageCell.m
//  Chat21
//
//  Created by Andrea Sponziello on 08/03/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "ChatMessageCell.h"
#import "ChatMessage.h"
#import "ChatMessageComponents.h"
#import "ChatUtil.h"
#import "ChatLocal.h"

@implementation ChatMessageCell

-(NSString*)formatDateMessage:(int)numberDaysBetweenChats message:(ChatMessage*)message row:(CGFloat)row {
    NSString *dateChat;
    if(numberDaysBetweenChats>0 || row==0){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *today;
        today = [NSDate date];
        int days = (int)[ChatUtil daysBetweenDate:message.date andDate:today];
        if(days==0){
            dateChat = [ChatLocal translate:@"today"];
        }
        else if(days==1){
            dateChat = [ChatLocal translate:@"yesterday"];
        }
        else if(days<8){
            [dateFormatter setDateFormat:@"EEEE"];
            dateChat = [dateFormatter stringFromDate:message.date];
        }
        else{
            [dateFormatter setDateFormat:@"dd MMM"];
            dateChat = [dateFormatter stringFromDate:message.date];
        }
    }
    return dateChat;
}

-(NSString *)displayUserOfMessage:(ChatMessage *)m {
    NSString *displayName;
    
    // use fullname if available
    if (m.senderFullname) {
        NSString *trimmedFullname = [m.senderFullname stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceCharacterSet]];
        if (trimmedFullname.length > 0 && ![trimmedFullname isEqualToString:@"(null)"]) {
            displayName = trimmedFullname;
        }
    }
    
    // if fullname not available use username instead
    if (!displayName) {
        displayName = m.sender;
    }
    
    return displayName;
}

-(void)attributedString:(UILabel *)label text:(ChatMessage *)message indexPath:(NSIndexPath *)indexPath rowComponents:(NSDictionary *)rowComponents {
    // consider use of: https://github.com/TTTAttributedLabel/TTTAttributedLabel
    NSString *text = message.text;
    if (!text) {
        text = @"";
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttributes:@{NSFontAttributeName: label.font} range:NSMakeRange(0, attributedString.string.length)];
    ChatMessageComponents *components = [rowComponents objectForKey:message.messageId];
    NSArray *urlMatches = components.urlsMatches;
    if (urlMatches) {
        for (NSTextCheckingResult *match in urlMatches) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:match.range];
        }
    }
    NSArray *chatLinkMatches = components.chatLinkMatches;
    if (chatLinkMatches) {
        for (NSTextCheckingResult *match in chatLinkMatches) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:match.range];
        }
    }
    label.attributedText = attributedString;
}

@end
