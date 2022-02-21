//
//  VmaxNativeAdLayoutFactory.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 23/10/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VMaxAdSpotSize) {
    CUSTOM, 
    DEFAULT,
    BANNER,
    BILLBOARD,
    INTERSTITIAL,
    INTERSTITIAL_POTRAIT,
    INTERSTITIAL_LANDSCAPE
};

NS_ASSUME_NONNULL_BEGIN

@interface VmaxNativeAdLayoutFactory : NSObject

+ (id _Nullable )getInstance;

- (void)addLayout:(NSString *)layoutName withLayout:(NSString *)layout andAdSpotSize:(VMaxAdSpotSize)adSpotSize;

//- (NSString *)getLayoutClassName:(NSString *)layoutName andAdSpotSize:(VMaxAdUX)adUx;

- (NSString *)getLayoutName:(NSString *)layoutName andAdSpotSize:(NSString *)adSpotSize;

@end

NS_ASSUME_NONNULL_END
