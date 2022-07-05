//
//  VMaxCustomAdListener.h



#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "VMaxAdView.h"

@interface VMaxAdView (Private)
-(VMaxAdChoicePlacement)getAdBagedPosition;
-(BOOL)getNativeMuteStateForNonFullscreen;
@end

@protocol VMaxCustomAd;

@protocol VMaxCustomAdListener <NSObject>
@required

-(void)VMaxCustomAdDidLoadAd:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd
    didFailWithError:(NSError*)outError;

-(void)VMaxCustomAdDidShowAd:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAdOnAdClicked:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAdWillLeaveApplication:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAdDidDismissAd:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd
     didLoadAdInView:(UIView*)outAdView;

@optional
-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd mediationInfo:(NSDictionary*)info;

-(void)VMaxCustomAdWillPresentOverlay:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAdWillDismissOverlay:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd didInterruptRewardVideoWithUserResponseBlock:(void(^)(BOOL))userResponse;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd didFailedToPlaybackRewardVideo:(NSError*)error;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd didCompleteRewardVideo:(NSInteger)rewardAmount;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd didCompleteOfferWall:(NSInteger)rewardAmount;

-(void)VMaxCustomAdDidInteractAd:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAdDidFinishInteractAd:(id<VMaxCustomAd>)inCustomAd;

-(void)VMaxCustomAd:(id<VMaxCustomAd>)inCustomAd didComplete:(BOOL)didComplete watchedDuration:(float)watchedDuration totalDuration:(float)totalDuration;

-(void)onPlayerFullScreenButtonClicked;

-(void)VMaxCustomAdMediaStart;

-(void)VMaxCustomAdMediaEnd;

-(VMaxAdView *)getVmaxAdView;
//..(3.9.18) Added
-(void)AddSameConstraintFromParentView:(UIView *)parentView toChildView :(UIView*) childView :(void (^)(BOOL isDone))completeBlock;

-(void)VMaxCustomFirstQuartile; //3.15.8

-(void)VMaxCustomMidPoint; //3.15.8

-(void)VMaxCustomThirdQuartile; //3.15.8

-(void)VMaxCustomAdImpression; //3.15.8

-(void)VMaxCustomAdRender; //3.15.8

-(void)VMaxCustomAdFill:(id<VMaxCustomAd>)inCustomAd; //3.15.8

-(void)VMaxCustomAdPause; //3.15.8

-(void)VMaxCustomAdResume; //3.15.8

-(void)VMaxCustomAdProgress:(NSNumber*) currentDuration withTotalDuration:(NSNumber*)totalDuration; //3.15.10

@end
