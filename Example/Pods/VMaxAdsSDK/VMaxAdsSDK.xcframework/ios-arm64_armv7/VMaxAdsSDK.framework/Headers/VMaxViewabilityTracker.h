//
//  VMaxViewabilityTracker.h


#import <Foundation/Foundation.h>

@interface VMaxViewabilityTracker : NSObject
-(void) dispatchEvent:(id)IMAAdEvent adLayer:(CALayer *)adCaLayer IMAAdManager :(id)adsManager;
@end
