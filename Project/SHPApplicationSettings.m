//
//  SHPApplicationSettings.m
//  Shopper
//
//  Created by andrea sponziello on 15/08/12.
//
//

#import "SHPApplicationSettings.h"
#import "SHPStringUtil.h"

@implementation SHPApplicationSettings

@synthesize thisBundle;

@synthesize productListImageCacheSize;
@synthesize productDetailImageCacheSize;
@synthesize smallImagesCacheSize;
@synthesize startWithCategoryAll;
@synthesize showReportAbuse;
@synthesize mainShopId;
@synthesize appColor;
@synthesize appTitleColor;
@synthesize appTitleFont;
@synthesize appTitleFontSize;
@synthesize userProfileBgColor;
@synthesize mainListBgColor;
@synthesize productDetailBgColor;
@synthesize productDetailImageWidth;
@synthesize productDetailImageHeight;
@synthesize mainListBgCellColor;
@synthesize mainListTextUsernameColor;
@synthesize moreResultsButtonColor;
@synthesize mainListTextDescriptionColor;
@synthesize mainListTextShopColor;
@synthesize mainListTextDistanceColor;

@synthesize mainListImageWidth;
@synthesize mainListImageHeight;
@synthesize mainListSearchPageSize;


@synthesize moreResultsButtonHighlighted;

@synthesize productsTablePageSize;
@synthesize fbUrlSchemeSuffix;
@synthesize appTitle;
@synthesize locationTimeout;

