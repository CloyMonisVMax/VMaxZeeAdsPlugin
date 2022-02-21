//
//  VMaxVideoAd.h



#import <UIKit/UIKit.h>

/*!
 @enum      VMaxVideoControlsState
 @abstract  Control state of video control buttons
 @field     VMaxVideoControlsState_Normal, Normal video contol state.
 @field     VMaxVideoControlsState_Selected, Video control state selected
 */
typedef NS_ENUM(NSUInteger, VMaxVideoControlsState) {
    VMaxVideoControlsState_Normal,
    VMaxVideoControlsState_Selected,
};

@interface VMaxVideoAd : NSObject

@property (nonatomic,strong,readonly) UIImage *muteControlButtonImage;
@property (nonatomic,strong,readonly) UIImage *unMuteControlButtonImage;
@property (nonatomic,strong,readonly) UIImage *fullSreenControlButtonImage;
@property (nonatomic,strong,readonly) UIImage *exitFullSreenControlButtonImage;
@property (nonatomic,strong,readonly) UIImage *skipControlButtonImage;
@property (nonatomic,strong,readonly) NSNumber *skipDuration;
@property (nonatomic,strong) UIColor *skipProgressIndicatorColor;
@property (nonatomic,strong) UIColor *timerLabelTextColor;
@property (nonatomic,assign) BOOL fullscreen;

/*!
 @function      setMuteControlButtonImage:forState
 @abstract      Set mute button control image forState
 @param         image, UIImage.
 @param         controlState, VMaxVideoControlsState.
 */
-(void) setMuteControlButtonImage:(UIImage*)image forState:(VMaxVideoControlsState)controlState;

/*!
 @function      setFullScreenControlButtonImage:forState
 @abstract      Set full screen button control image forState
 @param         image, UIImage.
 @param         controlState, VMaxVideoControlsState.
*/
-(void) setFullScreenControlButtonImage:(UIImage*)image forState:(VMaxVideoControlsState)controlState;
/*!
 @function      setSkipControlButtonImage:
 @abstract      Set skip button control image.If it is not set default image will be used
 @param         image, UIImage.
 */
-(void) setSkipControlButtonImage:(UIImage*)image;

/*!
 @function      setSkipDuration:
 @abstract      Set custom skip duration for VAST ads only. Overrides the skip duration set in VAST response only if greater. Has no effect if set to less than skip duration in VAST response.
 @param         skipDuration, NSNumber.
 */
- (void)setSkipDuration:(NSNumber*)skipDuration;

@end
