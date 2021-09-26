//
//  VmaxTracker.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 04/06/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VMaxMediationSelector;

NS_ASSUME_NONNULL_BEGIN

@interface VmaxTracker : NSObject
@property (strong, nonatomic) NSString *adID; //new adid
@property (strong, nonatomic) NSString *ccb; //new adid
@property (nonatomic , strong) NSMutableArray *mErrorUrls;
@property (nonatomic , strong) NSMutableArray *mClickTrackingUrls;
@property (nonatomic , strong) NSMutableArray *eventUrl;
@property (nonatomic , strong) NSDictionary *adData;
@property (nonatomic , strong) NSString *payload;
@property (nonatomic , strong) NSMutableArray *customEventURLs;
@property (nonatomic , strong) NSString *mClickThroughUrl;
//@property (nonatomic , strong) NSString *omVendorKey; //662 story
//@property (nonatomic , strong) NSString *omVerificationParam; //662 story
//@property (nonatomic , strong) NSString *omJavaScriptResourceURL; //662 story
@property (nonatomic , strong) NSMutableArray *verificationResourceArray; //662 story
@property (assign , nonatomic) NSInteger EVENT_OM;
@property (assign , nonatomic) NSInteger EVENT_IMPRESSION;
@property (assign , nonatomic) NSInteger EVENT_VAST;
@property (assign , nonatomic) NSInteger enableClickControl;
@property (nonatomic, strong) VMaxMediationSelector *mediationSelector;
@property (nonatomic , strong) NSMutableArray *mImpressionUrls;


- (id)initWithName:(NSString *)payload showLogEvent:(BOOL)showLogEvent;
- (void)parseAdData:(NSDictionary *)adData;
- (void)setAdid:(NSString *)adId;
- (void)setImpUrls;

- (void)onImpression;

- (void)addNativeImpressionUrl:(NSMutableArray *)urls;

- (void)setEventTrackers;

- (void)logEvent:(NSString *)eventId;

- (void)onClick:(void (^)(void))completionBlock;

- (void)setClickControl:(NSInteger)enableClickControl;

- (BOOL)handleVastClickThrough:(NSInteger *)payload;

- (void)setAdView:(UIView *)view plaverView:(AVPlayer *)playerView;

- (void)addFriendlyObstruction:(UIView *)view;

- (void)onStart:(NSInteger)totalDuration;

- (void)onFirstQuartile;

- (void)onMidpoint;

- (void)onThirdQuartile;

- (void)onComplete;

- (void)onPause;

- (void)onResume;

- (void)onMute;

- (void)onUnmute;

- (void)onFullscreen;

- (void)onExitFullscreen;

- (void)stop;

- (void)onClose;

- (void)onError;

- (void)onAdError:(NSString *)error;

- (NSMutableArray *)getErrorUrls;

- (NSString *)getClickVideoUrl;

- (NSMutableArray *)getClickTrackingUrls;

- (void)getTracker;

- (NSMutableArray *)getTrackingUrl:(NSString *)event;

- (void)fireVastTrackRequest:(NSArray *)event;

-(void)fireVastEventOMSDK:(NSString *)event;

@end

NS_ASSUME_NONNULL_END



