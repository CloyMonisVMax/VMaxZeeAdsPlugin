//
//  VMaxOrganicRequest.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 10/12/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VmaxRequestListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface VMaxOrganicRequest : NSObject

-(id)initWithAdSpot:(NSString *)adSpot;

-(void)getAd:(id<VmaxRequestListener>)delegate withAdId:(NSString *)adId withCampaignId:(NSString *)campaignId;

@end

NS_ASSUME_NONNULL_END
