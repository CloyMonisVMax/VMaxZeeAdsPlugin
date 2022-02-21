//
//  VMaxError.h


#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, DataErrorCode) {
    kVMaxErrorFetchingVastMetaData = 3003,
};


@interface VMaxError : NSError
//3.10.21
@property (nonatomic, readonly) NSString *errorTitle;

@end

