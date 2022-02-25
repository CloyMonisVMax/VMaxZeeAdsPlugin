//
//  VMaxAdDelegate.h


#import <Foundation/Foundation.h>
#import "CompanionInfo.h"
//#import "VmaxDataListener.h"
#import "VMaxAdSDK.h"

@class VMaxAdView;

@protocol VMaxAdAnimationDelegate <NSObject>
@required
- (void)onAnimationStart:(VMaxAdView *)adView;
- (void)onAnimationEnd:(VMaxAdView *)adView;
@end

//3.10.21 //StoryID 892
@protocol VMaxDataDelegate <NSObject>
@required
- (void)onSuccess: (VMaxAdView *)adView Data:(NSString *)data;
- (void)onFailure: (VMaxAdView *)adView Error:(NSError *)error;
@end

/*!
 @protocol  VMaxAdDelegate
 @abstract  Delegate methods called by VMaxAdView class on events.
 */
@protocol VMaxAdDelegate <NSObject>
@required

/*!
 @function  onAdReady:
 @abstract  Called when an ad is loaded via invocation of loadAd()/cacheAd() API's.
 loadAd() will show the ad immediately whereas cacheAd readies it &
 requires showAd() to show.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
- (void)onAdReady:(VMaxAdView *)adView;

/*!
 @function  onAdError:error:
 @abstract  Called when the ad view fails to load an ad.
 @param     adView, VMaxAdView. The ad view which sent this event.
 @param     error, NSError. The error which occured.
 */
- (void)onAdError:(VMaxAdView *)adView error:(NSError *)error;

/*!
 @function  onAdClose:
 @abstract  Called when an ad is about to be unload from the view.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
//3.10.16 Added VMaxAdView
- (void)onAdClose: (VMaxAdView *)adView;

/*!
 @function  onAdMediaEnd:completed:
 @abstract  Called when video ad viewing is completed.
 @param     adView, VMaxAdView. The ad view which sent this event.
 @param     completed, BOOL. Video was watched to completion or not.
 @param     reward, NSInteger. Reward on ad completion.
 */
- (void)onAdMediaEnd:(BOOL)completed reward:(NSInteger)reward : (VMaxAdView *)adView; //Prior 2

@optional
// 3.14.5 shorts
- (void)VMaxUserGestureListener:(VMaxUserGestures)vMaxUserGestures; //zeeShorts Changes 0.0.8
- (void)adAssetClicked:(VmaxAdAsset)elementType;
- (void)onAdSkippable:(VMaxAdView *)adView;
// 3.14.5 shorts
/*!
 @function  onAdMediaStart:
 @abstract  Called when an ad is about to be presented in the view.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
- (void)onAdMediaStart: (VMaxAdView *)adView; //Prior 2

/*!
 @function  onAdClick:
 @abstract  Called when user interacts with an ad via click.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
//3.10.15
- (void)onAdClick: (VMaxAdView *) adView;

/*!
 @function  onAdMediaExpand:
 @abstract  Called when an ad view transitions to an expanded state.
 Example: On clicking a banner, if an interstitial is displayed.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
- (void)onAdMediaExpand:(VMaxAdView *)adView; //Prior 2

/*!
 @function  onAdMediaCollapse:
 @abstract  Called when an ad view transitions back to a normal state.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
- (void)onAdMediaCollapse:(VMaxAdView *)adView; //Prior 2

/*!O
 @function  onAdInterrupted:
 @abstract  Called when video ad viewing is interrupted.
 @param     adView, VMaxAdView. The ad view which sent this event.
 */
- (void)onAdInterrupted:(VMaxAdView *)adView;
//..3.6.12
- (void)onAdRefresh:(VMaxAdView *)adView;
- (void)onAdRender:(VMaxAdView *)adView;

- (void)onAdReceived:(VMaxAdView *)adView; //3.13.1

- (void)onAdMediaProgress:(NSInteger)currentDuration withTotalDuration:(NSInteger)totalDuration withAdView:(VMaxAdView *)adView; //3.14.12 Jio 3.14.5

//3.14.1.3 EventsForKaltura

- (void)onAdPaused:(VMaxAdView *)adView;

- (void)onAdResumed:(VMaxAdView *)adView;

- (void)onAdMediaFirstQuartile:(VMaxAdView *)adView;

- (void)onAdMediaMidpoint:(VMaxAdView *)adView;

- (void)onAdMediaThirdQuartile:(VMaxAdView *)adView;

- (void)onAdImpression:(VMaxAdView *)adView;

- (void)onAdSkipped:(VMaxAdView *)adView;
//3.14.1.3 EventsForKaltura

- (void)onAdMediaBitrateChange:(float)bitrate; //3.14.9

- (void)onAdTapped:(VMaxAdView *)adView;

@end
