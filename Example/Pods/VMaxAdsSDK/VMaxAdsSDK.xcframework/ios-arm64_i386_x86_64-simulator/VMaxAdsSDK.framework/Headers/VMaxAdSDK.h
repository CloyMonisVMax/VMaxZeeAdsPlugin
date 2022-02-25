


#import <Foundation/Foundation.h>
#import "VMaxAdPartner.h"
#import "VMaxTimeout.h"
#import <CoreLocation/CoreLocation.h>

//3.14.5 shorts
typedef NS_ENUM(NSUInteger, AdOptionKey) {
    SCREEN_TYPE
};

typedef NS_ENUM(NSUInteger, AdOptionValue) {
    SCREEN_MID,
    SCREEN_END
};

typedef NS_ENUM(NSUInteger, VmaxAdAsset) {
    asset_ImageIcon,//brand page
    asset_Title,//brand page
    asset_Replay,
    asset_False_Replay
};

typedef NS_ENUM(NSUInteger, VMaxUserGestures) {
    GESTURE_SWIPE_UP,
    GESTURE_SWIPE_DOWN
};


//3.14.5 shorts..

//3.12.10 VMaxMediaType refactored to MediaType
typedef NS_ENUM(NSUInteger, VMaxMediaType) {
    VMAX_MEDIA_TYPE_VIDEO,
    VMAX_MEDIA_TYPE_AUDIO, //..(3.11.0)
    VMAX_MEDIA_TYPE_IMAGE, //3.10.16 Added
    VMAX_MEDIA_TYPE_ALL, //3.10.16 Added
};

typedef NS_ENUM(NSUInteger, VMAX_LogLevel) {
    LEVEL_NONE,
    LEVEL_DEBUG
};

typedef NS_ENUM(NSUInteger, ContentVideoPlayer) {
    AVPLAYER,
    OTHER,
};


typedef NS_ENUM(NSUInteger, ContentVideoHandler) {
    IMA_SDK,
    OTHER_SDK,
};

typedef NS_ENUM(NSUInteger, ViewabilityPartner) {
    MOAT = 2
};
typedef NS_ENUM(NSUInteger, VMaxUserGender) {
    kVMaxUserGender_Male   = 'M',
    kVMaxUserGender_Female = 'F'
};
//..(3.9.5) Removed
/*!
 @enum      VMaxCountryOption
 @abstract  Country property for Optional user property.
 @field     kVMaxCountries_Exclude, Exclude the countries listed in the country list.
 @field     kVMaxCountries_Include, Include the countries listed in the country list.
 
 typedef NS_ENUM(NSUInteger, VMaxCountryOption) {
 kVMaxCountries_Exclude = 1,
 kVMaxCountries_Allow
 };
 */

@interface VMaxAdUser : NSObject
NS_ASSUME_NONNULL_BEGIN 
@property (assign, nonatomic) VMaxUserGender   gender;
@property (assign, nonatomic) int age;
@property (strong, nonatomic) NSString * city;
@property (strong, nonatomic) NSString * email;
//..(3.10.25)
@property (assign, nonatomic) int pinCode;
@property (strong, nonatomic) NSString* state;
@property (strong, nonatomic) NSString* loginId;
//..
NS_ASSUME_NONNULL_END
@end



/** //..(3.9.0) Comment this FireMangaer
 @abstract  The VMaxAdSDKDelegate which notifies on completion of conversions.
 @discussion This method must be implemented in order to be notified of reward on conversion.
 @param reward, The reward to be given.
 
 @protocol VMaxAdSDKDelegate <NSObject>
 @required
 - (void)onAdReward:(NSInteger)reward;
 @end
 */

@class VMaxAdError;

typedef void (^VMaxAdSDKResponseBlock)(VMaxAdError * _Nonnull error);


//3.13.3 S_1049_7 pa
typedef struct{
    int currrent;
    int total;
}VMaxMediaProgress;
//..


