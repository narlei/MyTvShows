//
//  MTSTrakt.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 12/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSShow.h"
#import "MTSSeason.h"
#import "MTSEpisodeWatched.h"
#import "MTSEpisode.h"

@interface MTSTrakt : NSObject

+ (instancetype)sharedMTSTrakt;

@property (strong, nonatomic) NSString *authCode;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSNumber *createAt;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSNumber *expiresIn;


#pragma mark - Auth

- (BOOL)authenticateForce:(BOOL)pForce;

- (void)getTokenOnComplete:(void (^) (NSDictionary* dicReturn))onComplete;


#pragma mark - Sync Data

- (void)downloadWatchedListOnComplete:(void (^) (NSDictionary* dicReturn))onComplete;

- (void)downloadAllShowsOnComplete:(void (^) (NSDictionary* dicReturn))onComplete;
- (void)downloadSeasonsFromShow:(MTSShow *)pShow OnComplete:(void (^) (NSDictionary* dicReturn))onComplete;


- (void)addToHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^) (NSDictionary* dicReturn))onComplete;
- (void)removeFromHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^) (NSDictionary* dicReturn))onComplete;

#pragma mark - Get Data
- (void)getTrendingListOnComplete:(void (^) (NSArray* arrayShows))onComplete;
- (void)getShowsWithQuery:(NSString *)pQuery OnComplete:(void (^) (NSArray* arrayShows))onComplete;

@end
