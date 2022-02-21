//
//  VMaxOM.m

#import "VMaxOM.h"
#import <OMSDK_Zeedigitalesselgroup/OMIDAdEvents.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDAdSession.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDAdSessionConfiguration.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDAdSessionContext.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDFriendlyObstructionType.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDImports.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDMediaEvents.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDPartner.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDScriptInjector.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDSDK.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDVASTProperties.h>
#import <OMSDK_Zeedigitalesselgroup/OMIDVerificationScriptResource.h>

#define BUNDLEID    [NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]] ? [NSString stringWithString:[[NSBundle mainBundle] bundleIdentifier]] : @""

typedef NS_ENUM(NSUInteger,VastEventType) {
    kVMaxOMAdState_Started,
    kVMaxOMAdState_Stopped ,
    kVMaxOMAdState_Completed ,
    kVMaxOMAdState_Click ,
    kVMaxOMAdState_FirstQuartile,
    kVMaxOMAdState_Midpoint,
    kVMaxOMAdState_ThirdQuartile,
    kVMaxOMAdState_Pause,
    kVMaxOMAdState_Collapse,
    kVMaxOMAdState_Error,
    kVMaxOMAdState_Mute,
    kVMaxOMAdState_Unmute,
    kVMaxOMAdState_Skipped,
    kVMaxOMAdState_Expand
};

@interface VMaxOM ()

@end

Boolean isOMSdkActivated = false;
OMIDZeedigitalesselgroupPartner *partner;
OMIDZeedigitalesselgroupAdSession *adSession; 
OMIDZeedigitalesselgroupAdEvents *adEvents;
OMIDZeedigitalesselgroupMediaEvents *omidVideoEvents;

AVPlayer * avPlayerVideoPlayer;
NSString *strScript;
UIView *viewMainAdPlayerView;

@implementation VMaxOM 

#pragma mark Activate the OM SDK

-(void)activateOMSDK {

    isOMSdkActivated = [[OMIDZeedigitalesselgroupSDK sharedInstance] activate];
    partner = [[OMIDZeedigitalesselgroupPartner alloc] initWithName:@"Zeedigitalesselgroup" versionString:[VMaxAdSDK getSDKVersion]];
    if (isOMSdkActivated) {
        VLog(@"OM_vmax : Activate OMID SDK Success %@",[OMIDZeedigitalesselgroupSDK versionString]);
    }
    else {
        VLog(@"OM_vmax : Activate OMID SDK Failed");
    }
    
}

