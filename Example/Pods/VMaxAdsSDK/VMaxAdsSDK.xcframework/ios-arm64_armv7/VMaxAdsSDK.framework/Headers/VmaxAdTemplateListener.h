//
//  VmaxAdTemplateListener.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 04/06/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VmaxAdTemplateListener : NSObject

- (void)onAttachSuccess:(UIView *)viewGroup;

- (void)onAttachFailed:(NSString *)errorMessage;

- (void)onAdEnterFullscreen;

- (void)onAdExitFullscreen;

- (void)registerTemplate;

@end
NS_ASSUME_NONNULL_END


