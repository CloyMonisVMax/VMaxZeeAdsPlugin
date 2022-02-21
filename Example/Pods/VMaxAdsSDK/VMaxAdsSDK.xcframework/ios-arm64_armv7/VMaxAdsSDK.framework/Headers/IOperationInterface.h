//
//  IOperationInterface.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 11/09/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOperationEventReceiver.h"

NS_ASSUME_NONNULL_BEGIN

@interface IOperationInterface : NSObject

-(NSString *_Nullable)getOperationId;

-(void)onUserInteraction:(NSString *_Nullable)data withReceiver:(id<IOperationEventReceiver>)receiver andViewController:(UIViewController*)viewController;

//hc
-(void)onUserInteraction:(NSString *_Nullable)data withEventUrl:(NSString *)eventUrl;
//..

@end

NS_ASSUME_NONNULL_END
