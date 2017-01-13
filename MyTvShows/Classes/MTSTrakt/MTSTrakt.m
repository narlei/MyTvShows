//
//  MTSTrakt.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 12/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "MTSTrakt.h"
#import <UIKit/UIKit.h>
#import "UNIRest.h"


@implementation MTSTrakt{
    NSString *__authCode;
}


+ (instancetype)sharedMTSTrakt {
    static MTSTrakt *_sharedMTSTrakt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMTSTrakt = [MTSTrakt new];
        [_sharedMTSTrakt restoreDefaults];
    });
    return _sharedMTSTrakt;
}

- (BOOL)authenticateForce:(BOOL)pForce{
    
    if (!pForce && self.authCode.length > 0) {
        return NO;
    }
    
    NSString *urlOrFilename = [NSString stringWithFormat:@"%@oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code",DEF_trakt_base_url, DEF_trakt_client_id, DEF_callbackUrls];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlOrFilename] options:@{} completionHandler:^(BOOL success) {
        
    }];
    return YES;
}


- (void) getTokenOnComplete:(void (^) (NSDictionary* dicReturn))onComplete{
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    
    
    NSDictionary *pParameters = @{@"code":self.authCode,
                                  @"client_id":DEF_trakt_client_id,
                                  @"client_secret":DEF_trakt_secret_client_id,
                                  @"redirect_uri":DEF_callbackUrls,
                                  @"grant_type":@"authorization_code"};
    
    NSString *strJSON = [self convertDictionaryToJsonString:pParameters];
    NSLog(@" -----\n    %@    \n-----", strJSON);
    
    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@/oauth/token",DEF_trakt_base_url]];
        [bodyRequest setHeaders:headers];
        [bodyRequest setBody:jsonData];
    }]asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        
        self.refreshToken = [jsonResponse.body.object objectForKey:@"refresh_token"];
        self.createAt = [jsonResponse.body.object objectForKey:@"created_at"];
        self.accessToken  = [jsonResponse.body.object objectForKey:@"access_token"];
        self.expiresIn = [jsonResponse.body.object objectForKey:@"expires_in"];
        
        [self saveDefaults];
        
        onComplete(@{@"success":@1, @"message":@"Sucesso"});
        
    }];
}


#pragma mark - Getters and Setters

- (void)setAuthCode:(NSString *)authCode{
    _authCode = authCode;
    [self saveDefaults];
}

- (NSString *)convertDictionaryToJsonString:(NSDictionary *)dict {
    if (dict) {
        NSError *error;
        NSDictionary *tempDict = [dict copy]; // get Dictionary from mutable Dictionary
        // giving error as it takes dic, array,etc only. not custom object.
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDict options:NSJSONReadingMutableLeaves error:&error];
        NSString *nsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return nsJson;
    } else {
        return @"NIL";
    }
}

#pragma mark - Persietence

- (void)saveDefaults{
    [[NSUserDefaults standardUserDefaults] setObject:self.refreshToken forKey:@"refreshToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.createAt forKey:@"createAt"];
    [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.authCode forKey:@"authCode"];
    [[NSUserDefaults standardUserDefaults] setObject:self.expiresIn forKey:@"expiresIn"];
}

- (void)restoreDefaults{
    self.refreshToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"refreshToken"];
    self.createAt     = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"createAt"]];
    self.accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"];
    self.authCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"authCode"];
    self.expiresIn     = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"expiresIn"]];
}


#pragma mark - Sync Data

- (void)downloadWatchedListOnComplete:(void (^) (NSDictionary* dicReturn))onComplete{
    
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@sync/watched/shows",DEF_trakt_base_api_url]];
        
        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                                    @"trakt-api-version":@"2",
                                    @"trakt-api-key":DEF_trakt_client_id,
                                    @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [show saveData];
            
            for (NSDictionary *dicSeason in [dicData objectForKey:@"seasons"]) {
                
                NSNumber *seasonId =[dicSeason objectForKey:@"number"];
                
                for (NSDictionary *dicEpisodes in [dicSeason objectForKey:@"episodes"]) {
                    MTSEpisodeWatched *episode = [[MTSEpisodeWatched alloc] initWithJSONDictionary:dicEpisodes];
                    episode.showId = show.traktId;
                    episode.seasonId = seasonId;
                    [episode saveData];
                }
            }
            
        }
        
        onComplete(@{@"success":@1, @"message":@"Sucesso"});
    }];
    
}


