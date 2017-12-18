//
//  SHPDataController.m
//  Dressique
//
//  Created by andrea sponziello on 26/01/13.
//
//

#import "SHPDataController.h"

@implementation SHPDataController

@synthesize connectionsControllerDelegate;
@synthesize currentState;
@synthesize progress;
@synthesize creationDate;
@synthesize description;


// abstract
-(void)cancelConnection {
}

// abstract
-(void)send {
}

- (NSComparisonResult)compare:(SHPDataController *)otherObject {
    return [self.creationDate compare:otherObject.creationDate];
}

@end
