//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedVideoCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

@interface OguryRewardedVideoCustomEvent () <OguryAdsOptinVideoDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsOptinVideo *optInVideo;

@end

@implementation OguryRewardedVideoCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)dealloc {
    self.optInVideo.optInVideoDelegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];
    if (!self.adUnitId || [self.adUnitId isEqualToString:@""]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while loading the ad. Invalid ad unit identifier."];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], @"");

        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }

    [OguryAdapterConfiguration applyTransparencyAndConsentStatusWithParameters:info];

    self.optInVideo = [[OguryAdsOptinVideo alloc] initWithAdUnitID:self.adUnitId];
    self.optInVideo.optInVideoDelegate = self;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);

    [self.optInVideo load];
}

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.optInVideo && self.optInVideo.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])], self.adUnitId);

    if (![self hasAdAvailable]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while showing the ad. Ad was not ready."];
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        return;
    }

    [self.optInVideo showAdInViewController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - OguryAdsOptinVideoDelegate

- (void)oguryAdsOptinVideoAdAvailable {

}

- (void)oguryAdsOptinVideoAdClosed {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdWillDisappear:self];

    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsOptinVideoAdDisplayed {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];

    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])], self.adUnitId);
}

- (void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdLoaded {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsOptinVideoAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item {
    NSString *currencyType = kMPRewardCurrencyTypeUnspecified;
    NSInteger amount = kMPRewardCurrencyAmountUnspecified;

    if (item) {
        if (item.rewardName && ![item.rewardName isEqualToString:@""]) {
            currencyType = item.rewardName;
        }

        if (item.rewardValue && ![item.rewardValue isEqualToString:@""]) {
            amount = item.rewardValue.integerValue;
        }
    }

    MPReward *reward = [[MPReward alloc] initWithCurrencyType:currencyType amount:@(amount)];

    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

- (void)oguryAdsOptinVideoAdClicked {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@end
