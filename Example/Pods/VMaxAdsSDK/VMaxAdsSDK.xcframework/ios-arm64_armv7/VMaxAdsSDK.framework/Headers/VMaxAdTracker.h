//
//  VMaxAdTracker.h
//  VMaxAdSDK
//
//  Created by Cloy Monis on 13/11/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

#import "VMaxEventTracker.h"

@protocol VMaxAdTracker <VMaxEventTracker>

-(void)onImpression;
-(void)onClick;

@end

