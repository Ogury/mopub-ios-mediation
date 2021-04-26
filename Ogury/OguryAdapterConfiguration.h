//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

extern NSString * const kOguryConfigurationAdUnitId;
extern NSString * const kOguryErrorDomain;

@interface OguryAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString *adapterVersion;
@property (nonatomic, copy, readonly) NSString *biddingToken;
@property (nonatomic, copy, readonly) NSString *moPubNetworkName;
@property (nonatomic, copy, readonly) NSString *networkSdkVersion;

#pragma mark - Methods

+ (void)applyTransparencyAndConsentStatusWithParameters:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
