//
//  VMaxTimeout.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 28/10/21.
//  Copyright © 2021 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMaxAdSDK.h"

#define kAdRequestTimeout  8
#define kMediaLoadTimeout  6

typedef NS_ENUM(NSUInteger, VMaxConnectionType){
    VMaxConnectionTypeUnknown = 0,
    VMaxConnectionTypeWifi = 1,
    VMaxConnectionTypeCarrier = 2,
    VMaxConnectionType2G = 3,
    VMaxConnectionType3G = 4,
    VMaxConnectionType4G = 5,
    VMaxConnectionTypeLAN = 6,
    VMaxConnectionType5G = 7,
};

typedef NS_ENUM(NSUInteger, VMaxTimeoutType) {
    VMaxTimeoutTypeAdRequest = 1,
    VMaxTimeoutTypeMediaLoad = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface VMaxTimeout : NSObject

- (int)getTimeout:(VMaxConnectionType)connectionType type:(VMaxTimeoutType)type;

- (void)configure:(VMaxConnectionType)connectionType type:(VMaxTimeoutType)type value:(int)value;

@end

NS_ASSUME_NONNULL_END
