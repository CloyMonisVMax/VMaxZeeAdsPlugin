//
//  ICompanionEventsReceiver.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 29/09/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "VMaxCache.h"

@protocol ICompanionEventsReceiver <NSObject>
@required
- (void)onCompanionShow:(NSString *)masterAdViewId withAdSlotId:(NSString *)adSlotId andVmaxCache:(VMaxCache *)vmaxCache;
- (void)onCompanionClose:(NSString *)masterAdViewId withAdSlotId:(NSString *)adSlotId;
- (void)doPause:(NSString *)masterAdViewId withAdSlotId:(NSString *)adSlotId;
- (void)doResume:(NSString *)masterAdViewId withAdSlotId:(NSString *)adSlotId;
- (void)doUpdate:(NSString*)masterAdViewId withMessage:(NSString*)message;//LeadGen
- (void)onCompanionError; //3.14.7 Errors_ 603
@end
