//
//  SHPUserInterfaceUtil.m
//  Shopper
//
//  Created by andrea sponziello on 09/10/12.
//
//

#import "SHPUserInterfaceUtil.h"

@implementation SHPUserInterfaceUtil

+ (void)applyTitleString:(NSString *)text toAttributedLabel:(UILabel *)label {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                         initWithString:text];
    UIFontDescriptor *fontDescriptor = label.font.fontDescriptor;
    UIFontDescriptor* boldFontDescriptor = [fontDescriptor
                                            fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont* boldFont =  [UIFont fontWithDescriptor:boldFontDescriptor size: 0.0];
    
    // 2. match items surrounded by asterisks
    NSString* regexStr = @"(\\*\\w+(\\s\\w+)*\\*)";
    NSRegularExpression* regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexStr
                                  options:0
                                  error:nil];
    
    NSDictionary* boldAttributes = @{ NSFontAttributeName : boldFont };
    
    // 3. iterate over each match, making the text bold
    [regex enumerateMatchesInString:text
                            options:0
                              range:NSMakeRange(0, [text length])
                         usingBlock:^(NSTextCheckingResult *match,
                                      NSMatchingFlags flags,
                                      BOOL *stop){
                             //NSLog(@"MATCH %@", match);
                             NSRange matchRange = [match rangeAtIndex:1];
                             //                             NSLog(@"inizio: %d len: %d fine: %d", matchRange.location, matchRange.length, matchRange.location + matchRange.length);
                             //NSString *m_s = [text substringWithRange:matchRange];
                             //NSLog(@"match: %@", m_s);
                             [string addAttributes:boldAttributes range:matchRange];
                         }];
    [string.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string.mutableString length])];
    NSLog(@"string: %@", string);
    label.attributedText = string;
}

@end
