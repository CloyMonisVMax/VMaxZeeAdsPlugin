//
//  VMaxCustomAd.h



//#define VLog(fmt, ...) NSLog((@"VMAX: %s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__)
#define VLog(fmt...) VMAXNSLog (fmt);
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "VMaxCustomAdListener.h"

#define kVMaxNotificationOnClosingLandingPage @"OnClosingLandingPage"
#define kVMaxNotificationOnOpeningLandingPage @"OnOpeningLandingPage"

// User Info
extern NSString* const kVMaxCustomAdExtras_Gender;     // NSString can be either kVMaxCustomAdExtras_GenderMale or kVMaxCustomAdExtras_GenderFemale
extern NSString* const kVMaxCustomAdExtras_Email;      // NSString of EMail.
extern NSString* const kVMaxCustomAdExtras_Age;        // NSString of Age.
extern NSString* const kVMaxCustomAdExtras_City;       // NSString City Name.
extern NSString* const kVMaxCustomAdExtras_Keyword;    // NSString Search Keyword.
extern NSString* const kVMaxCustomAdExtras_adSpaceKey;
// Attributes for kVMaxCustomAdExtras_Gender key.
extern NSString* const kVMaxCustomAdExtras_GenderMale;
extern NSString* const kVMaxCustomAdExtras_GenderFemale;

// User Location info
extern NSString* const kVMaxCustomAdExtras_LocationLatitude;   // NSNumber of Double datatype
extern NSString* const kVMaxCustomAdExtras_LocationLongitude;  // NSNumber of Double datatype.
extern NSString* const kVMaxCustomAdExtras_TestMode;  
extern NSString* const kVMaxCustomAdExtras_TestDevices;
extern NSString* const kVMaxCustomAdExtras_CurrencyName;

//Incontent Video Specific
extern NSString* const kVMaxCustomAdExtras_InContentVideoParams;
extern NSString* const kVMaxCustomAdExtras_InContentVideoContentUrl;
extern NSString* const kVMaxCustomAdExtras_InContentVideoContentPlayer;
extern NSString* const kVMaxCustomAdExtras_InContentVideoContentPlayerView;

//Ad Settings
extern NSString* const kVMaxCustomAdExtras_AdSettings;

extern NSString* const kVMaxCustomAdExtras_AdUXType;

//Ad Size
extern NSString* const kVMaxCustomAdExtras_Scale;
extern NSString* const MEDIA_URL;


extern NSString* const kVMaxResponseParam_moat_macro;
extern NSString* const kVMaxResponseParam_moat_id;
extern NSString* const kVMaxResponseParam_moat_imaEvent;
extern NSString* const kVMaxResponseParam_moat_imaAdManger;
extern NSString* const kVMaxResponseParam_moat_playerLayer;
extern NSString* const kVMaxResponseParam_moat_AdSpotID;
//Available Ad Sizes
//extern NSString* const kVMaxCustomAdAdSize_320x50;
//extern NSString* const kVMaxCustomAdSize_728x90;
//extern NSString* const kVMaxCustomAdSize_300x250;
//extern NSString* const kVMaxCustomAdSize_480x320;
//extern NSString* const kVMaxCustomAdSize_320x480;
//extern NSString* const kVMaxCustomAdSize_480x800;
//extern NSString* const kVMaxCustomAdSize_1024x600;
//extern NSString* const kVMaxCustomAdSize_800x480;
//extern NSString* const kVMaxCustomAdSize_600x1024;
//



@protocol VMaxCustomAd <NSObject>
@required

-(void)loadCustomAd:(NSDictionary*)inParams
       withDelegate:(id<VMaxCustomAdListener>)inDelegate
     viewController:(UIViewController*)parentViewController
         withExtras:(NSDictionary*)inExtraInfo;

-(void)showAd;

-(void)invalidateAd;

@optional

- (void)playAd;
- (void)pauseAd;
//..3.6.12
- (UIView *)getPrimaryView:(CGFloat)width;
-(void)updateCTAButton:(UIButton*)btn;
-(void)updateMediaView:(id)mediaView;
-(BOOL)canDurationPassInRequest; //3.15.8 sce
void VMAXNSLog(NSString *format, ...);
@end


