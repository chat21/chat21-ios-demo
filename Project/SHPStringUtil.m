//
//  SHPStringUtil.m
//  Shopper
//
//  Created by andrea sponziello on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPStringUtil.h"


@implementation SHPStringUtil

+(NSString *)randomString:(NSInteger)length {
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

+(NSString *)urlParamEncode:(NSString *)param {
    NSString *param_s = [NSString stringWithFormat: @"%@", param];;
    return [param_s stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+(NSString *)filePathInApp:(NSString *)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:path];
    return file;
}

+(UIColor *)colorFromSettings:(NSString *)colorString {
    // ex "123,233,210,1.0"
    NSArray *colors = [colorString componentsSeparatedByString:@","];
    
    float red = [(NSString *)[colors objectAtIndex:0] floatValue]/255.0f;
    float green = [(NSString *)[colors objectAtIndex:1] floatValue]/255.0f;
    float blue = [(NSString *)[colors objectAtIndex:2] floatValue]/255.0f;
    float alfa = [(NSString *)[colors objectAtIndex:3] floatValue];
//    NSLog(@"Color %f %f %f %f", red, green, blue, alfa);
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alfa];
    return color;
}

+(NSString *) stringWithSentenceCapitalization:(NSString *)string {
    return [NSString stringWithFormat:@"%@%@",[[string substringToIndex:1] capitalizedString],[string substringFromIndex:1]];
}

+(NSDate *)parseDateRFC822:(NSString *)dateString {
//    NSString *dateString = @"Mon, 03 May 2010 18:54:26 +00:00";
//    NSString *dateString = @"Wed, 08 Aug 2012 10:30:05 +0000";
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMMM yyyy HH:mm:ss Z"];
    // set locale to something English
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    [df setLocale:enLocale];
    NSDate *date = [df dateFromString:dateString];
    return date;
}

+(BOOL) validEmail:(NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:candidate];
}

+(NSString *)localize:(NSString *)key {
    // TODO Refactoring with some sort of singleton?
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *localizedString = [thisBundle localizedStringForKey:key value:@"KEY NOT FOUND" table:@"Localizable"];
    return localizedString;
}

