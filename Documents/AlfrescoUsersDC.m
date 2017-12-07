//
//  AlfrescoUsersDC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 24/07/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "AlfrescoUsersDC.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoRepositorySession.h"
#import "SHPApplicationContext.h"
#import "AlfrescoPagingResult.h"
#import "AlfrescoPersonService.h"
#import "SHPUser.h"

@implementation AlfrescoUsersDC

-(AlfrescoRequest *)usersByText:(NSString *)text completion:(void (^)(NSArray<SHPUser *> *))callback  {
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    AlfrescoRepositorySession *session = app.docSession;
    
    if (session) {
        AlfrescoListingContext *lc = [[AlfrescoListingContext alloc] init];
        lc.maxItems = 20;
        AlfrescoPersonService *personService = [[AlfrescoPersonService alloc] initWithSession:session];
        AlfrescoRequest *request = [personService searchWithKeywords:text listingContext:lc completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            NSLog(@"Users loaded. Error? %@", error);
            NSLog(@"Total users result: %d", pagingResult.totalItems);
            NSMutableArray<SHPUser *> *users = [[NSMutableArray alloc] init];
            for (AlfrescoPerson *person in pagingResult.objects) {
                SHPUser *user = [[SHPUser alloc] init];
                user.fullName = person.fullName;
                // only for chat: replace "." with "_"
                user.username = [person.identifier stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                [users addObject:user];
            }
            callback(users);
        }];
        return request;
    }
    return nil;
}

-(AlfrescoRequest *)userById:(NSString *)userId completion:(void (^)(SHPUser *))callback  {
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    AlfrescoRepositorySession *session = app.docSession;
    
    if (session) {
        AlfrescoPersonService *personService = [[AlfrescoPersonService alloc] initWithSession:session];
        AlfrescoRequest *request = [personService retrievePersonWithIdentifier:userId completionBlock:^(AlfrescoPerson *person, NSError *error) {
            NSLog(@"User loaded. Error? %@, Person: %@", error, person);
            SHPUser *user = [[SHPUser alloc] init];
            if (person) {
                user.fullName = person.fullName;
                user.firstName = person.firstName;
                user.lastName = person.lastName;
                user.email = person.email;
            }
            callback(user);
        }];
        return request;
    }
    return nil;
}

@end
