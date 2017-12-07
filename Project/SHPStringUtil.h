//
//  SHPStringUtil.h
//  Shopper
//
//  Created by andrea sponziello on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPStringUtil : NSObject

+(NSString *)randomString:(NSInteger) length;
+(NSString *)urlParamEncode:(NSString *)param;
+(NSString *)filePathInApp:(NSString *)path;
+(UIColor *)colorFromSettings:(NSString *)settingsColor;
+(NSString *)stringWithSentenceCapitalization:(NSString *)string;
+(NSDate *)parseDateRFC822:(NSString *)feedDate;
+(BOOL) validEmail: (NSString *) candidate;
+(NSString *)localize:(NSString *)key;
+(NSString *)timeFromNowToString:(NSDate *)date;
+(NSString *)timeFromNowToStringFormattedForConversation:(NSDate *)date;
+(BOOL)isYesterday:(NSDate *)date;
+(NSString *)durationBetweenDatesAsString:(NSDate *)date1 andDate:(NSDate *)date2;
+(NSString *)differentBetweenDates:(NSDate *)date1 endDate:(NSDate *)date2;
+(NSString *)fulltextQuery:(NSString *)originalQuery;
+(NSString *)data2HexadecimalString:(NSData *)data;
+(NSNumber *)string2Number:(NSString *)num_as_string;
+(NSArray *)extractUrlsFromText:(NSString *)text;
+(NSString *)removeCharacter:(NSString *)text character:(NSString *)character chReplace:(NSString *)chReplace;
+(NSMutableAttributedString *)strikethroughText:(NSString *)text color:(UIColor *)color;
+(CGFloat)calculateTextViewHeight:(NSString *)string textWidth:(int)textWidth textHeight:(int)textHeight;

+ (NSString *)labelDateRange:(int)days data:(NSDate *)data;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

+(NSInteger)countUrlsInDescription:(NSString *)text;
+(NSString*)extractSubstring:(NSString*)text;
+(NSString*)cleanTextFromUrls:(NSString*)text;
+(NSMutableArray *)extractUrlsInText:(NSString *)text;
+(NSArray*)extractUrl:(NSString*)urlWithTag;


@end
