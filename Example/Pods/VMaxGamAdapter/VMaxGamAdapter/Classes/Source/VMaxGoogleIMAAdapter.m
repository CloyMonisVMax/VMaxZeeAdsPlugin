//
//  VMaxGoogleIMAAdapter.m
//

@import GoogleInteractiveMediaAds;
@import VMaxAdsSDK;
#import <AVFoundation/AVFoundation.h>
#import "VMaxGoogleIMAAdapter.h"
//#import "VMaxCustomAd.h"
//#import "VMaxAdError.h"
//#import "VMaxAdPartner.h"

NSString *const kInContentVideo_AdTagUrl             = @"ad_tag_url";
NSString *const kInContentVideo_MaxAdDur             = @"max_ad_duration";
//NSString *const errorAdTagUrl = @"https://asdfgpubads.g.doubleclick.net/gampad/ads?iu=/21665149170/TEST_JAN_2021&description_url=%5Bplaceholder%5D&tfcd=0&npa=0&sz=640x480&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=&max_ad_duration=100000"; //@"https://pubads.g.doubleclick.net/gampad/ads?iu=/21665149170/TEST_JAN_2021&description_url=%5Bplaceholder%5D&tfcd=0&npa=0&sz=640x480&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=";

@interface VMaxGoogleIMAAdapter () <IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMALinkOpenerDelegate>
@property (nonatomic, weak) AVPlayer *contentPlayer; // Content video player.
@property (nonatomic, weak) AVPlayerLayer *contentPlayerLayer;
@property (nonatomic, weak) UIView *contentPlayerContainerView;
@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, strong) NSString *adTagUrl;
@property (nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;
@property (nonatomic, strong) IMAAdsLoader *adsLoader;
@property (nonatomic, strong) IMAAdsManager *adsManager;
@property (nonatomic, assign) BOOL adIsPlaying;
@property (nonatomic, assign) BOOL allAdsCompleted;
@property (nonatomic, assign) NSTimeInterval watchedTime;
@property (nonatomic, strong) NSDictionary *mediationInfo; //3.15.8
@property (nonatomic, assign) BOOL directShow; //3.15.8
@property (nonatomic, strong) UILabel *adBadgeLabel; //3.15.8 Ad Badge Label
@property (nonatomic, strong) NSTimer *adBadgeTimer; //3.15.8 Ad Badge Label
@property (nonatomic, strong) NSString *strAdBadge; //3.15.8 Ad Badge Label

@end

@implementation VMaxGoogleIMAAdapter

- (void)loadCustomAd:(NSDictionary *)inParams withDelegate:(id<VMaxCustomAdListener>)inDelegate viewController:(UIViewController *)parentViewController withExtras:(NSDictionary *)inExtraInfo {
    VLog(@"%@ loadCustomAd GoogleIMA SDK Version: %@",NSStringFromClass([self class]),[IMAAdsLoader sdkVersion]);

    self.adIsPlaying = NO;
    self.allAdsCompleted = NO;
    self.parentViewController = parentViewController;
    self.delegate = inDelegate;
    id idAdTagURL = [inParams objectForKey:kInContentVideo_AdTagUrl];
    if ((idAdTagURL != nil) && ( [idAdTagURL isKindOfClass:[NSString class]])){
        self.adTagUrl = [inParams objectForKey:kInContentVideo_AdTagUrl];
    }

    self.contentURL = [NSURL URLWithString:@"."];

    if ([inExtraInfo valueForKey:kVMaxMediationDirectShow]){
        self.directShow = inExtraInfo[kVMaxMediationDirectShow];
    }

    if (inExtraInfo[kVMaxCustomAdExtras_InContentVideoParams]){
        if ([inExtraInfo[kVMaxCustomAdExtras_InContentVideoParams] valueForKey:kVMaxCustomAdExtras_InContentVideoContentPlayerView]){
            self.contentPlayerContainerView = inExtraInfo[kVMaxCustomAdExtras_InContentVideoParams][kVMaxCustomAdExtras_InContentVideoContentPlayerView];
        }
    }

    if ([self.delegate respondsToSelector:@selector(VMaxCustomAd:mediationInfo:)]) {
        [self.delegate performSelector:@selector(VMaxCustomAd:mediationInfo:) withObject:self withObject:@{@"name":kVMaxAdPartner_GoogleIMA,@"version":[IMAAdsLoader sdkVersion]}];
    }

    if(self.adTagUrl) {
        if (self.directShow == YES){
            dispatch_async( dispatch_get_main_queue(), ^{
                [self setUpContentPlayer];
                [self setupAdsLoader];
                [self requestAds:inExtraInfo];
                [self addRequiredObservers];
            });
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdDidLoadAd:)]) {
                VLog(@"%@ VMaxCustomAdDidLoadAd ",NSStringFromClass([self class]));
                [self.delegate performSelector:@selector(VMaxCustomAdDidLoadAd:)
                                    withObject:self];
            }
        }
    } else {
        VLog(@"%@ adTagUrl not found",NSStringFromClass([self class]));
        NSError *error = [[NSError alloc] initWithDomain:kVMaxAdErrorDomain code:kVMaxAdErrorAdParamsMissing userInfo:@{kVMaxAdErrorDetail : kVMaxAdErrorDetailAdParamsMissing}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAd:didFailWithError:)]) {
            VLog(@"%@ VMaxCustomAd:didFailWithError: %@",NSStringFromClass([self class]),error);
            [self.delegate performSelector:@selector(VMaxCustomAd:didFailWithError:) withObject:self withObject:error];
        }
    }
}

