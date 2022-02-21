//
//  VMaxAdError.h



#import <Foundation/Foundation.h>

extern NSString* const kVMaxAdErrorDomain;
extern NSString* const kVMaxAdErrorMessage;
extern NSString* const kVMaxAdErrorDetail;
extern NSString* const kVMaxAdErrorDetailNoFill;
extern NSString* const kVMaxAdErrorDetailAdRequestNotAllowed;
extern NSString* const kVMaxAdErrorDetailSDKInitFailed;
extern NSString* const kVMaxAdErrorDetailNetworkError;
extern NSString* const kVMaxAdErrorDetailAdParamsMissing;
extern NSString* const kVMaxAdErrorDetailRenditionError;
extern NSString* const kVMaxAdErrorDetailParsingFailed;
extern NSString* const kVMaxAdErrorDetailUnknownError;
extern NSString* const kVMaxAdErrorDetailAdExpired;
extern NSString* const VMaxAdErrorDescription_AdRequestCancelled;
extern NSString* const kVMaxAdErrorTitleAdSkipped;//3.13.0 1015 pa
extern NSString* const kVMaxAdErrorDetailAdSkipped; // 3.11.7 Added
extern NSString* const kVMaxAdErrorDescriptionMediaPlayerFailed;

typedef NS_ENUM (NSInteger, ErrorCode) {
    kVMaxAdErrorNoFill = 1001,
    kVMaxAdErrorAdRequestNotAllowed = 1002,
    kVMaxAdErrorPermissionsMissing = 1003,
    kVMaxAdErrorTimeout = 1004,
    kVMaxAdErrorInternalServerError = 1005,
    kVMaxAdErrorSDKInitFailed = 1006,
    kVMaxAdErrorAdMismatch = 1007,
    kVMaxAdErrorNetworkError = 1008,
    kVMaxAdErrorAdParamsMissing = 1009,
    kVMaxAdErrorAdRenditionFailed = 1010,
    kVMaxAdErrorAdParsingFailed = 1011,
    kVMaxAdErrorUnknownError = 1012,
    kVMaxAdErrorInvalidAdRequest = 1013,
    kVMaxAdErrorAdExpired = 1014,
    kVMaxError_auto_closed = 1015,
    kVMaxAdErrorDeviceMute = 1016,
    kVmaxAdErrorAdSkipped = 1032, // 3.11.7 Added
    kVmaxAdPodTimeout = 1031, // 3.11.7 Added
    kVMaxMediaPlayerFailed = 1033, //3.12.1
    kVMaxAdErrorLayoutNotDefined = 1034, //3.14.6 NativeLayoutFactory
    kVMaxAdBreakInitError = 1050 //3.15.0
};

/**
 @abstract      Custom VMAX error
 @discussion    Defines a custom error interface for ad related errors
 @property      errorTitle, NSString. A descriptive title for the error.
 @property      code, NSInteger. Query for (VMaxAdError*)instance.code for error code
 @property      localizedDescription, NSString. Query for (VMaxAdError*)instance.localizedDescription for descriptive information about the error.
 */
@interface VMaxAdError : NSError

@property (nonatomic, readonly) NSString *errorTitle;

@end
