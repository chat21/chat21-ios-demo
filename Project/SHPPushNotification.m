//
//  SHPPushNotification.m
//  Smart21
//
//  Created by Andrea Sponziello on 22/01/15.
//
//

#import "SHPPushNotification.h"

@implementation SHPPushNotification

-(NSString *)propertiesAsJSON {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.properties
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString: %@", jsonString);
        return jsonString;
    }
}

@end
