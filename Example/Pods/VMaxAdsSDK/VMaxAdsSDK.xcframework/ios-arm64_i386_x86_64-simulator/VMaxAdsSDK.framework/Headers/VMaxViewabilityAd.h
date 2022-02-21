//
//  VMaxViewabilityAd.h


#ifndef VMaxViewabilityAd_h
#define VMaxViewabilityAd_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "VMaxViewabilityTracker.h"
#import <WebKit/WebKit.h>
#import "VMaxAdView.h"

@protocol VMaxViewabilityAd <NSObject>

@required
- (void)createViewabilityInstance;

@optional
@property(nonatomic,weak) id mediaselector;
//MOAT webview Display_123rrr

//3.12.0___Display
//- (void)registerDisplayAd:(UIWebView *)webView;
- (void)registerDisplayAd:(WKWebView *)webView;

- (void)displayStartTracking;
- (void)displayStopTracking;

//MOAT Native Video
- (void)startVastAdSessionUsingDictionary:(NSDictionary *)dictionaryValue;
- (void)endVastAdSession;

// MOAT_CUSTOM_LAYER_

//MOAT Native Display
- (void)registerNativeAdSessionUsingDictionary:(NSDictionary *)adDictionary andView:(UIView *)adView;
- (void)startNativeAdTracking;
- (void)endNativeAdTracking;

////IAS Display
//- (void)registerDisplayAdInWebview:(UIWebView *)webView withObstruction:(UIView *)friendlyObstruction;
//- (void)displayAdRecordReadyEvent;
//- (void)endDisplayAdSession;
//
////IAS VAST
//- (void)startVastAdSessionUSingIASDictionary:(NSDictionary *)IASDictionary;
//- (void)recordVastEventWithEvent:(NSString *)eventString;
//- (void)endVastAdSessions;


-(void)createReactiveVideoTrackerWithDict:(NSMutableDictionary *)adDictionary;
-(void)dispatchVolumeChangeEvent:(VMaxVolumeEvents)event withLevel:(CGFloat)volume;
// OM

-(void)activateOMSDK;
- (void)endDisplayAdSession;
//-(void)startVastAdSession :(AVPlayer *)avplayer andview:(UIView *)playerView andVendorKey:(NSString *)strVendorKey andVerificationParam:(NSString *)strVerificationParam andResourceURL:(NSString *)strResourceURL andJSServiceContent:(NSString *)strJSServiceContent andDelay:(int *)delay andisFullscreenAd:(Boolean *)isFullscreenAd andfriendlyObstructions:(NSMutableArray *)friendlyObstructions;
-(void)startVastAdSessions :(AVPlayer *)avplayer andview:(UIView *)playerView andOmResources:(NSMutableArray *)andOmResources andJSServiceContent:(NSString *)strJSServiceContent andDelay:(int)delay andisFullscreenAd:(Boolean *)isFullscreenAd andfriendlyObstructions:(NSMutableArray *)friendlyObstructions; //662 story
- (void)endVastAdSessionOM;
-(void)recordVastEvent :(NSString *)strEvent;
- (void)recordVastEvent:(NSString *)strEvent withDictionary:(NSDictionary*)info; //3.15.0 OM
//-(void)startNativeAdSession :(UIView *)adview andVendorKey:(NSString *)strVendorKey andVerificationParam:(NSString *)strVerificationParam andResourceURL:(NSString *)strResourceURL andJSServiceContent:(NSString *)strJSServiceContent;
-(void)startNativeAdSessions :(UIView *)adview andOmResources:(NSMutableArray *)andOmResources andJSServiceContent:(NSString *)strJSServiceContent;//662 story
-(void)endNativeAdSession;

//3.12.0___Display
//-(void)registerDisplayAd :(UIWebView *)webView andview:(UIView *)playerView andfriendlyObstructions:(NSMutableArray *)friendlyObstructions;
-(void)registerDisplayAd :(WKWebView *)webView andview:(UIView *)playerView andfriendlyObstructions:(NSMutableArray *)friendlyObstructions;

-(void)registerNativeAdView:(UIView *)adview;
-(void)registerDisplayAdFriendlyObstruction : (UIView *)friendlyObstructions;
-(void)startVastAdSessionMainAdview;
//..
@end

#endif /* VMaxViewabilityAd_h */
