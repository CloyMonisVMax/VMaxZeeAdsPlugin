//
//  VMaxNativeAd.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VMaxAdView.h"

@class VMaxNativeAd;
@class VMaxAdView;
@class VMaxMediaView;
typedef NS_ENUM(NSUInteger, VMaxNativeAdType) {
    kVMaxNativeAdType_Infeed,
    kVMaxNativeAdType_ContentStream,
    kVMaxNativeAdType_ContentAd,
    kVMaxNativeAdType_AppInstall,
    kVMaxNativeAdType_UnifiedAd, //..(3.6.7) AdMob(Unified Ad)
    kVMaxNativeAdType_MediaView
};

@interface VMaxAdImage: NSObject

/*!
 @property
 @abstract url of image
 */
@property (nonatomic, copy, readonly) NSURL *url;

/*!
 @property
 @abstract width of the image
 */
@property (nonatomic, assign, readonly) NSInteger width;

/*!
 @property
 @abstract height of the image
 */
@property (nonatomic, assign, readonly) NSInteger height;

/*!
 @property
 @abstract image will be nil if autoloading property is not set true
 */
@property (nonatomic, strong) UIImage* image;

- (instancetype)initWithURL:(NSURL*)url
                              width:(NSInteger)width
                     height:(NSInteger)height;

- (instancetype)initWithUIImage:(UIImage*)image;

- (void)loadImageAsyncWithBlock:(void (^)(UIImage *image))block;
//3.10.16
- (void)downLoadImageAndCacheWithDictName:(NSString *)dictName WithBlock:(void (^)(UIImage *image))block;

// 3.10.18 get image synschronusly
-(UIImage *)downLoadImageSynschronuslyWithDictName:(NSString *)dictName;

- (void)cancelLoading;
//..3.6.12
-(UIImage *)downLoadImage;

@end

@class VMaxAdView;

@interface VMaxNativeAd : NSObject

@property (assign,nonatomic) NSInteger adContentType; // 3.11.10 Added

@property (assign,nonatomic)BOOL isImpressionFiredAd; // 3.11.7 Added

@property (assign) BOOL disablePreparePlayer; //3.12.1 Added

//.. 3.6.10
@property (assign,nonatomic) VMaxAdView *native_AdView;
/*!
 @property
 @abstract indicates if ad choice icon will display, if NO, one must display an ad indicator as per mediation specs
 */
@property (nonatomic, readonly) BOOL willDisplayAdChoice;

/*!
 @property
 @abstract name of the native ad partners
 */
@property (strong,nonatomic,getter=getNativeAdPartner) NSString* nativeAdPartner;

/*!
 @property
 @abstract type of native ad
 */
@property (assign,nonatomic,getter=getNativeAdType) VMaxNativeAdType nativeAdType;

/*!
 @property
 @abstract title
 */
@property (strong,nonatomic,getter=getTitle) NSString* title;

/*!
 @property
 @abstract call to action text
 */
@property (strong,nonatomic,getter=getCtaText) NSString* ctaText;

/*!
 @property
 @abstract objective
 */
@property (strong,nonatomic,getter=getObjective) NSString* objective;

/*!
 @property
 @abstract imageIcon,image of size 48X48
 */
@property (strong,nonatomic,getter=getImageIcon) VMaxAdImage* imageIcon;

@property (strong,nonatomic,getter=getImageCustom) VMaxAdImage* imageCustom;

/*!
 @property
 @abstract imageIcon,image of size 300X250
 */
@property (strong,nonatomic,getter=getImageMedium) VMaxAdImage* imageMedium;

/*!
 @property
 @abstract imageIcon,image of size 1200X628
 */
@property (strong,nonatomic,getter=getImageMain) VMaxAdImage* imageMain;

/*!
 @property
 @abstract imageIcon,image of size 320X50
 */
@property (strong,nonatomic,getter=getImageBanner) VMaxAdImage* imageBanner;

/*!
 @property
 @abstract imageIcon,image of size 750X750
 */
@property (strong,nonatomic,getter=getImageTile) VMaxAdImage* imageTile;

/*!
 @property
 @abstract number  of likes
 */
@property (strong,nonatomic,getter=getDesc) NSString* desc;

/*!
 @property
 @abstract number  of likes
 */
@property (strong,nonatomic,getter=getRating) NSString* rating;

