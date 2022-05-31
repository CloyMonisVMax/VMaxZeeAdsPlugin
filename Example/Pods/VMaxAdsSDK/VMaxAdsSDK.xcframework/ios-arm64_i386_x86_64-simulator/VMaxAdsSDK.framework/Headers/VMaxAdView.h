//
//  VMaxAdView.h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#import "VMaxAdSDK.h"
#import "VMaxAdDelegate.h"
#import "VMaxAdPartner.h"
#import "VMaxNativeAd.h"
#import "VMaxVideoAd.h"
#import "VMaxAdSettings.h"
#import "VMAXPageCategory.h"
#import "VMAXSectionCategory.h"
#import "VMaxAdCustomizer.h"
#import "VmaxAdInfo.h"
#import "VMaxCompanionDelegate.h"
#import "ICompanionEventsReceiver.h"
#import "VMaxAd.h"

/*!
 Keys to coustumize the VMaxAdView appearience.
 
 @field VMaxAdView_BackgroundColor:
 Background color of the AdView. Should be UIColor object. This property is applicable for Banner and interstetial ads.
 
 @field VMaxAdView_CloseButtonPosition:
 Close button placement of ads. Should be a NSNumber with VMaxAdCloseButtonPlacement element.
 
 @field VMaxAdView_FrameColor:
 Frame colour of adView. Should be UIColor object. Applicable to both Banner and Interstetial ads.
 
 @field VMaxAdView_Transparence:
 Transperence of adView. Should be NSNumber of float value. Value between 0 and 1. 0 = Full Opaque. 1 = Full Transperent.
 */
extern NSString* const VMaxAdView_BackgroundColor;
extern NSString* const VMaxAdView_CloseButtonPosition;
extern NSString* const VMaxAdView_FrameColor;
extern NSString* const VMaxAdView_Transparence;
extern NSString* const VMaxAdView_AdSize;
extern NSString* const VMaxAdView_Scale;
extern NSString* const VMaxAdViewAdmob_NativeAdSize;

extern NSString* const MEDIA_URL;
extern NSString* const AD_EVENTS_NOTIFIER;
extern NSString* const SKIPPABLE_TIME;
extern NSString* const STATIC_RESOURCE;
extern NSString* const HTML_RESOURCE;
extern NSString* const kVMaxNotificationHideCompanion;
extern NSString* const kVMaxNotificationUnHideCompanion;
extern NSString* const kVMaxAdSlotId;

/*!
 @enum      VMaxAdState
 @abstract  Internal states of ads.
 @field     kVMaxAdState_RequestSent, New request for ad has been sent. Yet to receive the responce from adServer.
 @field     kVMaxAdState_Cached, Ad is cached and ready to be displayed. Ads will be inthis state if user
 calls cacheAd and caching is successful.
 @field     kVMaxAdState_CacheFailed, Ad caching is failed. Ads will be in this state when user called
 cacheAd and request to server failed due to some reason. When caching fails
 adView: onAdError:error: is invoked with error.
 @field     kVMaxAdState_Loaded, Ad is loaded and is being displayed.
 @field     kVMaxAdState_Failed, Communication to adserver failed.
 */



typedef NS_ENUM(NSUInteger, VMaxAdState) {
    
    kVMaxAdState_Ad_Not_Requested,
    kVMaxAdState_Ad_Requested, //kVMaxAdState_Ad_Request_InProgress   -- RENAMED
    kVMaxAdState_Ad_Received, // ADDED IN SDK-VSERSION(3.10.4)        -- NEWLY ADDED
    kVMaxAdState_Ad_Ready,
    kVMaxAdState_Ad_Error,
    kVMaxAdState_Ad_Started,    //kVMaxAdState_Ad_Media_Start   -- RENAMED
    kVMaxAdState_Ad_End,       // kVMaxAdState_Ad_Media_End     -- RENAMED
    kVMaxAdState_Ad_Dismissed, //kVMaxAdState_Ad_Close          -- RENAMED
    kVMaxAdState_Ad_Expand,    // kVMaxAdState_Ad_Media_Expand  -- RENAMED
    kVMaxAdState_Ad_Collapsed,  // kVMaxAdState_Ad_Media_Collapse -- RENAMED
    kVMaxAdState_Ad_Interacted  // kVMaxAdState_Ad_Click          -- RENAMED

    //  kVMaxAdState_Ad_Interrupted                               -- REMOVED
    //    kVMaxAdState_Ad_Paused,                                 -- REMOVED
    //    kVMaxAdState_Ad_Resumed,                                -- REMOVED
};


