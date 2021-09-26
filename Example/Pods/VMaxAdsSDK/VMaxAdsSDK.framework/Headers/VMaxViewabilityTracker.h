//
//  VMaxViewabilityTracker.h


#import <Foundation/Foundation.h>


@interface VMaxViewabilityTracker : NSObject
typedef NS_ENUM(NSUInteger, VOLUME_EVENTS) {
    MUTED,
    UNMUTED
};
-(void) dispatchEvent:(id)IMAAdEvent adLayer:(CALayer *)adCaLayer IMAAdManager :(id)adsManager;
@end
