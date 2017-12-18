//
//  SHPConnectionsController.m
//  Dressique
//
//  Created by andrea sponziello on 26/01/13.
//
//

#import "SHPConnectionsController.h"
#import "SHPDataController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation SHPConnectionsController

@synthesize controllers;

-(id)init {
    self = [super init];
    if (self) {
        self.controllers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addDataController:(SHPDataController *)dc {
    dc.connectionsControllerDelegate = self;
    [self.controllers addObject:dc];
    NSLog(@"Added controller. Total %lu", (unsigned long)self.controllers.count);
}

-(void)didFinishConnection:(SHPDataController *)dc withError:(NSError *)error {
    NSLog(@"Connection for %@ finished. Finding and removing...", dc);
    NSLog(@"Total controllers: %lu", (unsigned long)self.controllers.count);
    SHPDataController *controller = nil;
    for (id obj in self.controllers) {
        if (obj == dc) {
            controller = (SHPDataController *)obj;
            break;
        }
    }
    if (controller) {
//        NSLog(@"Found controller %@, BUT NOT removing from controllers (FOR HISTORY).", controller);
        NSLog(@"Found controller %@, now removing from controllers.", controller);
//        [self.controllers removeObject:controller];
        [self removeDataController:controller];
    } else {
        NSLog(@"Controller not found.");
    }
    
    // on completion play a sound
    // help: https://github.com/TUNER88/iOSSystemSoundsLibrary
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_bamboo.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

-(void)removeDataController:(SHPDataController *)dc {
    [dc cancelConnection];
    [self.controllers removeObject:dc];
    NSLog(@"Controller was removed. Total %d", (int)self.controllers.count);
}

@end
