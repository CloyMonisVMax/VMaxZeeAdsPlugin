//
//  VmaxAdFactory.h
//  VMaxAdSDK
//
//  Created by admin_vserv on 05/06/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VmaxAdFactory : NSObject

@property (nonatomic) NSMutableDictionary *appTemplateList;

+ (id)getInstance;

- (void)addTemplate:(NSString *)templateName adData:(id)vmaxAdClassName;

- (void)setTemplate:(NSDictionary *)templates;
//- (VMaxAd *)getVmaxAdTemplate:(NSString *)templateName adData:(id)adData;
- (NSString *)getTemplateSignatures; //ae param changes
@end

NS_ASSUME_NONNULL_END
