//
//  SHPFirebaseTokenDelegate.h
//  Soleto
//
//  Created by Andrea Sponziello on 20/11/14.
//
//

#import <Foundation/Foundation.h>

@protocol SHPFirebaseTokenDelegate <NSObject>
@required
-(void)didFinishFirebaseAuthWithToken:(NSString *)token error:(NSError *)error;
@end