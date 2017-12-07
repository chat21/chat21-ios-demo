//
//  SHPConnectionsController.h
//  Dressique
//
//  Created by andrea sponziello on 26/01/13.
//
//

#import <Foundation/Foundation.h>

@class SHPDataController;

@interface SHPConnectionsController : NSObject

@property(strong, nonatomic) NSMutableArray *controllers;

-(void)addDataController:(SHPDataController *)dc;
-(void)removeDataController:(SHPDataController *)dc;

// delegate methods
-(void)didFinishConnection:(SHPDataController *)dataController withError:(NSError *)error;

@end