/*!
 @enum      VMaxAdViewState
 @abstract  View State of Adview.
 @field     kVMaxAdViewState_Instantiated,
 @field     kVMaxAdViewState_Not_Instantiated,
 @field     kVMaxAdViewState_Inview,
 */
typedef NS_ENUM(NSUInteger, VMaxAdViewState) {
    
    kVMaxAdViewState_Not_Instantiated,
    kVMaxAdViewState_Instantiated,
    kVMaxAdViewState_Inview
};



/*!
 @enum      VMaxTestMode
 @abstract  Test Mode of Adview.
 @field     kVMaxTestMode_NOT_AVAILABLE,
 @field     kVMaxTestMode_TEST_via_ADVID,
 @field     kVMaxTestMode_TEST_via_ID_FROM_NETWORKS,
 @field     kVMaxTestMode_TEST_FOR_ALL_DEVICES,
 */
typedef NS_ENUM(NSUInteger, VMaxTestMode) {
    kVMaxTestMode_NOT_AVAILABLE,
    kVMaxTestMode_TEST_via_ADVID,
    kVMaxTestMode_TEST_via_ID_FROM_NETWORKS,
    kVMaxTestMode_TEST_FOR_ALL_DEVICES,
    
};

/*!
 @enum      VMaxAdCloseButtonPlacement
 @abstract  Placement position of close button on ads. Eventhough closebutton placement is set by the user,
 the ad can override this property and display close button in some other position.
 @field     kVMaxAdCloseButtonPlacement_None, No preference for close button placement.
 @field     kVMaxAdCloseButtonPlacement_TopLeft, Close button placed top left corner of the VMaxAdView.
 @field     kVMaxAdCloseButtonPlacement_TopRight, Close button placed top right corner of the VMaxAdView.
 @field     kVMaxAdCloseButtonPlacement_BottomLeft, Close button placed bottom left corner of the VMaxAdView.
 @field     kVMaxAdCloseButtonPlacement_BottomRight, Close button placed bottom right corner of the VMaxAdView.
 */
typedef NS_ENUM(NSUInteger, VMaxAdCloseButtonPlacement) {
    kVMaxAdCloseButtonPlacement_None,
    kVMaxAdCloseButtonPlacement_TopRight,
    kVMaxAdCloseButtonPlacement_TopLeft,
    kVMaxAdCloseButtonPlacement_BottomRight,
    kVMaxAdCloseButtonPlacement_BottomLeft,
};

/*!
 @enum      VMaxAdUX
 @abstract  The UX Type of the required Ad. User needs to set this property to the SDK.
 @field     kVMaxAdUX_Interstitial, Interstetial UX Type.
 @field     kVMaxAdUX_Banner, Banner UX Type.
 */
typedef NS_ENUM(NSUInteger, VMaxAdUX) {
    //kVMaxAdUX_Uninitialized,
    kVMaxAdUX_Interstitial,
    kVMaxAdUX_Banner,
    kVMaxAdUX_Native,
    kVMaxAdUX_Native_Infeed,
    kVMaxAdUX_Native_Icon,
    kVMaxAdUX_Native_ContentStream,
    kVMaxAdUX_Billboard,
    kVMaxAdUX_InStreamVideo,
    kVMaxAdUX_InStreamAudio
};

typedef NS_ENUM(NSUInteger, VMaxRequestType) {
    kVMaxVMAPRequestType,
};

/*!
 @enum      VMaxAdOrientation
 @abstract  The orientation for the requested ad.
 @field     kVMaxAdOrientation_Adaptive, Ad capable of displaying in any orientation.
 @field     kVMaxAdOrientation_Portrait, Ad capable of displaying in portrait orientation.
 @field     kVMaxAdOrientation_Landscape, Ad capable of displaying in landscape orientation.
 */
typedef NS_ENUM(NSUInteger, VMaxAdOrientation) {
    kVMaxAdOrientation_Adaptive,
    kVMaxAdOrientation_Portrait,
    kVMaxAdOrientation_Landscape
};
typedef NS_ENUM(NSUInteger, CacheMode) {
    CACHE_MODE_NONE,
    CACHE_MODE_VIDEO,
    CACHE_MODE_AUDIO, //..(3.11.0) DAAST
    CACHE_MODE_IMAGE,//3.10.16 Added
    CACHE_MODE_ALL,//3.10.16 Added
};
typedef NS_ENUM(NSUInteger, MediaQuality) {
    SDK_CONTROLLED,
    SD,
    HD
};