- (void)addRequiredObservers {
    VLog(@"%@ addRequiredObservers",NSStringFromClass([self class]));

    [self addObserver:self forKeyPath:@"contentPlayerContainerView.frame" options:NSKeyValueObservingOptionOld context:NULL];  //KVO for contentPlayerContainerView frame change

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteringBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteringForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

#pragma mark - VMaxCustomAd
- (void)showAd {
    VLog(@"%@ showAd",NSStringFromClass([self class]));

    if (self.directShow == YES){
        [self createAdRenderingSettings];
    }else {
        dispatch_async( dispatch_get_main_queue(), ^{
            [self setUpContentPlayer];
            [self setupAdsLoader];
            [self requestAds:self.mediationInfo];
            [self addRequiredObservers];
        });
    }
}

- (void)createAdRenderingSettings{
    VLog(@"%@ createAdRenderingSettings",NSStringFromClass([self class]));

    // Create ads rendering settings and tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.linkOpenerPresentingController = self.parentViewController;
    adsRenderingSettings.uiElements = [NSMutableArray array]; //3.15.8 Ad Badge
    adsRenderingSettings.linkOpenerDelegate = self;
    //adsRenderingSettings.linkOpenerDelegate = __weak self;
    //adsRenderingSettings.webOpenerPresentingController = self.parentViewController;
    //adsRenderingSettings.webOpenerDelegate = self; // to be notified of in-app or external browser opening

    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)invalidateAd {
    VLog(@"%@ invalidateAd",NSStringFromClass([self class]));

    [self stopAdBadgeTimer]; //3.15.8 Ad Badge Label

    if(self.adsManager) {
        [self.adsManager destroy];
    }

}

- (void)playAd {
    VLog(@"%@ playAd",NSStringFromClass([self class]));

    if(self.adsManager) {
        if(self.adIsPlaying && self.contentPlayer) {
            [self.adsManager resume];
        }
    }
}

- (void)pauseAd {
    VLog(@"%@ pauseAd",NSStringFromClass([self class]));

    if(self.adsManager) {
        if(self.adIsPlaying && self.contentPlayer) {
            [self.adsManager pause];
        }
    }
}

#pragma mark -
- (void)displayGoogleIMAAd {
    VLog(@"%@ displayGoogleIMAAd",NSStringFromClass([self class]));

    [self updateFrames]; // ensure proper layout when playing ad

    if(self.adsManager) {
        self.adIsPlaying = YES;
        [self.adsManager start];
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdDidShowAd:)]) {
            VLog(@"%@ VMaxCustomAdDidShowAd",NSStringFromClass([self class]));
            [self.delegate performSelector:@selector(VMaxCustomAdDidShowAd:) withObject:self];
        }
    }
}

