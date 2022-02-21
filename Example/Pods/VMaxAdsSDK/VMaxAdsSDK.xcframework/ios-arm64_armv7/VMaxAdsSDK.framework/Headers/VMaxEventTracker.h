//
//  VMaxEventTracker.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 13/11/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol VMaxEventTracker <NSObject>

-(void)onStart;
-(void)onFirstQuartile;
-(void)onMidpoint;
-(void)onThirdQuartile;
-(void)onComplete;
-(void)onPause;
-(void)onResume;
-(void)onRewind;
-(void)onMute;
-(void)onUnmute;
-(void)onFullscreen;
-(void)onExitFullscreen;
-(void)onClose;
-(void)onError;
-(void)logEvent:(NSString *)eventName;
-(void)logEvent:(nullable NSString*)eventName withAttr1:(nullable NSString*)attr1 andAttr2:(nullable NSString*)attr2 andAttr3:(nullable NSString*)attr3; 

@end