typedef NS_ENUM(NSUInteger, VMaxAdTag) {
    vmax_native_title = 2000,
    vmax_native_image_icon,
    //    vmax_native_image_main, //.. REMOVED (3.10.6) USE MEDIA-LAYOUT TAG (vmax_native_media_layout)
    //vmax_native_image_medium, //.. REMOVED (3.10.6)
    vmax_native_description,
    vmax_native_cta_text,
    vmax_native_media_layout,  // (3.10.6) PRIORITY: 1. VIDEO 2. IMAGE MAIN
    vmax_native_adchoice,
    vmax_native_tagline,
    vmax_native_rating,
    vmax_native_downloads,
    vmax_native_sale_price,
    vmax_native_likes,
    vmax_native_price,
    vmax_native_phone,
    vmax_native_address,
    vmax_native_display_url,
    vmax_native_container,
    vmax_native_custom_image,
    vmax_native_advertiser_name
};

//3.14.1.1 Video tagging
typedef NS_ENUM(NSUInteger,VMaxAdVideoTag) {
    vmax_video_player_container = 5000,
    vmax_video_cta,
    vmax_video_volume_icon,
    vmax_video_skip_element,
    vmax_video_playback_icon,
    vmax_video_progresscount,
    vmax_video_progressbar,
    vmax_video_expand,
    vmax_video_skip_action,
    vmax_video_ad_text,
    vmax_video_companion,
    vmax_video_player_container_superview
    
};
//3.14.1.1 Video tagging

typedef NS_ENUM(NSUInteger, VMaxVolumeEvents) {
    MUTED = 1,
    UNMUTED = 2,
    VOLUME_CHANGE
};

// Tagging Approach
/*
typedef NS_ENUM(NSUInteger, VMaxAdVideoTag) {
    vmax_video_player_container = 5000,
    vmax_video_volume_icon,
    vmax_video_skip_element,
    vmax_video_playback_icon,
    vmax_video_progresscount,
    vmax_video_progressbar,
    vmax_video_close,
    vmax_video_viewadvertisement,
    vmax_video_skipcount,
    vmax_video_play,
    vmax_video_videocount,
    vmax_video_mute,
    vmax_video_expand
};
*/

/*!
 @enum      VMaxAdView
 @abstract  This is the main API interface of VMaxAdSDK. Confirm to VMaxAdDelegate protocol to receive the SDK messages.
 App Developers needs to set the frame of VMaxAdView by calling setFrame:(CGRect)inFrame before any of the Ad request is made.
 Ad Request methods are cacheAd, loadAd and showAd.
 
 For proper display of Ads the Zone ID must be properly set according to the AdType (Interstetial or Banner).
 For interstetial ad type Auto Refresh iof ads are not allowed. Hence any of the refresh methods dosent have any impact.
 
 For banner Ad Type If user wanto to have presize control over the ads he can opt for manual handling of ad caching and display.
 So he can use cacheAd to cache the ad in background. On cache complete SDK notifies user by delegate method
 - (void)onAdReady:(VMaxAdView *)theAdView
 The nuser can display the ad using showAd method. On ad display complete the SDK notifies user by delegate method
 - (void)onAdReady:(VMaxAdView *)theAdView
 For banner Ad type if the user doesent want to hace presize control ever the ad display, he can set the frame of VMaxAdView and call loadAd.
 The user will get callback
 - (void)onAdReady:(VMaxAdView *)theAdView
 when first ad is loaded. Subsequest refreshed ads dosent notifies the user of adRefresh. The default Refresh time is 20 seconds.
 User can set the Refresh time other than this by calling -(void)setRefreshRate:(UInt32)inRefreshIntervalInSeconds
 
 NOTE: Before any ads can be requested the user needs to set the frame of the VMaxADView to display the ad properly.
 */
@interface VMaxAdView : UIView

@property (nonatomic, assign) NSTimeInterval animationDelay;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;
@property (nonatomic, assign) BOOL animationEnabled;


