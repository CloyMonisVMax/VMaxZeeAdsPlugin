//
//  VMaxAdBreak.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 06/08/21.
//  Copyright © 2021 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMaxAdMetaData.h"
#import "VMaxAdBreakEvents.h"
#import "VMaxError.h"
#import "VMaxAdEvents.h"

typedef NS_ENUM(NSUInteger, VMaxAdBreakStatus) {
    UNOWNED,
    INITILIZED,
    REQUESTED,
    READY,
    STARTED,
    ERROR,
    COMPLETED
};

NS_ASSUME_NONNULL_BEGIN

@interface VMaxAdBreak : NSObject

@property (nonatomic, weak) id<VMaxAdBreakEvents> delegate;

@property (nonatomic, strong) id<VMaxAdEvents> vmaxAdEvents;

@property (nonatomic, strong) id<VMaxCompanionAdEvents> vmaxCompaionAdEvents;

@property (nonatomic, strong) NSString *adSpotBanner;

-(id)initWithVMaxMetaData:(VMaxAdMetaData*)adMetaData viewController:(UIViewController*)viewController;

-(void)start;

-(void)play:(UIView*)view;

-(void)pause;

-(void)resume;

-(void)setLayoutInfo:(NSDictionary*)layoutInfo;

-(VMaxAdBreakStatus)get;

-(void)updateVolumeChange:(VMaxVolumeEvents)event withLevel:(CGFloat)volume;

-(void)invalidate;


@end

NS_ASSUME_NONNULL_END
