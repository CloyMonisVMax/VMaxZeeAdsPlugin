//
//  VMaxAdBreakEvents.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 06/08/21.
//  Copyright © 2021 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMaxError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VMaxAdBreakEvents <NSObject>

-(void)onAdBreakRequest;
-(void)onAdBreakReady;
-(void)onAdBreakStart;
-(void)onAdBreakError:(VMaxError*)error;
-(void)onAdBreakComplete;

@end

NS_ASSUME_NONNULL_END