-(void)script {
    NSString *path =[[NSBundle bundleForClass: self.class] pathForResource:@"vmax_omid" ofType:@"js"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    strScript = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    VLog(@"%@",strScript);
}

#pragma mark Register Display Ad

-(void)registerDisplayAd :(WKWebView *)webView andview:(UIView *)playerView andfriendlyObstructions:(NSMutableArray *)friendlyObstructions {
    
    if (isOMSdkActivated) {
        VLog(@"OM_vmax : Initializing OM Display Ad Session");
        NSString *customReferenceData;
        NSError *adSessionContextError;
        OMIDZeedigitalesselgroupAdSessionContext *context = [[OMIDZeedigitalesselgroupAdSessionContext alloc] initWithPartner:partner webView:webView contentUrl:nil customReferenceIdentifier:customReferenceData error:&adSessionContextError];
        OMIDOwner owner = OMIDNativeOwner;
        NSError *adSessionConfigurationError;
        OMIDZeedigitalesselgroupAdSessionConfiguration *config = [[OMIDZeedigitalesselgroupAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay impressionType:OMIDImpressionTypeBeginToRender impressionOwner:owner mediaEventsOwner:owner isolateVerificationScripts:false error:&adSessionConfigurationError];
        adSession = [[OMIDZeedigitalesselgroupAdSession alloc] initWithConfiguration:config adSessionContext:context error:nil];
        adSession.mainAdView = webView;
        if (playerView != nil) {
            [self registerDisplayAdFriendlyObstruction:playerView];
        }
    }
    else {
        VLog(@"OM_vmax : Unable to activate OMID SDK");
    }
}

-(void)registerDisplayAdFriendlyObstruction : (UIView *)friendlyObstructions {
    [adSession addFriendlyObstruction:friendlyObstructions purpose: OMIDFriendlyObstructionOther detailedReason:nil error:nil];
}

#pragma mark Display Start Tracking

-(void)displayStartTracking  {
    
    if (adSession != nil) {
        VLog(@"OM_vmax : OM Display displayStartTracking");
        [adSession start];
        NSError *adEvtsError;
        adEvents = [[OMIDZeedigitalesselgroupAdEvents alloc] initWithAdSession:adSession error:&adEvtsError];
        NSError *impError;
        [adEvents impressionOccurredWithError:&impError];
    }
    
}

#pragma mark End Display AdSeesion

-(void)endDisplayAdSession {
    if (adSession !=nil) {
        VLog(@"OM_vmax : Terminating Display Start Tracking");
        [adSession finish];
    }
    omidVideoEvents = nil;
    adSession = nil;
}

#pragma mark Start Vast Session

-(void)startVastAdSessions:(AVPlayer *)avplayer andview:(UIView *)playerView andOmResources:(NSMutableArray *)andOmResources andJSServiceContent:(NSString *)strJSServiceContent andDelay:(int)delay andisFullscreenAd:(Boolean *)isFullscreenAd andfriendlyObstructions:(NSMutableArray *)friendlyObstructions {
    
    if (isOMSdkActivated) {
        [self script];
        viewMainAdPlayerView = playerView;
        NSMutableArray *scripts = [[NSMutableArray alloc]init];
        if (andOmResources.count > 0) {
            for (NSDictionary* omResource in andOmResources)
            {
                NSString *omJavaScriptResourceURL = [omResource valueForKey:@"omJavaScriptResourceURL"];
                NSString *strVendorKey = [omResource valueForKey:@"omVendorKey"];
                NSString *strVerificationParam = [omResource valueForKey:@"omVerificationParam"];
                if(omJavaScriptResourceURL == nil){
                    continue;
                }
                NSURL *url = [NSURL URLWithString:omJavaScriptResourceURL];
                //VLog(@"OM_vmax : %@",url);
                //VLog(@"OM_vmax : vendorKey %@",strVendorKey);
                //VLog(@"OM_vmax : verificationParam %@",strVerificationParam);
                if (url && strVendorKey && strVerificationParam){
                    [scripts addObject:[[OMIDZeedigitalesselgroupVerificationScriptResource alloc] initWithURL:url vendorKey:strVendorKey parameters:strVerificationParam]];
                }
            }
        }
        else {
            for (NSDictionary* omResource in andOmResources)
            {
                NSString *omJavaScriptResourceURL = [omResource valueForKey:@"omJavaScriptResourceURL"];
                NSURL *url = [NSURL URLWithString:omJavaScriptResourceURL];
                [scripts addObject:[[OMIDZeedigitalesselgroupVerificationScriptResource alloc] initWithURL:url]];
            }
        }
        if (scripts.count >= 1){
            VLog(@"OM_vmax : OM AdView Registered");
            VLog(@"OM_vmax : Initializing OM Vast Ad Session");
        }
        NSString *customReferenceData;
        NSError *adSessionContextError;
        OMIDZeedigitalesselgroupAdSessionContext *adSessionContext = [[OMIDZeedigitalesselgroupAdSessionContext alloc] initWithPartner:partner script:strScript resources:scripts contentUrl:nil customReferenceIdentifier:customReferenceData error:&adSessionContextError];
        OMIDOwner owner = OMIDNativeOwner;
        NSError *adSessionConfigurationError;
        OMIDZeedigitalesselgroupAdSessionConfiguration *adSessionConfiguration = [[OMIDZeedigitalesselgroupAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo impressionType:OMIDImpressionTypeBeginToRender impressionOwner:owner mediaEventsOwner:owner isolateVerificationScripts:true error:&adSessionConfigurationError];
        NSError *adSessionError;
        adSession = [[OMIDZeedigitalesselgroupAdSession alloc] initWithConfiguration:adSessionConfiguration adSessionContext:adSessionContext error:&adSessionError];
        [self startVastAdSessionMainAdview];
        if (friendlyObstructions.count != 0) {
            for (int i=0;i<friendlyObstructions.count;i++){
                id everyView = friendlyObstructions[i];
                if ([everyView isKindOfClass:[UIView class]] == YES){
                    UIView *friendlyObstruction = (UIView*)everyView;
                    [adSession addFriendlyObstruction:friendlyObstruction purpose:OMIDFriendlyObstructionOther detailedReason:nil error:nil];
                    VLog(@"OM_vmax : OM Vast ads friendly obstruction registered");
                }
            }
        }
        NSError *adEventsEroor;
        adEvents = [[OMIDZeedigitalesselgroupAdEvents alloc] initWithAdSession:adSession error:&adEventsEroor];
        omidVideoEvents = [[OMIDZeedigitalesselgroupMediaEvents alloc] initWithAdSession:adSession error:&adEventsEroor];
        avPlayerVideoPlayer = avplayer;
        [adSession start];
        VLog(@"OM_vmax : startVastAdSession delay:%i",delay);
        if (delay > 0) {
            OMIDZeedigitalesselgroupVASTProperties *vProps = [[OMIDZeedigitalesselgroupVASTProperties alloc] initWithSkipOffset:delay autoPlay:(BOOL)true position:OMIDPositionStandalone];
            NSError *errors;
            [adEvents loadedWithVastProperties:vProps error:&errors];
            VLog(@"OM_vmax : OM Vast loaded event with delay:%i",delay);
        }
        else {
            OMIDZeedigitalesselgroupVASTProperties *vProps = [[OMIDZeedigitalesselgroupVASTProperties alloc] initWithAutoPlay:true position:OMIDPositionStandalone];
            NSError *errors;
            [adEvents loadedWithVastProperties:vProps error:&errors];
            VLog(@"OM_vmax : OM Vast loaded event");
        }
        VLog(@"OM_vmax : Vast Ad Impression registered");
        [adEvents impressionOccurredWithError:&adEventsEroor];
        if (isFullscreenAd) {
            [omidVideoEvents playerStateChangeTo:OMIDPlayerStateFullscreen];
        }
        else {
            [omidVideoEvents playerStateChangeTo:OMIDPlayerStateNormal];
        }
    }
    else {
        VLog(@"OM_vmax : Unable to activate OMID SDK");
    }
}

-(void)startVastAdSessionMainAdview {
    VLog(@"OM_vmax : setMainAdView");
    [adSession setMainAdView:viewMainAdPlayerView];
}

#pragma mark End Vast Session

-(void)endVastAdSessionOM {
    if (adSession !=nil) {
        VLog(@"OM_vmax : Terminating OM Vast Ad session");
        [adSession finish];
    }
    omidVideoEvents = nil;
    adSession = nil;
}

#pragma mark Record Vast Event

-(void)recordVastEvent :(NSString *)strEvent {
    VLog(@"OM_vmax : Record Vast Event called :%@",strEvent);
    if (adSession != nil && omidVideoEvents!=nil) {
        VLog(@"OM_vmax : Registering OM Vast event= %@",strEvent);
        if ([strEvent isEqualToString:@"complete"]) {
            [omidVideoEvents complete];
        }
        else if ([strEvent isEqualToString:@"firstQuartile"]) {
            [omidVideoEvents firstQuartile];
        }
        else if ([strEvent isEqualToString:@"midpoint"]) {
            [omidVideoEvents midpoint];
        }
        else if ([strEvent isEqualToString:@"thirdQuartile"]) {
            [omidVideoEvents thirdQuartile];
        }
        else if ([strEvent isEqualToString:@"pause"]) {
            [omidVideoEvents pause];
        }
        else if ([strEvent isEqualToString:@"resume"]) {
            [omidVideoEvents resume];
        }
        else if ([strEvent isEqualToString:@"expand"]) {
            [omidVideoEvents playerStateChangeTo:OMIDPlayerStateExpanded];
        }
        else if ([strEvent isEqualToString:@"collapse"]) {
            [omidVideoEvents playerStateChangeTo:OMIDPlayerStateCollapsed];
        }
        else if ([strEvent isEqualToString:@"mute"]) {
            [omidVideoEvents volumeChangeTo:0];
        }
        else if ([strEvent isEqualToString:@"unmute"]) {
            [omidVideoEvents volumeChangeTo:1];
        }
        else if ([strEvent isEqualToString:@"skipped"] || [strEvent isEqualToString:@"skip"] ) {
            [omidVideoEvents skipped];
        }
        else if ([strEvent isEqualToString:@"click"]) {
            [omidVideoEvents adUserInteractionWithType:OMIDInteractionTypeClick];
        }
        else {
            VLog(@"OM_vmax : No %@ event available for OM",strEvent);
        }
    }
}

-(void)recordVastEvent:(NSString *)strEvent withDictionary:(NSDictionary *)info{
    VLog(@"OM_vmax : Record Vast Event withDictionary called :%@",strEvent);
    if (adSession != nil && omidVideoEvents!=nil) {
        VLog(@"OM_vmax : Registering OM Vast event= %@",strEvent);
        if ([strEvent isEqualToString:@"start"]) {
            NSInteger mediaDuration = [[info valueForKey:@"duration"] integerValue];
            CGFloat volume = [[info valueForKey:@"volume"] floatValue];
            [omidVideoEvents startWithDuration:mediaDuration mediaPlayerVolume:volume];
        }else {
            VLog(@"OM_vmax : No %@ event available for OM withDictionary ",strEvent);
        }
    }
}

#pragma mark Start Native AdSession

-(void)startNativeAdSessions:(UIView *)adview andOmResources:(NSMutableArray *)andOmResources andJSServiceContent:(NSString *)strJSServiceContent{
    [self script];
    NSMutableArray *verificationScriptResources = [[NSMutableArray alloc]init];
    if (andOmResources.count > 0) {
        for (NSDictionary* omResource in andOmResources)
        {
            NSString *omJavaScriptResourceURL = [omResource valueForKey:@"omJavaScriptResourceURL"];
            NSString *strVendorKey = [omResource valueForKey:@"omVendorKey"];
            NSString *strVerificationParam = [omResource valueForKey:@"omVerificationParam"];
            NSURL *url = [NSURL URLWithString:omJavaScriptResourceURL];
            VLog(@"OM_vmax : %@",url);
            VLog(@"OM_vmax : vendorKey %@",strVendorKey);
            VLog(@"OM_vmax : verificationParam %@",strVerificationParam);
            [verificationScriptResources addObject:[[OMIDZeedigitalesselgroupVerificationScriptResource alloc] initWithURL:url vendorKey: strVendorKey
                                                                                                                parameters:strVerificationParam]];
        }
    }
    else{
        for (NSDictionary* omResource in andOmResources)
        {
            NSString *omJavaScriptResourceURL = [omResource valueForKey:@"omJavaScriptResourceURL"];
            NSURL *url = [NSURL URLWithString:omJavaScriptResourceURL];
            [verificationScriptResources addObject:[[OMIDZeedigitalesselgroupVerificationScriptResource alloc] initWithURL:url]];
        }
        
    }
    NSString *customReferenceData;
    NSError *adSessionContextError;
    OMIDZeedigitalesselgroupAdSessionContext *adSessionContext = [[OMIDZeedigitalesselgroupAdSessionContext alloc] initWithPartner:partner script:strScript resources:verificationScriptResources contentUrl:nil customReferenceIdentifier:customReferenceData error:&adSessionContextError];
    OMIDOwner owner = OMIDNativeOwner;
    NSError *adSessionConfigurationError;
    OMIDZeedigitalesselgroupAdSessionConfiguration *adSessionConfiguration = [[OMIDZeedigitalesselgroupAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay impressionType:OMIDImpressionTypeBeginToRender impressionOwner:owner mediaEventsOwner:owner isolateVerificationScripts:false error:&adSessionConfigurationError];
    NSError *adSessionError;
    adSession = [[OMIDZeedigitalesselgroupAdSession alloc] initWithConfiguration:adSessionConfiguration adSessionContext:adSessionContext error:&adSessionError];
    [adSession start];
    VLog(@"OM_vmax : Native Ad Session Started");
    NSError *adEvtsError;
    OMIDZeedigitalesselgroupAdEvents *adEvents = [[OMIDZeedigitalesselgroupAdEvents alloc] initWithAdSession:adSession error:&adEvtsError];
    VLog(@"OM_vmax : Native Ad Impression registered");
    NSError *impError;
    [adEvents impressionOccurredWithError:&impError];
    NSError *adEventsEroor;
    omidVideoEvents = [[OMIDZeedigitalesselgroupMediaEvents alloc] initWithAdSession:adSession error:&adEventsEroor];
    if (omidVideoEvents != nil){
        VLog(@"OM_vmax : OMIDZeedigitalesselgroupMediaEvents created");
    }
}

-(void)endNativeAdSession {
    if (adSession != nil) {
        VLog(@"OM_vmax : Terminating OM Native Ad session");
        [adSession finish];
    }
    adSession = nil;
}

-(void)createViewabilityInstance {
    [self activateOMSDK];
}

-(void)registerNativeAdView:(UIView *)adview {
    if (isOMSdkActivated) {
        [adSession setMainAdView:adview];
        VLog(@"OM_vmax : Native Ad Session Registered");
    }
}

- (void)dispatchVolumeChangeEvent:(VMaxVolumeEvents)event withLevel:(CGFloat)volume{
    VLog(@"OM_vmax Volume change :%f ",volume);
    switch (event) {
        case MUTED:
            [omidVideoEvents volumeChangeTo:0.0];
            break;
        case UNMUTED:
            [omidVideoEvents volumeChangeTo:volume];
            break;
        case VOLUME_CHANGE:
            [omidVideoEvents volumeChangeTo:volume];
            break;
        default:
            break;
    }
    
}

@end

