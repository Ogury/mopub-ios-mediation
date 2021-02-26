//
//  GADQueryInfo.h
//  Google Mobile Ads SDK
//
//  Copyright 2019 Google LLC. All rights reserved.
//

#import <GoogleMobileAds/GADAdFormat.h>
#import <GoogleMobileAds/GADRequest.h>

@class GADQueryInfo;

/// Completion handler for query creation. Returns query info or an error.
typedef void (^GADQueryInfoCreationCompletionHandler)(GADQueryInfo *_Nullable queryInfo,
                                                      NSError *_Nullable error);

/// Query info used in requests.
@interface GADQueryInfo : NSObject

/// Query string used in requests.
@property(nonatomic, readonly, nonnull) NSString *query;

/// Uniquely identifies a request. The ad string response contains a matching identifier. See
/// GADAdInfo_Preview.h for more information.
@property(nonatomic, readonly, nonnull) NSString *requestIdentifier;

/// Creates query info that can be used as input in a Google request. Calls completionHandler
/// asynchronously on the main thread once query info has been created or when an error occurs.
+ (void)createQueryInfoWithRequest:(nullable GADRequest *)request
                          adFormat:(GADAdFormat)adFormat
                 completionHandler:(nonnull GADQueryInfoCreationCompletionHandler)completionHandler;

@end
