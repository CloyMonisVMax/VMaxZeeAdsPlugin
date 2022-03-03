//
//  AdInfo.h
//  VMaxAdSDK
//
//  Created by mac  on 29/04/20.
//  Copyright © 2020 Vserv.mobi. All rights reserved.
//

//3.14.9

#import <Foundation/Foundation.h>

@interface MediaFile : NSObject

@property (strong, nonatomic) NSString* delivery;
@property (strong, nonatomic) NSString* bitrate;
@property (strong, nonatomic) NSString* width;
@property (strong, nonatomic) NSString* height;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* url;

@end

@interface VmaxAdInfo : NSObject

@property (strong, nonatomic) NSString* adDescription; // got
@property (assign, nonatomic) NSTimeInterval adDuration; // got
@property (strong, nonatomic) NSString* adTitle; // got
@property (assign,nonatomic) Boolean isSkippable;
//@property (strong, nonatomic) NSString* contentType;
@property (strong, nonatomic) NSString* adId; // got
@property (strong, nonatomic) NSString* adSystem; // got
//@property (nonatomic) NSInteger height; // got
//@property (nonatomic) NSInteger width; // got
@property (nonatomic) NSInteger totalAds; // not to do
@property (nonatomic) NSInteger adPosition; // not to do
//@property (nonatomic) NSTimeInterval* timeOffset; // current time of video
@property (nonatomic) Boolean* isBumper;
@property (nonatomic) NSInteger podIndex;
@property (nonatomic) NSInteger adIndex;
//@property (nonatomic) NSString mediaBitrate;
//@property (strong, nonatomic) NSString* creativeId;
//@property (strong, nonatomic) NSString* advertiserName;
@property (strong, nonatomic) MediaFile* mediaFile;
@property (strong, nonatomic) NSDictionary* adMeta;
@property (strong,nonatomic) NSString *videoLayout;

@end

@interface AdViewMetaData : NSObject

@property (nonatomic, strong) NSString *adspotKey;

@property (nonatomic, strong) NSString *adId;

@property (nonatomic, assign) UInt32 adDuration;

@property (nonatomic, assign) UInt32 mediationLocalBackupDuration;

@property (nonatomic, strong) VMaxAdView *adView;

@end
