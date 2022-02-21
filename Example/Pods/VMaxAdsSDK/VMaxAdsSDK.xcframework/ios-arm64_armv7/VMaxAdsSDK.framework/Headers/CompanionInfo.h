//
//  CompanionInfo.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 29/03/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CompanionInfo : NSObject

@property (nonatomic,strong) NSString *width;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *adSlotId;
@property (nonatomic,strong) NSString *htmlResource;
//@property (nonatomic,strong) NSString *trackingEvents;
@property (nonatomic,strong) NSMutableArray* trackingEvents;
@property (nonatomic,assign) BOOL existInCompanionList;
@property (nonatomic,strong) NSMutableDictionary *dictForWebRender;
@property (nonatomic,strong) NSMutableArray* clickTrackingEvents;//3.14.3 S_476 pa

@end

NS_ASSUME_NONNULL_END
