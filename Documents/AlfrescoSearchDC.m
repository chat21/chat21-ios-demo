//
//  AlfrescoSearchDC.m
//  bppmobile
//
//  Created by Andrea Sponziello on 21/08/2017.
//  Copyright © 2017 Frontiere21. All rights reserved.
//

#import "AlfrescoSearchDC.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoRepositorySession.h"
#import "SHPApplicationContext.h"
#import "AlfrescoPagingResult.h"
#import "AlfrescoSearchService.h"
#import "AlfrescoKeywordSearchOptions.h"
#import "AlfrescoFolder.h"

@implementation AlfrescoSearchDC

-(AlfrescoRequest *)documentsByText:(NSString *)text folder:(AlfrescoFolder *)folder completion:(void (^)(NSArray<AlfrescoNode *> *))callback {
    SHPApplicationContext *app = [SHPApplicationContext getSharedInstance];
    AlfrescoRepositorySession *session = app.docSession;
    
    if (session) {
        AlfrescoListingContext *lc = [[AlfrescoListingContext alloc] init];
        lc.maxItems = 20;
        AlfrescoKeywordSearchOptions *options = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:NO includeContent:YES folder:folder includeDescendants:YES];
        AlfrescoSearchService *searchService = [[AlfrescoSearchService alloc] initWithSession:session];
        AlfrescoRequest *request = [searchService searchWithKeywords:text options:options listingContext:lc completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            NSLog(@"Nodes found, error? %@", error);
            NSLog(@"Total nodes found: %d", pagingResult.totalItems);
//            NSMutableArray<AlfrescoNode *> *nodes = [[NSMutableArray alloc] init];
//            for (AlfrescoNode *node in pagingResult.objects) {
//                SHPUser *user = [[SHPUser alloc] init];
//                user.fullName = person.fullName;
//                user.username = [person.identifier stringByReplacingOccurrencesOfString:@"." withString:@"_"];
//                [users addObject:user];
//            }
            callback(pagingResult.objects);
        }];
        return request;
    }
    return nil;
}

@end
