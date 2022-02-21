//
//  VMaxMediaView.h


#import <UIKit/UIKit.h>

#define VAST_CONTENT_MINIMUM_LENGTH 500

@class VMaxMediaView;
@class VMaxNativeAd;


@protocol VMaxMediaViewDelegate <NSObject>
@required
/*!
 @function  mediaViewDidLoad:
 @abstract  This method will be called when the mediaview loaded successfully.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
- (void)mediaViewDidLoad:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewFailedToLoad:
 @abstract  This method will be called when the mediaview is failed to load.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
- (void)mediaViewFailedToLoad:(VMaxMediaView *)mediaView error:(NSError*)error;

/*!
 @function  mediaViewDidClick:
 @abstract  This method will be called when the mediaview is clicked.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
- (void)mediaViewDidClick:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewDidExpand:
 @abstract  This method will be called when the mediaview expanded.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidExpand:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewDidCollapse:
 @abstract  This method will be called when the mediaview is collapsed
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidCollapse:(VMaxMediaView *)mediaView;

#pragma mark video playback -
@optional
/*!
 @function  mediaViewDidStart:
 @abstract  This method will be called when the mediaview playback starts.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidStart:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewDidPause:
 @abstract  This method will be called when the mediaview playback pauses.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidPause:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewDidResume:
 @abstract  This method will be called when the mediaview playback resumes.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidResume:(VMaxMediaView *)mediaView;

/*!
 @function  mediaViewDidComplete:
 @abstract  This method will be called when the mediaview playback completes.
 @param     mediaView, VMaxMediaView. The mediaview view which sent this event.
 */
-(void)mediaViewDidComplete:(VMaxMediaView *)mediaView;

@end

@interface VMaxMediaView : UIView
/*!
 @property delegate
 @abstract delegate for mediaview
 */
@property (nonatomic,weak) id<VMaxMediaViewDelegate> delegate;

/*!
 @property nativeAd
 @abstract native ad object
 */
@property (strong,nonatomic) VMaxNativeAd *nativeAd;

/*!
 @property controller
 @abstract controller for presenting the mediaview in  full screen
 */
@property (weak,nonatomic) UIViewController *controller;
/*!
 @property muted
 @abstract for setting muted state ON/OFF
 */
@property (assign,nonatomic) BOOL muted;
/*!
 @property autoplay
 @abstract for autoplaying media when loaded, defaults to YES
 */
@property (assign,nonatomic) BOOL autoplay;
/*!
 @function  initWithVMaxNativeAd:
 @abstract  initialise with native ad.
 @param     nativeAd, VMaxNativeAd.The native ad object.
 */
- (instancetype)initWithVMaxNativeAd:(VMaxNativeAd *)nativeAd;

/*!
 @property play
 @abstract for playing the ad
 */
- (void)play;

/*!
 @property pause
 @abstract for pausing ad playback
 */
- (void)pause;

- (void)sdkResumeAd;

- (void)sdkPauseAd;

@property (assign,nonatomic) BOOL nativeAutoplay;


- (void)removeAsSuperviewObserver;

//838.2
@property (strong,nonatomic) NSString* previewImage;
@property (assign,nonatomic) BOOL loop;
//..

@end
