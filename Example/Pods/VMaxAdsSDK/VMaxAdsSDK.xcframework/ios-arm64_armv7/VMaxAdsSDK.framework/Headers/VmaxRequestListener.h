//
//  VmaxRequestListener.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 09/12/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol VmaxRequestListener <NSObject>

-(void)onSuccess;
-(void)onSuccess:(NSData *)response headers:(NSDictionary *)headers;
-(void)onFailure:(NSError *)error;

@end
