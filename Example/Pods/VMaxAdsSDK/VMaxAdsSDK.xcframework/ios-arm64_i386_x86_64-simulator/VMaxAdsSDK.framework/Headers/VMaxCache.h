//
//  VMaxCache.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 28/09/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VMaxCache : NSObject

@property (nonatomic) NSInteger height;

@property (nonatomic) NSInteger width;

@property (strong, nonatomic) id<VMaxCompanionDelegate> delegateCompanion;

@property (strong, nonatomic) VMaxAdView *adView;

@property (nonatomic,strong) NSString *adSlotId;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary andHostVC:(UIViewController *)hostVC andVMaxAddress:(NSString *)vmaxAddress;

-(NSString*)getMarkup;

-(NSArray*)getClickTrackers;

-(void)notifyCreativeViewTrackers;

-(UIView*)getCache;

-(void)doUpdate:(NSString*)message;

-(void)getContentHeight:(void(^)(int))webContentHeight; //3.14.9 companion adaptive

-(void)invalidate;

@end

NS_ASSUME_NONNULL_END