@property (weak, nonatomic) id<VMaxAdDelegate> delegate;
//3.10.21
@property (weak, nonatomic) id<VMaxDataDelegate> dataDelegate;
@property (strong, nonatomic, readonly) NSString *adspotID;
@property (strong, nonatomic) UIViewController *hostController,*presentedviewController;
@property (assign, nonatomic, readonly) VMaxAdUX adUXType;
@property (nonatomic, readonly) VMaxAdPartner *adPartner;
@property (nonatomic, strong) VMaxAdSettings *adSettings;
@property (strong, nonatomic) VMaxAdCustomizer *adCustomizer; //..(3.6.46) Added
@property (nonatomic, assign) BOOL isRewarded;
//Audio
// 3.14.5 shorts
@property (nonatomic, strong) VMaxAd *getVmaxAd;
@property (strong, nonatomic) id customclasses;

// 3.14.5 shorts
@property (nonatomic) NSInteger inputBitrate;
@property (nonatomic, strong) NSDictionary *moatLevelDictionary;
@property (nonatomic) AVPlayer *playerObject;
@property (nonatomic) AVPlayerLayer *playerLayer; //482 added
@property (nonatomic) UIView *viewObject;
@property (strong, nonatomic) NSLayoutConstraint *nativeAdChoiceTrialingConstraint; //..(3.6.46) Added
@property (assign,nonatomic) int latencyPerAdFromConfig;//..(3.11.7) ADDED
@property (strong, nonatomic) id<VMaxCompanionDelegate> delegateCompanion; //3.14.3 S_476 pa
@property (strong, nonatomic, readonly) NSString *adslotID; //3.15.4 adslot 

- (NSDictionary*)getAdditionalParameters;

//3.14.1.1 Video tagging TO_Review
@property (nonatomic) BOOL isVideoViewTagged;
//3.14.1.1 Video tagging TO_Review

//3.10.21
-(void)triggerDataDelegate;
/*!
 @function      initWithadspotID: viewController: withAdUXType
 @abstract      Init method to initilize the VMaxAdView. Use
 @param         inadspotID, NSString. Zone ID for the Ad. Zone ID can be for Banner or Bilboard.
 @param         inHostViewController, UIViewController. The video controller in which the Ad will be rendered. This will be used for displaying Full screen Billoard ads.
 @param         inAdUXType, VMaxAdUX. Ad UX type from struct VMaxAdUX.
 */
-(id)initWithAdspotID:(NSString*)inAdspotID
       viewController:(UIViewController*)inHostViewController
         withAdUXType:(VMaxAdUX)inAdUXType;

/*!
 @function      setCustomVideo:
 @abstract      setting custom video object for customising vast video ads
 @param         customVideoAd,VMaxVideoAd object.
 */
-(void)setCustomVideo:(VMaxVideoAd*)customVideoAd;

/*!
 @function      playAd
 @abstract      Use this method to play incontent video ads if paused.
 */
- (void)playAd;

/*!
 @function      pauseAd
 @abstract      Use this method to pause incontent video ads if playing.
 */
- (void)pauseAd;

///*!
// @function      setVideoControlHidden
// @abstract      Use this method to hide and show incontent video controls
// */
//- (void)setVideoControlsHidden:(BOOL)isHidden;  //..DEPRECATED USE AD CUSTOMIZER PROPERTY
/*!
 @function      setVideoPlayerDetails:
 @abstract      Set the video player details for 'In Content Video' in order to deliver video ads
 @param         contentPlayerContainerView, UIView, the contentPlayer container view.
 */
-(void)setVideoPlayerContainerView:(UIView *)contentPlayerContainerView;
///*!
// @function      setRefresh:
// @abstract      Call this method to enable or disable refresh property. Before setting the refresh use setRefreshRate: to override the default refresh rate of 30 seconds. By default for banner ads refresh is ON and for interstetial ads refresh is always off.
// @param         shouldEnableRefresh, BOOL. If YES Refresh is enabled. If NO Refresh is disabled.
// */
//
//-(void)setRefresh:(BOOL)shouldEnableRefresh;

/*!
 @function      setRefreshRate:
 @abstract      Call this method to set the refresh rate. This overrides the default refresh rate of 30 seconds.
 @param         inRefreshIntervalInSeconds, UInt32. Refresh rate in seconds. Value should be greater than 30 seconds.
 */
-(void)setRefreshRate:(UInt32)inRefreshIntervalInSeconds;

/*!
 @function      getRefreshRate:
 @abstract      Call this method to get the refresh rate.
 */
-(UInt32)getRefreshRate;

