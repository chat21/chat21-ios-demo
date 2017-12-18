//
//  SHPDataController.h
//  Dressique
//
//  Created by andrea sponziello on 26/01/13.
//
//

#import <Foundation/Foundation.h>

@class SHPConnectionsController;

@interface SHPDataController : NSObject

@property (nonatomic, strong) SHPConnectionsController *connectionsControllerDelegate;
@property (nonatomic, assign) NSInteger currentState;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *creationDate;

// abstract
- (void)cancelConnection;
// abstract
-(void)send;

@end
