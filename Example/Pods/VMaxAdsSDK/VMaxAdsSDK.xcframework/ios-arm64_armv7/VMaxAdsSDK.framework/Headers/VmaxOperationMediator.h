//
//  VmaxOperationMediator.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 11/09/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOperationInterface.h"
#import "IOperationEventReceiver.h"

NS_ASSUME_NONNULL_BEGIN

@interface VmaxOperationMediator : NSObject

+ (id _Nullable )getInstance;

- (void)registerOperation:(IOperationInterface *_Nullable)ioperationInterface;

- (NSString *_Nullable)getOperations;

- (void)handleOperations:(NSString *_Nullable)schemeUrl withReceiver:(id<IOperationEventReceiver>)receiver withViewController:(UIViewController*)viewController;

//hc
- (void)handleOperation:(NSString *_Nullable)data withEventUrl:(NSString *)eventUrl;
//..

@end

NS_ASSUME_NONNULL_END