@interface VMaxAdSDK : NSObject
NS_ASSUME_NONNULL_BEGIN
//..(3.9.0) Comment this FireMangaer
/*
 
 @abstract Initializes the VMaxAdSDK with the specified accountKey (mandatory)
 @discussion This method must be called as early as possible in the applications life-cycle.
 Calling this multiple times will have no additional effects."
 @param accountKey, The VMAX accountKey to initialise the SDK.
 @param delegate, The delegate to send callbacks to.
 @param VMaxAdSDKResponseBlock, The response block invoked on completion. Check error for failure, is nil if initialisation succeeded.
 
 + (void)initWithAccountKey:(NSString *)accountKey delegate:(id<VMaxAdSDKDelegate>)delegate onCompletion:(VMaxAdSDKResponseBlock)completion;
 */
/**
 @abstract Retrieve a string-based representation of the SDK version.
 @discussion The returned string will be in the form of "<Major Version>.<Minor Version>.<External Revision>.<Internal Revision>"
 @return The current VMAX Ad SDK version string.
 */
+ (NSString *)getSDKVersion;

/**
 @abstract Informs if the SDK is ready.
 @discussion The sdk if ready.
 @return BOOL, SDK ready or not.
 
 + (BOOL)isReady; //..(3.9.0) Comment this FireMangaer
 */

/**
 @abstract Informs the SDK of async mediation rewards.
 @discussion The sdk initiates observing to fetch & give rewards.
 @param mediation, id, the mediation to observe.
 */
//+ (void)rewardedMediationDidComplete:(id)mediation;
//..Audio (3.6.26) deprecated
//+ (void)deviceVolumeChanged:(NSNotification *)notification;

+(NSString *)getAdapterParterName:(VMaxAdaperClass)classObj;


//..LOG Property (3.6.25)
+(void)setLogLevel:(VMAX_LogLevel)logLevel;

//..(3.6.26)
+(void)setUserGender:(VMaxUserGender )gender;
+(void)setUserAge:(int)age; // (3.10.25) UPDATED SIGNATURE
+(void)setUserCity:(NSString *)city;
+(void)setUserEmail:(NSString *)email;
+(void)setUserLoginId:(NSString*)loginId; // (3.10.25)
+(void)setCustomData:(NSMutableDictionary *)globalCSData;// (3.10.25)
+(NSString *)getSHA1:(NSString *)str; // (3.10.25)
+(NSString *)getSHA2:(NSString *)str;
+(void)setAccountId:(long)accountId; // 12124536547  optional Story id 307  //story accountid
/**
 * Provide the user's location to the SDK for targetting purposes.
 * @param location: The location of the user
 */
+(void)setLocation:(CLLocation*)location;

+(void)setQueue:(dispatch_queue_t)queue;

typedef NS_ENUM(NSUInteger, Environment) {
    PRODUCTION,
    SIT,
    REPLICA,
    DISABLE,
};

+(void)setIMSI:(NSString * _Nonnull)IMSI;
+(void)setEnvironment:(Environment)jsBasePath;
+(void)setAppGroupIndentity:(NSString *_Nullable)appGroupName __attribute__((nonnull));
+(BOOL)clearCachedMedia:(VMaxMediaType)mediaType;
+(void)disableAdClicksInSafariController:(BOOL)enable;
//..(3.10.25) ADDED
+(void)setUserPinCode:(int)pinCode;
+(void)setUserState:(NSString *)state;
//..

+(void)requestIDFA:(void (^)(void))completionBlock;//3.14.8 //3.14.4 JIO

//3.14.11 Jio 3.14.1 ppid story
+(NSString *)getPPID:(NSString *)adSpot;
//..

+(VMaxTimeout*)getTimeout; //3.15.1

+(void)setTimeout:(VMaxTimeout*)timeout; //3.15.1

+(void)clearUserDataFilter; //3.15.4 VMaxUserDataFilter

NS_ASSUME_NONNULL_END
@end
