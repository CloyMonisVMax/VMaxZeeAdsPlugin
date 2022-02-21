//
//  IOperationEventReceiver.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 11/09/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IOperationEventReceiver <NSObject>

-(void)onUpdate:(NSString *)message;

@end