- (id) initWithFile:(NSString *)fileName {
    self = [super init];
    
    if (self != nil)
    {
        self.thisBundle = [NSBundle bundleForClass:[self class]];
        UIScreen *mainScreen = [UIScreen mainScreen];
        
        NSString *productListImageCacheSize_s = [thisBundle localizedStringForKey:@"productListImageCacheSize" value:@"KEY NOT FOUND" table:fileName];
        self.productListImageCacheSize = [productListImageCacheSize_s integerValue];
        
        NSString *productDetailImageCacheSize_s = [thisBundle localizedStringForKey:@"productDetailImageCacheSize" value:@"KEY NOT FOUND" table:fileName];
        self.productDetailImageCacheSize = [productDetailImageCacheSize_s integerValue];
        
        NSString *smallImagesCacheSize_s = [thisBundle localizedStringForKey:@"smallImagesCacheSize" value:@"KEY NOT FOUND" table:fileName];
        self.smallImagesCacheSize = [smallImagesCacheSize_s integerValue];
        
        self.fbUrlSchemeSuffix = [thisBundle localizedStringForKey:@"fbUrlSchemeSuffix" value:@"KEY NOT FOUND" table:fileName];
        
        self.appTitle = [thisBundle localizedStringForKey:@"appTitle" value:@"KEY NOT FOUND" table:fileName];
        
        NSString *appColor_s = [thisBundle localizedStringForKey:@"appColor" value:@"KEY NOT FOUND" table:fileName];
        self.appColor = [SHPStringUtil colorFromSettings:appColor_s];
        
        NSString *appTitleColor_s = [thisBundle localizedStringForKey:@"appTitleColor" value:@"KEY NOT FOUND" table:fileName];
        self.appTitleColor = [SHPStringUtil colorFromSettings:appTitleColor_s];
        
        self.appTitleFont = [thisBundle localizedStringForKey:@"appTitleFont" value:@"KEY NOT FOUND" table:fileName];
        
        self.mainShopId = [thisBundle localizedStringForKey:@"mainShopId" value:@"KEY NOT FOUND" table:fileName];
        
        NSString *appTitleFontSize_s = [thisBundle localizedStringForKey:@"appTitleFontSize" value:@"KEY NOT FOUND" table:fileName];
        self.appTitleFontSize = [appTitleFontSize_s floatValue];
        
        NSString *mainListBgColor_s = [thisBundle localizedStringForKey:@"mainListBgColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListBgColor = [SHPStringUtil colorFromSettings:mainListBgColor_s];
        
        NSString *productDetailBgColor_s = [thisBundle localizedStringForKey:@"productDetailBgColor" value:@"KEY NOT FOUND" table:fileName];
        self.productDetailBgColor = [SHPStringUtil colorFromSettings:productDetailBgColor_s];
        
        NSString *mainListBgCellColor_s = [thisBundle localizedStringForKey:@"mainListBgCellColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListBgCellColor = [SHPStringUtil colorFromSettings:mainListBgCellColor_s];
        
        NSString *userProfileBgColor_s = [thisBundle localizedStringForKey:@"userProfileBgColor" value:@"KEY NOT FOUND" table:fileName];
        self.userProfileBgColor = [SHPStringUtil colorFromSettings:userProfileBgColor_s];
        
        NSString *mainListImageWidth_s = [thisBundle localizedStringForKey:@"mainListImageWidth" value:@"KEY NOT FOUND" table:fileName];
        self.mainListImageWidth = [mainListImageWidth_s intValue];
        self.mainListImageWidth = [[UIScreen mainScreen] bounds].size.width * (int)[UIScreen mainScreen].scale;
        
        
        NSString *mainListImageHeight_s = [thisBundle localizedStringForKey:@"mainListImageHeight" value:@"KEY NOT FOUND" table:fileName];
        self.mainListImageHeight = [mainListImageHeight_s intValue];
        self.mainListImageHeight = [[UIScreen mainScreen] bounds].size.height * (int)[UIScreen mainScreen].scale;
        
        
        NSString *productDetailImageWidth_s = [thisBundle localizedStringForKey:@"productDetailImageWidth" value:@"KEY NOT FOUND" table:fileName];
        self.productDetailImageWidth = [productDetailImageWidth_s intValue];
        self.productDetailImageWidth = [[UIScreen mainScreen] bounds].size.width * (int)[UIScreen mainScreen].scale;
        
        NSString *productDetailImageHeight_s = [thisBundle localizedStringForKey:@"productDetailImageHeight" value:@"KEY NOT FOUND" table:fileName];
        self.productDetailImageHeight = [productDetailImageHeight_s intValue];
        self.productDetailImageHeight = [[UIScreen mainScreen] bounds].size.height * (int)[UIScreen mainScreen].scale;
        
        NSString *mainListSearchPageSize_s = [thisBundle localizedStringForKey:@"mainListSearchPageSize" value:@"KEY NOT FOUND" table:fileName];
        self.mainListSearchPageSize = [mainListSearchPageSize_s intValue];
        
        NSString *productsTablePageSize_s = [thisBundle localizedStringForKey:@"productsTablePageSize" value:@"KEY NOT FOUND" table:fileName];
        self.productsTablePageSize = [productsTablePageSize_s intValue];
        
        NSString *locationTimeout_s = [thisBundle localizedStringForKey:@"locationTimeout" value:@"KEY NOT FOUND" table:fileName];
        self.locationTimeout = [locationTimeout_s floatValue];
        
        NSString *uploadImageSize_s = [thisBundle localizedStringForKey:@"uploadImageSize" value:@"KEY NOT FOUND" table:fileName];
        self.uploadImageSize = [uploadImageSize_s intValue];
        
        NSString *moreResultsButtonColor_s = [thisBundle localizedStringForKey:@"moreResultsButtonColor" value:@"KEY NOT FOUND" table:fileName];
        self.moreResultsButtonColor = [SHPStringUtil colorFromSettings:moreResultsButtonColor_s];
        
        NSString *mainListTextDescriptionColor_s = [thisBundle localizedStringForKey:@"mainListTextDescriptionColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListTextDescriptionColor = [SHPStringUtil colorFromSettings:mainListTextDescriptionColor_s];
        
        NSString *mainListTextShopColor_s = [thisBundle localizedStringForKey:@"mainListTextShopColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListTextShopColor = [SHPStringUtil colorFromSettings:mainListTextShopColor_s];
        
        NSString *mainListTextUsernameColor_s = [thisBundle localizedStringForKey:@"mainListTextUsernameColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListTextUsernameColor = [SHPStringUtil colorFromSettings:mainListTextUsernameColor_s];
        
        NSString *mainListTextDistanceColor_s = [thisBundle localizedStringForKey:@"mainListTextDistanceColor" value:@"KEY NOT FOUND" table:fileName];
        self.mainListTextDistanceColor = [SHPStringUtil colorFromSettings:mainListTextDistanceColor_s];
        
        NSString *moreResultsButtonHighlighted_s = [thisBundle localizedStringForKey:@"moreResultsButtonHighlighted" value:@"KEY NOT FOUND" table:fileName];
        self.moreResultsButtonHighlighted = [SHPStringUtil colorFromSettings:moreResultsButtonHighlighted_s];
        
        NSString *startWithCategoryAll_s = [thisBundle localizedStringForKey:@"startWithCategoryAll" value:@"KEY NOT FOUND" table:fileName];
        self.startWithCategoryAll = [startWithCategoryAll_s boolValue];
        
        NSString *showReportAbuse_s = [thisBundle localizedStringForKey:@"showReportAbuse" value:@"KEY NOT FOUND" table:fileName];
        self.showReportAbuse = [showReportAbuse_s boolValue];
    }
    return self;
}

//-(id)getSetting:(NSString *)name {
//    NSString *startWithCategoryAll_s = [thisBundle localizedStringForKey:name value:@"KEY NOT FOUND" table:fileName];
//    self.startWithCategoryAll = [startWithCategoryAll_s boolValue];
//}

@end