/*!
 @property
 @abstract number  of likes
 */
@property (strong,nonatomic,getter=getSalePrice) NSString* salePrice;

/*!
 @property
 @abstract number  of likes
 */
@property (strong,nonatomic,getter=getPrice) NSString* price;


/*!
 @property
 @abstract number  of likes
 */
//@property (strong,nonatomic,getter=getSponsored) NSString* sponsored; //..REMOVED(3.10.5)

/*!
 @property
 @abstract number  of likes
 */
@property (strong,nonatomic,getter=getLikes) NSString* likes;

/*!
 @property
 @abstract phone number
 */
@property (strong,nonatomic,getter=getPhone) NSString* phone;

/*!
 @property
 @abstract address
 */
@property (strong,nonatomic,getter=getAddress) NSString* address;

/*!
 @property
 @abstract description
 */
@property (strong,nonatomic,getter=getDesc2) NSString* desc2;

@property (strong,nonatomic,getter=getAdvertiser_Name) NSString* advertiser_Name; //..(3.7.3)

/*!
 @property
 @abstract displayUrl
 */
@property (strong,nonatomic,getter=getDisplayUrl) NSString* displayUrl;

/*!
 @property
 @abstract number of downloads
 */
@property (strong,nonatomic,getter=getDownloadss) NSString* downloads;

/*!
 @property
 @abstract Facebook mediaview
 */
@property (strong,nonatomic,getter=getView) UIView* view;

/*!
 @property
 @abstract vastVideoTag,VMax Vast VideoTag
 */
@property (strong,nonatomic,getter=getVastVideoTag) NSString *vastVideoTag;

/*!
 @property
 @abstract start download the images it is set true.It will be false by default
 */
@property (assign,nonatomic) BOOL autoLoading;

//3.15.2 1161.1
/*!
 @property
 @abstract layout name
 */
@property (strong,nonatomic,getter=getLayout) NSString* layout;

@property (strong, nonatomic) NSString *adSpotId;//(MOAT)

/*!
 @function      setLinkUrl
 @abstract      set Link Url
 @param         linkUrl,linkUrl
 */
-(void) setLinkUrl:(NSString *)linkUrl;
/*!
 @function      setLinkFallback
 @abstract      set linkFallback url
 @param         linkFallback,linkFallback
 */
-(void)setLinkFallback:(NSString *)linkFallback;

/*!
 @function      setLinkClickTrackers:
 @abstract      seting LinkClickTrackers
 @param         linkClickTrackers,linkClickTrackers.
 */
-(void) setLinkClickTrackers:(NSArray *)linkClickTrackers;


/*!
 @function      reportAndHandleAdClick
 @abstract      report Ad Click and Open the link Url if for vmax and inmobi ads
 */
-(void) reportAndHandleAdClick;
/*!
 @function      setImpTrackers:
 @abstract      setting click trackers
 @param         impTrackers,impTrackers.
 @param         view,view which  holds the nativeAd elements.
 */
-(void) setImpTrackers:(NSArray *)impTrackers;


/*!
 @function      registerViewForInteraction:view:listOfViews
 @abstract      registering native ad for interaction
 @param         adView,AdView.
 @param         view,view which  holds the nativeAd elements.
 @param         listOfViews, List of views which should be clickable.
 */
-(void)registerViewForInteraction:(VMaxAdView*)adView view:(UIView*)view listOfViews:(NSArray*)listOfViews;

/*!
 @function      sizeImage:toView
 @abstract      aspect fit an image to a UIImageView
 @param         image,UIImage.
 @param         imageView,UIImageView which  holds the image.
 */
- (void)sizeImage:(UIImage*)image toView:(UIImageView*)imageView;
//..3.6.12
@property (strong,nonatomic,getter=getAdChoiceView) UIView * choiceView;

// OM

//@property (strong,nonatomic,getter=getVendorKey) NSString* strVendorkey;
//@property (strong,nonatomic,getter=getJavascriptResourceUrl) NSString* strJavascriptResourceUrl;
//@property (strong,nonatomic,getter=getVerificationParameters) NSString* strVerificationParameters;
@property (strong,nonatomic,getter=verificationResourceArray) NSMutableArray* verificationResourceArray;  //662 story
@property (nonatomic,getter=isVideoAd) BOOL isVideoAd; //662 story
@end
