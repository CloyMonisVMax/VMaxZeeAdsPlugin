//
//  VMaxRequest.h




#import "VMaxAdView.h"
#import "VMaxViewabilityTracker.h"

@protocol VMaxRequestDelegate <NSObject>

- (void)onSuccess;
- (void)onFailure:(NSError *)error;

@end

@interface VMaxRequest : VMaxAdView

@property (nonatomic, weak) id <VMaxRequestDelegate> requestDelegate;
//@property(nonatomic, copy,nullable) void(^responseCallback)(NSString  * VMAPString);
- (id)initWithVMAPId:(NSString *)VMAPId requestType:(VMaxRequestType)requestType;

- (void)setContentVideoDuration:(NSString *)duration;
- (void)setContentVideoPlayer:(ContentVideoPlayer)playerName andVersion:(NSString *)playerVersion;
- (void)setContentVideoHandler:(ContentVideoHandler)sdkName andVersion:(NSString *)versionName;
- (void)setSupportedViewabilityPartners:(NSArray *)partnerArray;
-(void)setCustomData:(NSDictionary *)customData;


- (void)fetchVMAPUrl;
- (NSString *)getVMAPUrl;
- (void)fetchVMAPXml;
- (NSString *)getVMAPXML;
-(VMaxViewabilityTracker *)getViewabilityTracker;

@end