#pragma mark - Content Player Setup
- (void)setUpContentPlayer {
    VLog(@"%@ setUpContentPlayer",NSStringFromClass([self class]));

    // Load AVPlayer with path to the content.
    self.contentPlayer = [AVPlayer playerWithURL:self.contentURL];

    if(self.parentViewController) {
        if (self.contentPlayerLayer) {
            [self.contentPlayerLayer setPlayer:self.contentPlayer];
        }
        else {
            self.contentPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.contentPlayer];
            // Size, position, and display the AVPlayer.
            self.contentPlayerLayer.frame = self.contentPlayerContainerView.layer.bounds;
            [self.contentPlayerContainerView.layer addSublayer:self.contentPlayerLayer];
        }
    }

    if(self.contentPlayer) {
        // IMAAVPlayerContentPlayhead for AVPlayer to track current position of the video content
        self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayer];
        // Let the sdk know our own video content finished to display post-rolls
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.contentPlayer.currentItem];
    }
}

- (void)setupAdsLoader {
    VLog(@"%@ setupAdsLoader",NSStringFromClass([self class]));

    // Re-use this IMAAdsLoader instance for the entire lifecycle of your app.
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    self.adsLoader.delegate = self;
}

#pragma mark -
- (void)contentDidFinishPlaying:(NSNotification*)notification {
    VLog(@"%@ contentDidFinishPlaying",NSStringFromClass([self class]));

    if(notification.object == self.contentPlayer.currentItem) {
        [self.adsLoader contentComplete]; // content complete only on own video content playing finished, not ad!
    }
}

#pragma mark -
- (void)requestAds:(NSDictionary*)dict {
    VLog(@"%@ requestAds",NSStringFromClass([self class]));

    IMAAdDisplayContainer *adDisplayContainer = [[IMAAdDisplayContainer alloc] initWithAdContainer:self.contentPlayerContainerView viewController:self.parentViewController];

    self.adTagUrl = [self getModifiedURL:dict adTagURL:self.adTagUrl];
    VLog(@"%@ self.adTagUrl %@",NSStringFromClass([self class]),self.adTagUrl);

    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:self.adTagUrl
                                                  adDisplayContainer:adDisplayContainer
                                                     contentPlayhead:self.contentPlayhead
                                                         userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}

#pragma mark - IMAAdsLoaderDelegate
- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    VLog(@"%@ adsLoader adsLoadedWithData ",NSStringFromClass([self class]));

    self.adsManager = adsLoadedData.adsManager; // Grab the instance of the IMAAdsManager
    self.adsManager.delegate = self; // conform to delegate

    [self createAdRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    VLog(@"%@ adsLoader:failedWithErrorData: %@", NSStringFromClass([self class]), adErrorData.adError.message);

    self.adIsPlaying = NO;

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAd:didFailWithError:)]) {
        VLog(@"%@ VMaxCustomAd:didFailWithError: %@",NSStringFromClass([self class]),adErrorData);
        NSError *error = [[NSError alloc] initWithDomain:kVMaxAdErrorDomain code:adErrorData.adError.type userInfo:@{kVMaxAdErrorDetail:adErrorData.adError.message}];
        [self.delegate performSelector:@selector(VMaxCustomAd:didFailWithError:) withObject:self withObject:error];
    }
}

