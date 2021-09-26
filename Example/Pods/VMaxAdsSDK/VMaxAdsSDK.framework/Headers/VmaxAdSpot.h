//
//  VmaxAdSpot.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 08/07/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "VMaxAdView.h"
@class VMaxAdView;

// in data listener for now
NS_ASSUME_NONNULL_BEGIN
@interface VmaxAdSpot : NSObject
@property (strong,nonatomic) VMaxAdView *vmaxAdView;
@property (strong,nonatomic) NSString *urls;
@property (strong,nonatomic) NSString *adId;
@property (strong,nonatomic) NSString *campaignId;
@property (strong,nonatomic) NSString *adSpotKey;
@property (strong,nonatomic) UIViewController *vc;
-(id)initWithAdSpotKey:(NSString *)adSpotKey vc:(UIViewController *)vc;
-(void)getAd:(NSString *)campaignId adId:(NSString *)adId;
-(void)invalidate;
-(void)setRefreshTime:(NSInteger)refreshTime;

@end
NS_ASSUME_NONNULL_END
