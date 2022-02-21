//
//  VmaxDataListener.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 04/06/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "VMaxAdView.h"
//#import "VMaxAdSDK.h"
//#import "VMaxAdDelegate.h"
//#import "VMaxAdPartner.h"
//#import "VMaxNativeAd.h"
//#import "VMaxVideoAd.h"
//#import "VmaxAdTemplateListener.h"
//#import "VMaxAdError.h"
//#import "VmaxTracker.h"
@class VMaxAdView;
@class VmaxTracker;
#import "VMaxAdSDK.h"

@class VmaxTracker;


NS_ASSUME_NONNULL_BEGIN

@interface VmaxDataListener : NSObject
- (void)onSuccess:(NSString *)data vmaxAdView:(VMaxAdView *)vmaxAdView;
- (void)onFailure:(VMaxAdError *)error vmaxAdView:(VMaxAdView *)vmaxAdView;
- (void)onAdLoaded:(NSString *)data vmaxAdView:(VMaxAdView *)vmaxAdView;
- (void)onAdElementClicked:(VmaxAdAsset)typeClicked vmaxAdView:(VMaxAdView *)vmaxAdView;
- (void)onAdSwiped:(VMaxUserGestures)gestureType vmaxAdView:(VMaxAdView *)vmaxAdView;//zeeShorts Changes 0.0.8
- (void)onAdCloseLoaded:(VMaxAdView *)vmaxAdView;
- (void)onAdSkipables:(VMaxAdView *)vmaxAdView;
- (void)onMediaStarted:(VMaxAdView *)vmaxAdView;
- (void)onMediaEnded:(VMaxAdView *)vmaxAdView;
- (void)onAdClicked:(VMaxAdView *)vmaxAdView;  //zeeShorts Changes 0.0.2

@end
NS_ASSUME_NONNULL_END