#pragma mark - IMAAdsManagerDelegate
- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    VLog(@"%@ adsManager didReceiveAdEvent %@ ",NSStringFromClass([self class]),event.typeString);

    if(event.type == kIMAAdEvent_LOADED) { // ad loaded, play if needed

        [self displayGoogleIMAAd];
        //if([self.contentURL.absoluteString length])

        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdFill:)]) {
            VLog(@"%@ VMaxCustomAdFill",NSStringFromClass([self class]));
            [self.delegate VMaxCustomAdFill:self];
        }


    } else if (event.type == kIMAAdEvent_STARTED) {

        [self createAdBadgeLabel]; //3.15.8 Ad Badge
        [self startAdBadgeTimer]; //3.15.8 Ad Badge

        //..(3.9.18) Added
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdMediaStart)]) {
            VLog(@"VMaxCustomAdMediaStart");
            [self.delegate VMaxCustomAdMediaStart];
        }
        //..
        //3.15.8
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdImpression)]) {
            VLog(@"VMaxCustomAdImpression");
            [self.delegate VMaxCustomAdImpression];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdRender)]) {
            VLog(@"VMaxCustomAdRender");
            [self.delegate VMaxCustomAdRender];
        }
        //..

    } else if (event.type == kIMAAdEvent_SKIPPED) {

        self.allAdsCompleted = YES;

    } else if (event.type == kIMAAdEvent_COMPLETE) {

        self.adIsPlaying = NO;

        [self stopAdBadgeTimer];

    } else if (event.type == kIMAAdEvent_ALL_ADS_COMPLETED) {

        self.allAdsCompleted = YES;

        [self stopAdBadgeTimer];

    }
    //3.15.8
    else if (event.type == kIMAAdEvent_FIRST_QUARTILE) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomFirstQuartile)]) {
            VLog(@"%@ VMaxCustomFirstQuartile",NSStringFromClass([self class]));
            [self.delegate VMaxCustomFirstQuartile];
        }
    } else if (event.type == kIMAAdEvent_MIDPOINT) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomMidPoint)]) {
            VLog(@"%@ VMaxCustomMidPoint",NSStringFromClass([self class]));
            [self.delegate VMaxCustomMidPoint];
        }
    } else if (event.type == kIMAAdEvent_THIRD_QUARTILE) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomThirdQuartile)]) {
            VLog(@"%@ VMaxCustomThirdQuartile",NSStringFromClass([self class]));
            [self.delegate VMaxCustomThirdQuartile];
        }
    }
    //.

    if(event.type == kIMAAdEvent_SKIPPED || event.type == kIMAAdEvent_COMPLETE) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAd:didComplete:watchedDuration:totalDuration:)]) {
            VLog(@"%@ VMaxCustomAd:didComplete:watchedDuration:totalDuration:",NSStringFromClass([self class]));
            [self.delegate VMaxCustomAd:self didComplete:(event.type == kIMAAdEvent_SKIPPED) ? NO : YES watchedDuration:self.watchedTime totalDuration:event.ad.duration];
        }
    }
    else if(event.type == kIMAAdEvent_ALL_ADS_COMPLETED) {

        dispatch_async( dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdDidDismissAd:)]) {
                VLog(@"%@ VMaxCustomAdDidDismissAd",NSStringFromClass([self class]));
                [self.delegate VMaxCustomAdDidDismissAd:self];
            }
        });

    }

    else if (event.type == kIMAAdEvent_AD_BREAK_FETCH_ERROR ){

        NSError *error = [[NSError alloc] initWithDomain:kVMaxAdErrorDomain code:1 userInfo:@{kVMaxAdErrorDetail:@"Break Fetch error"}];

        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAd:didFailWithError:)]) {
            VLog(@"%@ VMaxCustomAd:didFailWithError",NSStringFromClass([self class]));
            [self.delegate performSelector:@selector(VMaxCustomAd:didFailWithError:) withObject:self withObject:error];
        }

    }

    else if (event.type == kIMAAdEvent_PAUSE){

        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdPause)]) {
            VLog(@"%@ VMaxCustomAdPause",NSStringFromClass([self class]));
            [self.delegate VMaxCustomAdPause];
        }

    }

    else if (event.type == kIMAAdEvent_RESUME) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdResume)]) {
            VLog(@"%@ VMaxCustomAdResume",NSStringFromClass([self class]));
            [self.delegate VMaxCustomAdResume];
        }

    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    VLog(@"%@ didReceiveAdError %@",NSStringFromClass([self class]),error.message);
    // Something went wrong with the ads manager after ads were loaded. Log the error.

    self.adIsPlaying = NO;

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAd:didFailWithError:)]) {
        VLog(@"%@ VMaxCustomAd:didFailWithError: %@",NSStringFromClass([self class]),error);
        NSError *adError = [[NSError alloc] initWithDomain:kVMaxAdErrorDomain code:error.type userInfo:@{kVMaxAdErrorDetail:error.message}];
        [self.delegate performSelector:@selector(VMaxCustomAd:didFailWithError:) withObject:self withObject:adError];
    }
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    VLog(@"%@ adsManagerDidRequestContentPause",NSStringFromClass([self class]));
    self.adIsPlaying = YES;
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    VLog(@"%@ adsManagerDidRequestContentResume",NSStringFromClass([self class]));
    self.adIsPlaying = NO; // done playing ads, atleast for now
}

