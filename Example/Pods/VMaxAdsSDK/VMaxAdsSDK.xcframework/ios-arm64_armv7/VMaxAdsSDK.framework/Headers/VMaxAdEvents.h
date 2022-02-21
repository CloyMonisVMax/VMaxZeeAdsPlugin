//
//  VmaxAdEvents.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 06/09/21.
//  Copyright © 2021 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VmaxAdInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VMaxAdEvents <NSObject>

-(void)onAdInit;
-(void)onAdReady:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdError:(VmaxAdInfo*)vmaxAdInfo error:(NSError *)error;
-(void)onAdRender:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdImpression:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaStart:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaFirstQuartile:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaMidPoint:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaThirdQuartile:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaEnd:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaExpand:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaCollapse:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdClick:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdSkip:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdClose:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdPause:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdResume:(VmaxAdInfo*)vmaxAdInfo;
-(void)onAdMediaBitrateChange:(float)indicatedBitrate;

@end

@protocol VMaxCompanionAdEvents <NSObject>

- (void)onCompanionReady;
- (void)onCompanionRender;
- (void)onCompanionError:(NSError *)error;
- (void)onCompanionClose;
- (void)onCompanionClick;

@end

NS_ASSUME_NONNULL_END

