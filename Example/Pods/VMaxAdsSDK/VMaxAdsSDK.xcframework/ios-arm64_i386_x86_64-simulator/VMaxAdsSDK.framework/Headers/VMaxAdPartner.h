//
//  VMaxAdPartner.h


#import <Foundation/Foundation.h>

// Ad Partners
extern NSString* const kVMaxAdPartner_AdColony;
extern NSString* const kVMaxAdPartner_Chartboost;
extern NSString* const kVMaxAdPartner_Facebook;
extern NSString* const kVMaxAdPartner_Flurry;
extern NSString* const kVMaxAdPartner_AdX;
extern NSString* const kVMaxAdPartner_Admob;
extern NSString* const kVMaxAdPartner_GoogleIMA;
extern NSString* const kVMaxAdPartner_MilennialMedia;
extern NSString* const kVMaxAdPartner_Pokkt;
extern NSString* const kVMaxAdPartner_InMobi;
extern NSString* const kVMaxAdPartner_UnityAds;
//extern NSString* const kVMaxAdPartner_Tapjoy; //..(3.9.0) Comment this FireMangaer
extern NSString* const kVMaxAdPartner_Vungle;
extern NSString* const kVMaxAdPartner_VMAX;
extern NSString* const kVMaxAdPartner_MediationPartner_AdView;
extern NSString* const kVMaxAdPartner_AppNext; //.. (3.9.1) AppNext Ads
extern NSString* const kVMaxCustomAdAdapter_GADMobileAdsApplicationId; //..(3.9.12)
extern NSString* const kVMaxKey_ImageMain; //838.2
extern NSString* const kVMaxMaxDuration;
extern NSString* const kVMaxMaxDurationPerAd;
extern NSString* const kVMaxMediationDirectShow;
extern NSString* const kVMaxMediationPodIndex;
extern NSString* const kVMaxMediationTotalAds;

typedef NS_ENUM(NSUInteger, VMaxAdaperClass) {
    FacebookNativeAdapterClass,
    GoogleMobileAdsNativeAdapterClass,
    InmobiNativeAdapterClass,
    FlurryNativeAdapterClass,
    AppNextNativeAdapterClass
};

@interface VMaxAdPartner : NSObject
@property (nonatomic, readonly) NSString *partnerName;
@property (nonatomic, readonly) NSString *partnerSDKVersion;
@end