- (void)adsManagerAdDidStartBuffering:(IMAAdsManager *)adsManager {
    VLog(@"%@ adsManagerAdDidStartBuffering",NSStringFromClass([self class]));
}

- (void)adsManagerAdPlaybackReady:(IMAAdsManager *)adsManager {
    VLog(@"%@ adsManagerAdPlaybackReady",NSStringFromClass([self class]));
}

- (void)adsManager:(IMAAdsManager *)adsManager adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime {
    //VLog(@"%@ adDidProgressToTime",NSStringFromClass([self class]));
    self.watchedTime = mediaTime;
}

#pragma mark - IMAWebOpenerDelegate
- (void)webOpenerWillOpenExternalBrowser:(NSObject *)webOpener {
    VLog(@"%@ webOpenerWillOpenExternalBrowser",NSStringFromClass([self class]));

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdOnAdClicked:)]) {
        VLog(@"%@ VMaxCustomAdOnAdClicked",NSStringFromClass([self class]));
        [self.delegate performSelector:@selector(VMaxCustomAdOnAdClicked:) withObject:self];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdWillLeaveApplication:)]) {
        VLog(@"%@ VMaxCustomAdWillLeaveApplication",NSStringFromClass([self class]));
        [self.delegate performSelector:@selector(VMaxCustomAdWillLeaveApplication:) withObject:self];
    }
}

- (void)webOpenerWillOpenInAppBrowser:(NSObject *)webOpener {
    VLog(@"%@ webOpenerWillOpenInAppBrowser",NSStringFromClass([self class]));

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdOnAdClicked:)]) {
        VLog(@"%@ VMaxCustomAdOnAdClicked",NSStringFromClass([self class]));
        [self.delegate performSelector:@selector(VMaxCustomAdOnAdClicked:) withObject:self];
    }
}

- (void)webOpenerDidOpenInAppBrowser:(NSObject *)webOpener {
    VLog(@"%@ webOpenerDidOpenInAppBrowser",NSStringFromClass([self class]));
}

- (void)webOpenerWillCloseInAppBrowser:(NSObject *)webOpener {
    VLog(@"%@ webOpenerWillCloseInAppBrowser",NSStringFromClass([self class]));
}

