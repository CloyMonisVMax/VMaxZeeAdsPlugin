//
//  VMaxCompanionDelegate.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 26/08/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VMaxCompanionDelegate <NSObject>

- (void)onCompanionReady:(VMaxAdView *)adView;

- (void)onCompanionRender:(VMaxAdView *)adView;

- (void)onCompanionError:(VMaxAdView *)adView;

- (void)onCompanionClose:(VMaxAdView *)adView;

- (void)onCompanionClick:(VMaxAdView *)adView;

- (void)onCompanionSkip:(VMaxAdView *)adView;

- (void)onCompanionComplete:(VMaxAdView *)adView;

@end