- (void)downloadSeasonsFromShow:(MTSShow *)pShow OnComplete:(void (^) (NSDictionary* dicReturn))onComplete{
    
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@shows/%@/seasons?extended=episodes",DEF_trakt_base_api_url,pShow.showIds.slug]];
        
        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                                    @"trakt-api-version":@"2",
                                    @"trakt-api-key":DEF_trakt_client_id,
                                    @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        
        if (error) {
            onComplete(@{@"success":@0, @"message":error.localizedDescription});
            return;
        }
        
        for (NSDictionary *dicData in jsonResponse.body.array) {
            
            MTSSeason*season = [[MTSSeason alloc] initWithJSONDictionary:dicData];
            [season saveData];
//            for (NSDictionary *dicEpisodes in [dicData objectForKey:@"episodes"]) {
//                MTSEpisode *episode = [[MTSEpisode alloc] initWithJSONDictionary:dicEpisodes];
//                episode.showId = pShow.traktId;
//                [episode saveData];
//            }
        }
        
        onComplete(@{@"success":@1, @"message":@"Sucesso"});
    }];
}


- (void)addToHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^) (NSDictionary* dicReturn))onComplete{
    
    NSString*lastWatched = [NSString stringWithFormat:@"%@",[NSDate date]];
//    2014-09-01T09:10:11.000Z
    MTSEpisodeWatched *watched = [[MTSEpisodeWatched alloc] initWithNumber:pEpisode.number lastWatched:lastWatched showId:pEpisode.showId seasonId:pEpisode.seasonId];
    
    NSDictionary *pParameters = @{@"watched_at":watched.last_watched_at,
                                  @"ids":@{
                                          @"trakt":pEpisode.episodeIds.trakt,
                                          @"tvdb":pEpisode.episodeIds.tvdb,
                                          @"imdb":pEpisode.episodeIds.imdb,
                                          @"tmdb":pEpisode.episodeIds.tmdb,
                                          @"tvrage":pEpisode.episodeIds.tvrage
                                          }
                                      };
    
    NSString *strJSON = [self convertDictionaryToJsonString:@{@"episodes":@[pParameters]}];
    NSLog(@" -----\n    %@    \n-----", strJSON);
    
    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@sync/history",DEF_trakt_base_api_url]];
        
        [bodyRequest setHeaders:@{@"Content-Type": @"application/json",
                                    @"trakt-api-version":@"2",
                                    @"trakt-api-key":DEF_trakt_client_id,
                                    @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
        
        [bodyRequest setBody:jsonData];
        
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        if ([[[jsonResponse.body.object objectForKey:@"added"] objectForKey:@"episodes"] intValue] > 0) {
            [watched saveData];
        }
        
        onComplete(@{@"success":@1, @"message":@"Sucesso"});
    }];
    
}

- (void)removeFromHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^) (NSDictionary* dicReturn))onComplete{
    
    
    NSDictionary *pParameters = @{@"watched_at":pEpisode.watched.last_watched_at,
                                  @"ids":@{
                                          @"trakt":pEpisode.episodeIds.trakt,
                                          @"tvdb":pEpisode.episodeIds.tvdb,
                                          @"imdb":pEpisode.episodeIds.imdb,
                                          @"tmdb":pEpisode.episodeIds.tmdb,
                                          @"tvrage":pEpisode.episodeIds.tvrage
                                          }
                                  };
    
    NSString *strJSON = [self convertDictionaryToJsonString:@{@"episodes":@[pParameters]}];
    NSLog(@" -----\n    %@    \n-----", strJSON);
    
    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@sync/history",DEF_trakt_base_api_url]];
        
        [bodyRequest setHeaders:@{@"Content-Type": @"application/json",
                                  @"trakt-api-version":@"2",
                                  @"trakt-api-key":DEF_trakt_client_id,
                                  @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
        
        [bodyRequest setBody:jsonData];
        
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        if ([[[jsonResponse.body.object objectForKey:@"added"] objectForKey:@"episodes"] intValue] > 0) {
//            [watched saveData];
            // TODO
        }
        
        onComplete(@{@"success":@1, @"message":@"Sucesso"});
    }];
    
}

#pragma mark - Get data

- (void)getTrendingListOnComplete:(void (^) (NSArray* arrayShows))onComplete{
    
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@shows/trending",DEF_trakt_base_api_url]];
        
        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                                    @"trakt-api-version":@"2",
                                    @"trakt-api-key":DEF_trakt_client_id,
                                    @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        NSMutableArray*arrayShows = [NSMutableArray new];
        
        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [arrayShows addObject:show];
        }
        
        onComplete(arrayShows);
    }];
    
}

- (void)getShowsWithQuery:(NSString *)pQuery OnComplete:(void (^) (NSArray* arrayShows))onComplete{
    
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@search/movie?query=%@",DEF_trakt_base_api_url,pQuery]];
        
        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                                    @"trakt-api-version":@"2",
                                    @"trakt-api-key":DEF_trakt_client_id,
                                    @"Authorization":[NSString stringWithFormat:@"Bearer %@",[MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        NSMutableArray*arrayShows = [NSMutableArray new];
        
        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [arrayShows addObject:show];
        }
        
        onComplete(arrayShows);
    }];
}

@end