- (void)webOpenerDidCloseInAppBrowser:(NSObject *)webOpener {
    VLog(@"%@ webOpenerDidCloseInAppBrowser",NSStringFromClass([self class]));
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //3.11.13 Try-Cached Added
    VLog(@"%@ observeValueForKeyPath %@",NSStringFromClass([self class]),keyPath);
    @try {
        if([keyPath isEqualToString:@"contentPlayerContainerView.frame"]) {
            [self updateFrames];
        }
    } @catch (NSException *exception) {

    }
}

- (void)updateFrames {
    VLog(@"%@ updateFrames",NSStringFromClass([self class]));
    if(self.contentPlayerLayer && self.contentPlayerContainerView) {
        self.contentPlayerLayer.frame = self.contentPlayerContainerView.layer.bounds;
    }
}

#pragma mark -
- (void)applicationEnteringBackground {
    VLog(@"%@ applicationEnteringBackground",NSStringFromClass([self class]));
}

- (void)applicationEnteringForeground {
    VLog(@"%@ applicationEnteringForeground",NSStringFromClass([self class]));
    if(!self.allAdsCompleted && !self.adIsPlaying && CMTimeGetSeconds(self.contentPlayer.currentItem.duration) != CMTimeGetSeconds(self.contentPlayer.currentItem.currentTime)) { // check player status
        [self.contentPlayer play];
    }
    if (self.adsManager){
        [self.adsManager resume];
    }
}

#pragma mark -
- (void)dealloc {
    VLog(@"%@ dealloc",NSStringFromClass([self class]));
    @try {
        [self stopAdBadgeTimer]; //3.15.8 Ad Badge Label

        if(_adsManager != nil) {
            [_adsManager destroy];
            _adsManager.delegate = nil;
            _adsManager = nil;
        }
        if(_contentPlayerLayer != nil) {
            [_contentPlayerLayer removeFromSuperlayer];
            _contentPlayerLayer = nil;
        }

        if(_contentPlayer != nil) {
            _contentPlayer = nil;
        }

        [self removeObserver:self forKeyPath:@"contentPlayerContainerView.frame"];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    } @catch(id anException) {
        VLog(@"%@ exception %@",NSStringFromClass([self class]),anException);
    }
}

#pragma mark - GAM Parameter

- (NSString *)getModifiedURL:(NSDictionary*)input adTagURL:(NSString*)adTagURL{
    NSLog(@"%@ getModifiedURL %@",NSStringFromClass([self class]),input);
    if (adTagURL == nil){
        return @"";
    }
    if (input == nil){
        return adTagURL;
    }
    @try {
        NSInteger maxDuration = 0;
        NSInteger maxDurationPerAd = 0;
        if (input && ([input valueForKey:kVMaxMaxDuration]) ){
            NSString *duration = [input valueForKey:kVMaxMaxDuration];
            maxDuration = [duration integerValue];
        }
        if (input && ([input valueForKey:kVMaxMaxDurationPerAd]) ){
            NSString *duration = [input valueForKey:kVMaxMaxDurationPerAd];
            maxDurationPerAd = [duration integerValue];
        }
        NSInteger duration = 0;
        if (maxDuration > 0 && maxDurationPerAd > 0){
            if (maxDuration < maxDurationPerAd){
                duration = maxDuration;
            }else{
                duration = maxDurationPerAd;
            }
        }else if (maxDuration > 0){
            duration = maxDuration;
        }else if (maxDurationPerAd > 0){
            duration = maxDurationPerAd;
        }
        if (duration > 0){
            duration = duration * 1000;
            NSString *strDuration = [@(duration) stringValue];
            if (strDuration.length > 1){
                NSString *maxDuration = @"";
                if ([adTagURL containsString:[kInContentVideo_MaxAdDur stringByAppendingString:@"="]]){
                    maxDuration = [kInContentVideo_MaxAdDur stringByAppendingString:@"="];
                }else if ([adTagURL containsString:kInContentVideo_MaxAdDur]) {
                    maxDuration = kInContentVideo_MaxAdDur;
                }
                if ([adTagURL containsString:maxDuration]){
                    NSRange startRange = [adTagURL rangeOfString:maxDuration];
                    if (startRange.location != NSNotFound){
                        NSString *toReplace = nil;
                        NSString *substring = [adTagURL substringFromIndex:startRange.location];
                        NSRange endRange = [substring rangeOfString:@"&"];
                        if (endRange.location == NSNotFound){
                            toReplace = substring;
                        }else{
                            NSUInteger endLocation = endRange.location;
                            toReplace = [substring substringToIndex:endLocation];
                        }
                        if (toReplace != nil){
                            NSString *durationWithKey = [NSString stringWithFormat:@"%@=%@",kInContentVideo_MaxAdDur,strDuration];
                            NSString *newString = [adTagURL stringByReplacingOccurrencesOfString:toReplace withString:durationWithKey];
                            adTagURL = newString;
                        }
                    }
                } else {
                    NSString *durationWithKey = [NSString stringWithFormat:@"%@=%@",kInContentVideo_MaxAdDur,strDuration];
                    if ([adTagURL containsString:@"?"] == NO){
                        adTagURL = [[adTagURL stringByAppendingString:@"?"] stringByAppendingString:durationWithKey];
                    }else if ([adTagURL hasSuffix:@"&"] || [adTagURL hasSuffix:@"?"] ) {
                        adTagURL = [adTagURL stringByAppendingString:durationWithKey];
                    }else{
                        adTagURL = [[adTagURL stringByAppendingString:@"&"] stringByAppendingString:durationWithKey];
                    }
                }
                return adTagURL;
            }else{
                return adTagURL;
            }
        }
    } @catch (NSException *exception) {

    }
    return adTagURL;
}

