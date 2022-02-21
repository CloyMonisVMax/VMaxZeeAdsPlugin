//
//  VMaxAdCustomizer.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMaxAdCustomizer : NSObject
NS_ASSUME_NONNULL_BEGIN
@property (assign,nonatomic) UIInterfaceOrientationMask supportOrientationMaskOnMediaExpand;

//@property (assign,nonatomic) BOOL   enableTransitionLoader;//1049_1 
@property (assign,nonatomic) BOOL   disableTransitionLoader;
//@property (copy)AVLayerVideoGravity  playerGravity; //..NEWLY ADDED
@property (assign,nonatomic) BOOL   hideAdBadge;
@property (assign,nonatomic) BOOL   disableAutoHandlingMediaViewOnExpand;
@property (assign,nonatomic) BOOL   hideNumericalAdProgress;
@property (assign,nonatomic) BOOL   hideSkipAd;
@property (assign,nonatomic) BOOL   hideCta;
@property (assign,nonatomic) BOOL   hideSkipAfterCounter;
@property (assign,nonatomic) BOOL   hideProgressBar;
@property (assign,nonatomic) BOOL   hideBottomStrip;
@property (assign,nonatomic) BOOL   hideExpandControl;
@property (assign,nonatomic) BOOL   hidePlaybackControl;
@property (strong,nonatomic) NSString * adBadgeText;
@property (assign,nonatomic) CGFloat    adBadgeTextSize;
@property (strong,nonatomic) NSString * adBadgeTextColor;
@property (strong,nonatomic) NSString * bottomStripBgColor;


@property (assign,nonatomic) CGFloat    numericalAdProgressTextSize;
@property (strong,nonatomic) NSString * numericalAdProgressTextColor;
@property (strong,nonatomic) NSString * numericalAdProgressBarFillColor;

@property (strong,nonatomic) NSString * progressbarColor;

@property (strong,nonatomic) NSString * skipAdIcon_Name;

@property (strong,nonatomic) NSString * skipAdText;
@property (assign,nonatomic) CGFloat    skipAdTextSize;
@property (strong,nonatomic) NSString * skipAdTextColor;


@property (strong,nonatomic) NSString * ctaText;
@property (assign,nonatomic) CGFloat    ctaTextSize;
@property (strong,nonatomic) NSString * ctaTextColor;
@property (strong,nonatomic) NSString * ctaTextBgColor;

@property (strong,nonatomic) NSString * skipAfterCounterText;
@property (assign,nonatomic) CGFloat    skipAfterCounterTextSize;
@property (strong,nonatomic) NSString * skipAfterCounterTextColor;
@property (strong,nonatomic) NSString * skipAfterCounterTextBgColor;

@property (strong,nonatomic) NSString * skipAdTextBgColor;
@property (strong,nonatomic) NSString * adLoaderColor; //..(3.10.9) AD: Ad loader color as hex string e.g. '#ffffff'
@property (strong,nonatomic) NSString * adContainerBgColor; //..(3.10.9) AD: Ad container background color as hex string e.g. '#000000'
NS_ASSUME_NONNULL_END
@end
