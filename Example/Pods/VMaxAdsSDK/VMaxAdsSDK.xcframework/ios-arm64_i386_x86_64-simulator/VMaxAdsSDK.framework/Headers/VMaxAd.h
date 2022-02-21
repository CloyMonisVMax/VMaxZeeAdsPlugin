//
//  VmaxTwo.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 11/06/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "VmaxTracker.h"
#import "VmaxDataListener.h"
//#import "VmaxAdTemplateListener.h"
@class VmaxAdTemplateListener;
@class VmaxTracker;

NS_ASSUME_NONNULL_BEGIN

@interface VMaxAd : NSObject
@property (strong, nonatomic) NSString* iconUrl;
@property (strong, nonatomic) NSString* postId;
@property (strong, nonatomic) NSString* adOffset;
@property (strong, nonatomic) NSString* adId;
@property (nonatomic, strong) VmaxTracker *vmaxTracker;

- (NSString *)getIconUrl;
- (NSString *)getPostId;
- (NSString *)getAdOffset;
- (void)getAdId:(NSString *)adId;
- (VmaxTracker *)getVmaxTracker;
- (void)parse:(NSData *)payload adData:(NSDictionary *)adData vmaxDataListener:(VmaxDataListener *)vmaxDataListener vmaxAdView:(VMaxAdView *)vmaxAdView templateName:(NSString *)templateName;
- (void)render:(VmaxAdTemplateListener *)vmaxAdTemplateListener adScreenType:(NSNumber *)adScreenType viewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END