- (BOOL)canDurationPassInRequest{
    return YES;
}

- (void)updateMediationData:(NSDictionary*)dict {
    self.mediationInfo = dict;
}

#pragma mark - //3.15.8 Ad Badge Label

- (void)createAdBadgeLabel{
    if (self.adBadgeLabel != nil){
        return;
    }
    self.adBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,(self.contentPlayerContainerView.bounds.size.height-34),200,22)];
    self.adBadgeLabel.layer.zPosition = CGFLOAT_MAX;
    self.adBadgeLabel.backgroundColor = [UIColor clearColor];
    self.adBadgeLabel.textColor = [UIColor whiteColor];
    self.adBadgeLabel.font = [UIFont fontWithName:@"NotoSansOriya" size:14.0];
    self.adBadgeLabel.shadowColor = [UIColor blackColor];
    self.adBadgeLabel.shadowOffset = CGSizeMake(1.0,1.0);
    self.adBadgeLabel.numberOfLines = 0;
    self.adBadgeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    int podIndex = 0;
    int totalAds = 0;
    if (self.mediationInfo && ([self.mediationInfo valueForKey:kVMaxMediationPodIndex]) ){
        podIndex = [[self.mediationInfo valueForKey:kVMaxMediationPodIndex] intValue];
    }
    if (self.mediationInfo && ([self.mediationInfo valueForKey:kVMaxMediationTotalAds]) ){
        totalAds = [[self.mediationInfo valueForKey:kVMaxMediationTotalAds] intValue];
    }
    self.strAdBadge = @"Ad";
    if (totalAds > 1 && podIndex >= 1){
        self.strAdBadge = [NSString stringWithFormat:@"Ad %d of %d",podIndex,totalAds];
    }
    self.adBadgeLabel.text = self.strAdBadge;
    if ((self.adBadgeLabel) && (self.contentPlayerContainerView)){
        [self.contentPlayerContainerView addSubview:self.adBadgeLabel];
        //[self addConstraintsForAdBadge:self.contentPlayerContainerView withAdBadge:self.adBadgeLabel];
    }
}

- (void)removeAdBadge{
    if (self.adBadgeLabel){
        [self.adBadgeLabel removeFromSuperview];
        self.adBadgeLabel = nil;
    }
}

