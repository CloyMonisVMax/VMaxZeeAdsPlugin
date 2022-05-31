//
//  VMaxGoogleIMAAdapter.h

#import <UIKit/UIKit.h>
@import GoogleInteractiveMediaAds;
@import VMaxAdsSDK;

@interface VMaxGoogleIMAAdapter : NSObject <VMaxCustomAd>

@property (nonatomic, weak) id<VMaxCustomAdListener> delegate;
@property (nonatomic, strong) UIViewController* parentViewController;

@end


//@interface VMaxAbc : NSObject
//
//@end
//
//@implementation VMaxAbc
//
//@end