+(NSString *)timeFromNowToStringFormattedForConversation:(NSDate *)date {
    // TEST
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
//    NSString *ds = @"7-4-2016 14:50";
//    NSDate *date = [df dateFromString: ds];
    
    /*
     a few seconds ago
     about a minute ago
     15 minutes ago
     about one hour ago
     2 hours ago
     23 hours ago
     Yesterday at 5:07pm TODO
     October 11
     */
    NSString *timeMessagePart;
    NSString *unitMessagePart;
    NSDate *now = [[NSDate alloc] init];
//    NSLog(@"NOW: %@", now);
//    NSLog(@"DATE: %@", date);
    double nowInSeconds = [now timeIntervalSince1970];
//    NSLog(@"NOW IN SECONDS %f", nowInSeconds);
    double startDateInSeconds = [date timeIntervalSince1970];
//    NSLog(@"START DATE IN SECONDS %f", startDateInSeconds);
    double secondsElapsed = nowInSeconds - startDateInSeconds;
//    NSLog(@"SECONDS ELAPSED %f", secondsElapsed);
    if (secondsElapsed < 60) {
        NSLog(@"<60");
        timeMessagePart = NSLocalizedString(@"FewSecondsAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 60 && secondsElapsed <120) {
//        NSLog(@"<120");
        timeMessagePart = NSLocalizedString(@"AboutAMinuteAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 120 && secondsElapsed <3600) {
//        NSLog(@"<360");
        int minutes = secondsElapsed / 60.0;
        timeMessagePart = [[NSString alloc] initWithFormat:@"%d ", minutes];
        unitMessagePart = NSLocalizedString(@"MinutesAgoLKey", nil);
    }
    else if (secondsElapsed >=3600 && secondsElapsed < 5400) {
//        NSLog(@"<5400");
        timeMessagePart = NSLocalizedString(@"AboutAnHourAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 5400 && secondsElapsed <= 86400) { // HH:mm
//        NSLog(@"<86400");
        if ([SHPStringUtil isYesterday:date]) {
//            NSLog(@"Yesterday in < 1 day");
            timeMessagePart = NSLocalizedString(@"yesterday", nil);
            unitMessagePart = @"";
        } else {
//            NSLog(@"Not Yesterday. time in this day");
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"HH:mm"];
            timeMessagePart = [dateFormat stringFromDate:date];
            unitMessagePart = @"";
        }
    }
    else if (secondsElapsed > 86400 && secondsElapsed <= 518400) { // 518.400 = 6 days. Format = Thrusday, Monday ...
        if ([SHPStringUtil isYesterday:date]) {
//            NSLog(@"Yesterday");
            timeMessagePart = NSLocalizedString(@"yesterday", nil);
            unitMessagePart = @"";
        } else {
//            NSLog(@"Thrusday, monday...");
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEEE"];
            timeMessagePart = [dateFormat stringFromDate:date];
            unitMessagePart = @"";
        }
    }
    else { // 6/4/2015
//        NSLog(@"6/4/2015...");
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        // http://mobiledevelopertips.com/cocoa/date-formatters-examples-take-2.html
        [dateFormat setDateFormat:NSLocalizedString(@"ShortDateFormat", nil)];
        timeMessagePart = [dateFormat stringFromDate:date];
        unitMessagePart = @"";
    }
    NSString *timeString = [[NSString alloc] initWithFormat:@"%@%@", timeMessagePart, unitMessagePart];
//    NSLog(@"TIMESTRING %@", timeString);
    return timeString;
}

+(BOOL)isYesterday:(NSDate *)date
{
//    NSDate *now = [NSDate date];
//    // All intervals taken from Google
//    NSDate *yesterday = [now dateByAddingTimeInterval: -86400.0];
//    NSLog(@"yesterday %@", yesterday);
//    return yesterday ? YES : NO;
    
    // ios 8 only
    NSCalendar* calendar = [NSCalendar currentCalendar];
    return [calendar isDateInYesterday:date];
}

+(NSString *)timeFromNowToString:(NSDate *)date {
    /*
     Model from Facebook

     a few seconds ago
     about a minute ago
     15 minutes ago
     about one hour ago
     2 hours ago
     23 hours ago
     Yesterday at 5:07pm TODO
     October 11
     */
    NSString *timeMessagePart;
    NSString *unitMessagePart;
    NSDate *now = [[NSDate alloc] init];
    NSLog(@"NOW: %@", now);
    NSLog(@"DATE: %@", date);
    double nowInSeconds = [now timeIntervalSince1970];
    NSLog(@"NOW IN SECONDS %f", nowInSeconds);
    double startDateInSeconds = [date timeIntervalSince1970];
    NSLog(@"START DATE IN SECONDS %f", startDateInSeconds);
    double secondsElapsed = nowInSeconds - startDateInSeconds;
    NSLog(@"SECONDS ELAPSED %f", secondsElapsed);
    if (secondsElapsed < 60) {
        timeMessagePart = NSLocalizedString(@"FewSecondsAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 60 && secondsElapsed <120) {
        timeMessagePart = NSLocalizedString(@"AboutAMinuteAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 120 && secondsElapsed <3600) {
        int minutes = secondsElapsed / 60.0;
        timeMessagePart = [[NSString alloc] initWithFormat:@"%d ", minutes];
        unitMessagePart = NSLocalizedString(@"MinutesAgoLKey", nil);
    }
    else if (secondsElapsed >=3600 && secondsElapsed < 5400) {
        timeMessagePart = NSLocalizedString(@"AboutAnHourAgoLKey", nil);
        unitMessagePart = @"";
    }
    else if (secondsElapsed >= 5400 && secondsElapsed <= 86400) {
        int hours = secondsElapsed / 3600.0;
        timeMessagePart = [[NSString alloc] initWithFormat:@"%d ", hours];
        unitMessagePart = NSLocalizedString(@"HoursAgoLKey", nil);
    }
    else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        // http://mobiledevelopertips.com/cocoa/date-formatters-examples-take-2.html
        [dateFormat setDateFormat:NSLocalizedString(@"TimeToStringDateFormat", nil)];
        NSString *dateString = [[dateFormat stringFromDate:date] capitalizedString];
//        timeMessagePart = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"theLKey", nil), dateString];
        timeMessagePart = dateString;
        unitMessagePart = @"";
    }
    NSString *timeString = [[NSString alloc] initWithFormat:@"%@%@", timeMessagePart, unitMessagePart];
    return timeString;
}

+(NSString *)differentBetweenDates:(NSDate *)date1 endDate:(NSDate *)date2 {
    // The time interval
   // NSTimeInterval theTimeInterval = 326.4;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSString *timeStringMonth=@"";
    NSString *timeStringDay=@"";
    
    NSLog(@"anni: %d",(int)[conversionInfo year]);
    if([conversionInfo year]>0){
        return @"";
    }else{
        if([conversionInfo month]==1){
            timeStringMonth =  [[NSString alloc] initWithFormat:@"%d %@, ",(int)[conversionInfo month], NSLocalizedString(@"durationMonth", nil)];
        }else if([conversionInfo month]>0){
            timeStringMonth =  [[NSString alloc] initWithFormat:@"%d %@, ",(int)[conversionInfo month], NSLocalizedString(@"durationMonths", nil)];
        }
        if([conversionInfo day]==1){
            timeStringDay =  [[NSString alloc] initWithFormat:@"%d %@, ",(int)[conversionInfo day], NSLocalizedString(@"durationDay", nil)];
        }else if([conversionInfo day]>0){
            timeStringDay =  [[NSString alloc] initWithFormat:@"%d %@, ",(int)[conversionInfo day], NSLocalizedString(@"durationDays", nil)];
        }
        
        NSString *timeStringHours;
        NSString *timeString;
        if([conversionInfo hour]>=0 && [conversionInfo minute]>0){
            timeStringHours =  [[NSString alloc] initWithFormat:@"%d%@:%d%@",(int)[conversionInfo hour], NSLocalizedString(@"h", nil), (int)[conversionInfo minute], NSLocalizedString(@"m", nil)];
            timeString =  [[NSString alloc] initWithFormat:@"%@%@%@",timeStringMonth, timeStringDay, timeStringHours];
        }
        NSLog(@"diff date: %@",timeString);
        return timeString;
    }
}


+(NSString *)durationBetweenDatesAsString:(NSDate *)date1 andDate:(NSDate *)date2 {
    NSString *message;
    double date1InSeconds = [date1 timeIntervalSince1970];
    double date2InSeconds = [date2 timeIntervalSince1970];
    double secondsElapsed = date2InSeconds - date1InSeconds;
    NSLog(@"secondsElapsed %f", secondsElapsed);
    if (secondsElapsed < 82800) {
        NSLog(@"< 23 hours");
        message = NSLocalizedString(@"durationLessThanOneDayFormat", nil);
    }
    else if (secondsElapsed < 86400) {
        NSLog(@"< 23:59:59 hours");
        message = NSLocalizedString(@"durationAboutOneDayFormat", nil);
    }
    else if (secondsElapsed >= 86400) {
        NSLog(@">= 1 day");
        int days = secondsElapsed / 86400;
        message = [[NSString alloc] initWithFormat:NSLocalizedString(@"durationDaysFormat", nil), days];
    }
    return message;
}

+(NSString *)fulltextQuery:(NSString *)originalQuery {
    // remove all *
    NSString *cleanedQuery = [originalQuery
                                     stringByReplacingOccurrencesOfString:@"*" withString:@""];
    // remove all !
    cleanedQuery = [cleanedQuery
                              stringByReplacingOccurrencesOfString:@"!" withString:@""];
    NSLog(@"preparing for fulltext -%@-", cleanedQuery);
    NSString *trimmedQuery = [cleanedQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"trimmed -%@-", trimmedQuery);
    if ([trimmedQuery isEqualToString:@""]) {
        NSLog(@"Returning empty string.");
        return trimmedQuery;
    }
    // ex. "m k"
    NSLog(@"String is not empty, adding * at the end of each word...");
    NSArray *_words = [trimmedQuery componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray* words = [_words mutableCopy];
    // ex "m" "k"
    NSString *newQuery;
    NSString *firstWordWildcarded = [[NSString alloc] initWithFormat:@"%@*", [words objectAtIndex:0]];
    if (words.count == 1) {
        newQuery = firstWordWildcarded;
    } else {
        [words replaceObjectAtIndex:0 withObject:firstWordWildcarded];
        newQuery = [words componentsJoinedByString:@" "];
    }
//    // m* t* k (the last word has no joinString "* "
//    newQuery = [[NSString alloc] initWithFormat:@"%@*", newQuery];
    // ex. m* t* k*
    NSLog(@"Final query with * -%@-", newQuery);
    return newQuery;
//    for (NSString *w in words) {}
}

+(NSString *)data2HexadecimalString:(NSData *)data {
    NSUInteger capacity = [data length] * 2;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [data bytes];
    NSInteger i;
    for (i=0; i<[data length]; ++i) {
        [stringBuffer appendFormat:@"%02X", (int)dataBuffer[i]];
    }
    return [NSString stringWithString:stringBuffer];
}

+(NSNumber *)string2Number:(NSString *)num_as_string {
    num_as_string = [num_as_string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            //[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setAllowsFloats:YES];
            [formatter setMaximumFractionDigits:2];
            [formatter setUsesGroupingSeparator:NO];
            [formatter setDecimalSeparator:@"."];
    NSNumber *fNum = [formatter numberFromString:num_as_string];
    //[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSLog(@"Number is 1 %@", num_as_string);
    return fNum;
}

+(NSArray *)extractUrlsFromText:(NSString *)text{
    NSArray *splitText1 = [text componentsSeparatedByString:@"[["];
    //NSLog(@"%@",splitText1);
    NSArray *splitText2;
    NSArray *splitText3;
    NSString *linkPage = @"";
    NSString *linkLabel = @"";
    if(splitText1.count>1){
        splitText2 = [splitText1[1] componentsSeparatedByString:@"]]"];
        //NSLog(@"%@",splitText2);
        if(splitText2.count>1){
            linkPage = splitText2[0];
            //[text stringByAppendingString:splitText2[1]];
            if([linkPage hasPrefix:@"http"]){
                text = [NSString stringWithFormat:@"%@%@", splitText1[0], splitText2[1]];
                text = [self removeCharacter:text character:@"  " chReplace:@" "];//TRIM
                text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                linkLabel = splitText2[0];
                splitText3 = [linkPage componentsSeparatedByString:@"|"];
                if(splitText3.count>1){
                    linkPage=splitText3[0];
                    linkLabel=splitText3[1];
                }
            }
        }
    }
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    [strings addObject:text];
    [strings addObject:linkPage];
    [strings addObject:linkLabel];
    return [[NSArray alloc] initWithArray:strings];
}

+(NSString *)removeCharacter:(NSString *)text character:(NSString *)character chReplace:(NSString *)chReplace{
    while ([text rangeOfString:character].location != NSNotFound) {
        text = [text stringByReplacingOccurrencesOfString:character withString:chReplace];
    }
    return text;
}

+(NSMutableAttributedString *)strikethroughText:(NSString *)text color:(UIColor *)color{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:(text ? text : @"")];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@1
                            range:NSMakeRange(0, [attributeString length])
     ];
    // Set foreground color for entire range
    [attributeString addAttribute:NSStrikethroughColorAttributeName
                             value:color//[UIColor colorWithRed:0.850 green:0.850 blue:0.850 alpha:1.000]
                             range:NSMakeRange(0, [attributeString length])];
    return attributeString;
}

+ (CGFloat)calculateTextViewHeight:(NSString *)string textWidth:(int)textWidth textHeight:(int)textHeight
{
    //NSString *string2 = @"<h1>Header</h1><h2>Subheader</h2><p>Some <em>text dòvjdf lda  aslkjfksd lskfjls  alhiuhef weuhfpn òWIEJ ONSD OIJ oerijnlfdkj dfoijn </em></p><a href='http://google.it'>LINK</a>";
    NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [bodyText addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:14.0]
                     range:NSMakeRange(0,[bodyText length])];
    //CGRect rect = [bodyText boundingRectWithSize:CGSizeMake(self.labelDescription.frame.size.width+2, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGRect rect = [bodyText boundingRectWithSize:CGSizeMake(textWidth+2, textHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return CGRectGetHeight(rect);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//FUNZIONI ELABORAZIONI DATE
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSString *)labelDateRange:(int)days data:(NSDate *)data
{
    NSString *dateChat;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if(days==0){
        dateChat = NSLocalizedString(@"today", nil);
    }
    else if(days==1){
        dateChat = NSLocalizedString(@"yesterday", nil);
    }
    else if(days<8){
        [dateFormatter setDateFormat:@"EEEE"];
        dateChat = [dateFormatter stringFromDate:data];
    }
    else{
        [dateFormatter setDateFormat:@"dd MMM"];
        dateChat = [dateFormatter stringFromDate:data];
    }
    return dateChat;
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
+(NSString*)cleanTextFromUrls:(NSString*)text{
    ///extractSubstring:(NSString*)text
    NSString *cleanText = text;
    NSString *subString;
    NSInteger numberUrlsInDescription = [self countUrlsInDescription:text];
    for (int i=0; i<numberUrlsInDescription; i++) {
        subString = [self extractSubstring:cleanText];
        cleanText = [cleanText stringByReplacingOccurrencesOfString:subString withString:@""];
    }
    //NSString *cleanText = [text stringByReplacingOccurencesOfString:@"%" withString:@""];
    return cleanText;
}

+(NSString *)extractSubstring:(NSString*)text{
    NSRange match;
    NSRange match1;
    match = [text rangeOfString: @"[["];
    match1 = [text rangeOfString: @"]]"];
    //NSLog(@"%@ --- %i,%i",text, (int)match.location,(int)match1.location);
    NSString *substring = [text substringWithRange: NSMakeRange (match.location, match1.location - match.location+2)];
    return substring;
}

+(NSMutableArray *)extractUrlsInText:(NSString *)text{
    NSMutableArray *arrayLink = [[NSMutableArray alloc] init];
    NSString *cleanText = text;
    NSString *subString;
    NSInteger numberUrlsInDescription = [self countUrlsInDescription:text];
    for (int i=0; i<numberUrlsInDescription; i++) {
        subString = [self extractSubstring:cleanText];
        cleanText = [cleanText stringByReplacingOccurrencesOfString:subString withString:@""];
        [arrayLink addObject:subString];
    }
    return arrayLink;
}

+(NSArray*)extractUrl:(NSString*)urlWithTag{
    NSString *urlPage = [urlWithTag stringByReplacingOccurrencesOfString:@"[[" withString:@""];
    urlPage = [urlPage stringByReplacingOccurrencesOfString:@"]]" withString:@""];
    NSArray *splitText = [urlPage componentsSeparatedByString:@"|"];
    return splitText;
}

+(NSInteger)countUrlsInDescription:(NSString *)text{
    NSUInteger numberOfOccurrences = [[text componentsSeparatedByString:@"[["] count] - 1;
    return numberOfOccurrences;
}
@end