- (void)startAdBadgeTimer{
    if (self.adBadgeTimer == nil){
        self.adBadgeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateAdBadgeLabel:) userInfo:nil repeats:YES];
    }
}

- (void)stopAdBadgeTimer{
    if (self.adBadgeTimer){
        [self.adBadgeTimer invalidate];
        self.adBadgeTimer = nil;
    }
    [self removeAdBadge];
}

- (void)updateAdBadgeLabel:(NSTimer *)timer {
    if (self.adsManager && self.adsManager.adPlaybackInfo){
        if (self.adsManager.adPlaybackInfo.totalMediaTime == NAN || self.adsManager.adPlaybackInfo.currentMediaTime == NAN){
            return;
        }
        NSInteger totalTime = self.adsManager.adPlaybackInfo.totalMediaTime;
        NSInteger currentTime = self.adsManager.adPlaybackInfo.currentMediaTime;
        if (self.adBadgeLabel && self.strAdBadge){
            NSInteger sec = totalTime - currentTime;
            NSString *currentTime = [self convertSecondsToMinutes:sec];
            self.adBadgeLabel.text = [[NSString alloc] initWithFormat:@"%@ : %@",self.strAdBadge,currentTime];
        }
    }
}

- (NSString*)convertSecondsToMinutes:(NSInteger)totalTime {
    NSString *defaultTime = @"0:00";
    @try {
        if (totalTime <= 0){
            return defaultTime;
        }
        NSInteger minutes = (totalTime / 60);
        NSInteger seconds = totalTime % 60;
        NSString *isSec = (seconds < 10) ? [[NSString alloc] initWithFormat:@"0%ld",seconds] : [[NSString alloc] initWithFormat:@"%ld",seconds];
        return [NSString stringWithFormat:@"(%ld:%@)",minutes, isSec];
    } @catch (NSException *exception) {
        return defaultTime;
    }
    return defaultTime;
}

#pragma mark - IMALinkOpenerDelegate

- (void)linkOpenerWillOpenExternalApplication:(NSObject *)linkOpener{
    VLog(@"%@ linkOpenerWillOpenExternalApplication",NSStringFromClass([self class]));
}

- (void)linkOpenerDidOpenInAppLink:(NSObject *)linkOpener{
    VLog(@"%@ linkOpenerDidOpenInAppLink",NSStringFromClass([self class]));

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdOnAdClicked:)]) {
        VLog(@"%@ VMaxCustomAdOnAdClicked",NSStringFromClass([self class]));
        [self.delegate performSelector:@selector(VMaxCustomAdOnAdClicked:) withObject:self];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdWillLeaveApplication:)]) {
        VLog(@"%@ VMaxCustomAdWillLeaveApplication",NSStringFromClass([self class]));
        [self.delegate performSelector:@selector(VMaxCustomAdWillLeaveApplication:) withObject:self];
    }
}

- (void)linkOpenerWillOpenInAppLink:(NSObject *)linkOpener{
    VLog(@"%@ linkOpenerWillOpenInAppLink",NSStringFromClass([self class]));
}

- (void)linkOpenerWillCloseInAppLink:(NSObject *)linkOpener{
    VLog(@"%@ linkOpenerWillCloseInAppLink",NSStringFromClass([self class]));
}

- (void)linkOpenerDidCloseInAppLink:(NSObject *)linkOpener{
    VLog(@"%@ linkOpenerDidCloseInAppLink",NSStringFromClass([self class]));

    if (self.adsManager){
        [self.adsManager resume];
    }
}

- (void)updateMediaProgess:(NSNumber*) currentDuration withTotalDuration:(NSNumber*)totalDuration {
    if (self.delegate && [self.delegate respondsToSelector:@selector(VMaxCustomAdProgress:withTotalDuration:)]) {
        [self.delegate VMaxCustomAdProgress:currentDuration withTotalDuration:totalDuration];
    }
}


@end