/*!
 @function      setTimeout:
 @abstract      Set the Ad Request timeout. Default timeout is 20 seconds.
 @param         inTimeout, UInt32. Timeout period in seconds.
 */
-(void)setTimeout:(UInt32)inTimeout;

/*!
 @function      setPodTimeout:
 @abstract      Set the Pod timeout.
 @param         inTimeout, UInt32. Timeout period in seconds.
 */
-(void)setPodTimeout:(UInt32)inTimeout;

/*!
 @function      setUXType: withConfig:
 @abstract      Set the Configration properties and display properties for Ads.
 @param         inAdUXType, VMaxAdUX. Ad Type. Must be same as passed in init method.
 @param         inConfig, NSDictionary. Dictionary specifying the display properties of Ads. Posible properties are VMaxAdView_BackgroundColor, VMaxAdView_CloseButtonPosition, VMaxAdView_FrameColorVMaxAdView_Transparence;
 */
-(void)setUXType:(VMaxAdUX)inAdUXType
      withConfig:(NSDictionary*)inConfig;

/*!
 @function      setWebViewBackgroundColor:
 @abstract      Set WebView Background color
 @param         backgroundColor, The color that should used to for webView baground.
 */
-(void)setWebViewBackgroundColor:(UIColor*)backgroundColor;
/*!
 @function      cacheAd
 @abstract      Manually cache the ad in background. Ad will not be displayed. On success onAdReady: method will be called by SDK.
 On Failure onAdError:error: will be called by SDK. When this method is called Auto Refresh is automatically disabled.
 */
-(void)cacheAd;

/*!
 @function      showAd
 @abstract      Use this method in conjunction with cacheAd. If the ad is cached in background in responce to cacheAd or cacheAdWithorientation, this method will display the cache ad on screen. For Billboard ads, this method puts full screen overlay on screen.
 */
// 3.14.5 shorts
//-(void)prepareOrganicAd:(NSString *)ad headers:(NSDictionary *)headers;
//-(void)prepareOrganicAd:(NSString *)ad headers:(NSDictionary *)headers adId:(NSString *)adId;
-(void)prepareOrganicAd:(NSString *)ad headers:(NSDictionary *)headers adId:(NSString *)adId fcapDict:(NSDictionary *)fcapDict cid:(NSString *)cid; //added for fcap shorts
- (void)setAdOption:(AdOptionKey)adOptionKey adOptionValue:(AdOptionValue)adOptionValue;
// 3.14.5 shorts

-(void)showAd;

/*!
 @function      cancelAd
 @abstract      Cancel the request sent to ad server. Call this method if you have called cacheAd and you do not want to display that ad before adViewDidCacheAd is fired.
 */
-(void)cancelAd;

/*!
 @function      getAdState
 @abstract      Retrives the state of the ad.
 @return        VMaxAdState, value from VMaxAdState structure.
 */
-(VMaxAdState)getAdState;

//..(3.6.44)
-(VMaxAdViewState)getState;

/*!
 @function      setTestMode:withDevices
 @abstract      Set the test mode.
 @param         testMode, VMaxTestMode
 @param         inDeviceIDFAList, NSArray, Test device array.
 */
-(void)setTestMode:(VMaxTestMode)testMode withDevices:(NSArray*)inDeviceIDFAList;
/*!
 @function      setLanguageOfArticle:
 @abstract      Sets the Language of Article.
 @param         inlanguageofArticle, Language of Article.
 */
-(void)setLanguageOfArticle:(NSString*)inlanguageofArticle;
/*!
 @function      setKeyword:
 @abstract      Sets the setKeyword
 @param         keyword, Keyword
 */
-(void)setKeyword:(NSString*)keyword;
/*!
 @function      setCustomData:
 @abstract      Sets the CustomData
 @param         customData, CustomData
 */
-(void)setCustomData:(NSDictionary*)customData;

/*!
 @function      setContentURL:
 @abstract      Sets the contentUrl
 @param         contentUrl, contentUrl
 */
- (void)setContentURL:(NSString*)contentUrl;

/*!
 @function      getNativeAd
 @abstract      Retrive NativeAd object
 @return        NativeAd, object got from the json resposne
 */
-(VMaxNativeAd*)getNativeAd; //..3.6.12. DEPRECATE
/*!
 @function      getRawVASTMarkup
 @abstract      Retrive VastAdO object
 @return        VastAd Data String
 */
