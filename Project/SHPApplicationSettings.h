//
//  SHPApplicationSettings.h
//  Shopper
//
//  Created by andrea sponziello on 15/08/12.
//
//
#import <UIKit/UIKit.h>

@interface SHPApplicationSettings : NSObject
@property (strong, nonatomic) NSBundle *thisBundle;



@property (assign, nonatomic) NSInteger productListImageCacheSize;
@property (assign, nonatomic) NSInteger productDetailImageCacheSize;
@property (assign, nonatomic) NSInteger smallImagesCacheSize;
@property (strong, nonatomic) UIColor *appColor;
@property (strong, nonatomic) UIColor *appTitleColor;
@property (strong, nonatomic) NSString *appTitleFont;
@property (assign, nonatomic) float appTitleFontSize;
@property (assign, nonatomic) BOOL startWithCategoryAll;
@property (assign, nonatomic) BOOL showReportAbuse;
@property (strong, nonatomic) NSString *mainShopId;
@property (strong, nonatomic) NSString *fbUrlSchemeSuffix;
@property (strong, nonatomic) NSString *appTitle;
@property (strong, nonatomic) UIColor *userProfileBgColor;
@property (strong, nonatomic) UIColor *mainListBgColor;
@property (strong, nonatomic) UIColor *productDetailBgColor;
@property (assign, nonatomic) NSInteger productDetailImageWidth;
@property (assign, nonatomic) NSInteger productDetailImageHeight;
@property (assign, nonatomic) NSInteger uploadImageSize;
@property (strong, nonatomic) UIColor *mainListBgCellColor;
@property (strong, nonatomic) UIColor *mainListTextDescriptionColor;
@property (strong, nonatomic) UIColor *mainListTextShopColor;
@property (strong, nonatomic) UIColor *mainListTextUsernameColor;
@property (strong, nonatomic) UIColor *mainListTextDistanceColor;
@property (assign, nonatomic) NSInteger mainListImageWidth;
@property (assign, nonatomic) NSInteger mainListImageHeight;
@property (assign, nonatomic) NSInteger mainListSearchPageSize;
@property (strong, nonatomic) UIColor *moreResultsButtonColor;
@property (strong, nonatomic) UIColor *moreResultsButtonHighlighted;
@property (assign, nonatomic) NSInteger productsTablePageSize;
@property (assign, nonatomic) float locationTimeout;

//-(id)getSetting:(NSString *)name;

-(id)initWithFile:(NSString *)fileName;

@end