-(NSString*)getMarkup;
/*!
 @function      setCustomVideoIsFullscreen
 @abstract      Notify adview is displaying fullscreen (on/off) in pre-roll
 */
- (void)setCustomVideoIsFullscreen:(BOOL)isFullscreen;

//+(void)setConfigURL:(NSString*)inConfigURL;
//
//+(NSString*)getConfigURL;

-(void)invalidateAd;//..3.6.0
//Audio
- (void)setRequestedBitrate:(NSInteger)inputBitrate;
//..3.6.12
-(void)setCustomNativeAdContainer:(UIView *)customeUiView;

- (void)setContainer:(UIView *)adDisplayContainer;

- (void)setPlayer:(AVPlayer *)playerObject;

//- (NSString *)getAssets;
- (NSDictionary *)getAssets;
/*!
 @function      setSection:
 @abstract      setting section
 @param         section, Section
 */
-(void)setSectionCategory:(VMAXSectionCategory *)sectionCategory;

-(void) setPageCategory:(VMAXPageCategory *)pageCategory;

-(BOOL)closeAd;

-(void)setCloseAfter:(int)closeAfter;

-(void)hideControls;

-(void)showControls;

-(void)toggleFullScreenButtonWithStatus:(BOOL)state;

//..(3.8.7) Added for AdMob AdBadge position.
typedef NS_ENUM(NSInteger, VMaxAdChoicePlacement)
{
    kVmax_AdChoices_Top_Left,
    kVmax_AdChoices_Top_Right,
    kVmax_AdChoices_Bottom_Left,
    kVmax_AdChoices_Bottom_Right
};

-(void)setAdchoicePlacement:(VMaxAdChoicePlacement)adBadgePlacementPosition;

-(void)setNativeMuteStateForNonFullscreen:(BOOL)muteUnMuteState;
-(void)pauseRefresh;
-(void)resumeRefresh;
-(void)setRequestedAdDuration:(int)duration;

//..JIO
@property (strong, nonatomic,getter=getBundleIdentifier) NSString *bundleIdentifier; //..(3.10.3) Added
-(void)enableMediaCaching:(CacheMode)mode;
-(void)requestMediaQuality:(MediaQuality)quality;
-(void)setEnableAdStorage:(BOOL)enableState;
-(void)setAdTimeout:(UInt32)inTimeout;

//..(3.10.5) ADDED DYNAMIC INTERSTIAL CUSTOMIZATION API'S
typedef NS_ENUM(NSUInteger, AdCategory) {
    AD_CATEGORY_NATIVE,
    AD_CATEGORY_VIDEO
};

-(void)setCustomNativeAdContainer :(UIView *)portraitUIView forLandscapeView:(UIView*)landscapeUIView forAdCategory:(AdCategory) adCategory;

-(void)setInstreamDaastContainer:(UIView *)audioNativeContainer containerWidth :(int)width containerHeight:(int) height; //.. (3.11.0) ADDED FOR DAAST STORY
//..

-(void)setBackgroundColor:(UIColor *)backgroundColor;

#pragma mark CompanionAdChanges

typedef NS_ENUM(NSUInteger,VMaxAdType) {
    none = 1,
    primary,
    companion
};

typedef NS_ENUM(NSUInteger,VMaxCompanionState) {
    STATE_DEFAULT_STATE = 1,
    STATE_INSTANTIATED,
    STATE_PAUSED,
    STATE_RESUMED,
    STATE_AD_CACHED,
    STATE_AD_SHOWN,
    STATE_AD_CONSUMED
};

//3.14.9 VMaxAdType refactor
//@property (nonatomic,assign) VMaxAdType adType;
-(void)setAdType:(VMaxAdType)adType;
//..

@property (nonatomic) VMaxCompanionState companionState;

//@property (nonatomic,weak) UIView *viewForVMax;

@property (weak, nonatomic) id<ICompanionEventsReceiver> delegateCompanionReceiver;

#pragma mark Vmax Plugin Layout getAdParams

//3.14.9 @property(nonatomic) NSMutableDictionary *adParams;
@property (nonatomic) VmaxAdInfo *adInfo;

//3.14.9
///*!
//@function      getAdditionalParameters:
//@abstract      getting AdParams Object From the VAST document
//*/
//- (NSDictionary*)getAdParams;

-(void)setLayoutInfo:(NSDictionary*)layoutInfo;

@end



