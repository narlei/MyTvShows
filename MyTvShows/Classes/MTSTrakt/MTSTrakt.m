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


@implementation MTSTrakt {
    NSString *__authCode;
}


+ (instancetype)sharedMTSTrakt {
    static MTSTrakt *_sharedMTSTrakt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMTSTrakt = [MTSTrakt new];
        [_sharedMTSTrakt _restoreDefaults];
    });
    return _sharedMTSTrakt;
}

- (BOOL)authenticateForce:(BOOL)pForce {

    if (!pForce && self.authCode.length > 0) {
        return NO;
    }

    NSString *urlOrFilename = [NSString stringWithFormat:@"%@oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code", DEF_trakt_base_url, DEF_trakt_client_id, DEF_callbackUrls];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlOrFilename] options:@{} completionHandler:^(BOOL success) {

    }];
    return YES;
}


- (void)getTokenOnComplete:(void (^)(NSDictionary *dicReturn))onComplete {
    NSDictionary *headers = @{@"Content-Type": @"application/json"};


    NSDictionary *pParameters = @{@"code": self.authCode,
            @"client_id": DEF_trakt_client_id,
            @"client_secret": DEF_trakt_secret_client_id,
            @"redirect_uri": DEF_callbackUrls,
            @"grant_type": @"authorization_code"};

    NSString *strJSON = [self _convertDictionaryToJsonString:pParameters];
    NSLog(@" -----\n    %@    \n-----", strJSON);

    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@/oauth/token", DEF_trakt_base_url]];
        [bodyRequest setHeaders:headers];
        [bodyRequest setBody:jsonData];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            onComplete(@{@"success": @0, @"message": @"Erro ao requisitar o token de acesso"});
            NSLog(@"Token Error");
            return;
        }

        self.refreshToken = [jsonResponse.body.object objectForKey:@"refresh_token"];
        self.createAt = [jsonResponse.body.object objectForKey:@"created_at"];
        self.accessToken = [jsonResponse.body.object objectForKey:@"access_token"];
        self.expiresIn = [jsonResponse.body.object objectForKey:@"expires_in"];

        [self _saveDefaults];
        NSLog(@"Token Success");
        onComplete(@{@"success": @1, @"message": @"Sucesso"});

    }];
}


#pragma mark - Getters and Setters

- (void)setAuthCode:(NSString *)authCode {
    _authCode = authCode;
    [self _saveDefaults];
}

- (NSString *)_convertDictionaryToJsonString:(NSDictionary *)dict {
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

- (void)_saveDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.refreshToken forKey:@"refreshToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.createAt forKey:@"createAt"];
    [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.authCode forKey:@"authCode"];
    [[NSUserDefaults standardUserDefaults] setObject:self.expiresIn forKey:@"expiresIn"];
}

- (void)_restoreDefaults {
    self.refreshToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"refreshToken"];
    self.createAt = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"createAt"]];
    self.accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"];
    self.authCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"authCode"];
    self.expiresIn = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"expiresIn"]];
}


#pragma mark - Sync Data

- (void)downloadWatchedListOnComplete:(void (^)(NSDictionary *dicReturn))onComplete {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@sync/watched/shows", DEF_trakt_base_api_url]];

        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (error) {
            onComplete(@{@"success": @0, @"message": [NSString stringWithFormat:@"Erro ao requisitar a lista de séries assistidas [%@]", error.localizedDescription]});
            NSLog(@"Watched list error");
            return;
        }


        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [show saveData];

            for (NSDictionary *dicSeason in [dicData objectForKey:@"seasons"]) {
                NSNumber *seasonId = [dicSeason objectForKey:@"number"];

                for (NSDictionary *dicEpisodes in [dicSeason objectForKey:@"episodes"]) {
                    MTSEpisodeWatched *episode = [[MTSEpisodeWatched alloc] initWithJSONDictionary:dicEpisodes];
                    episode.showId = show.traktId;
                    episode.seasonId = seasonId;
                    [episode saveData];
                }
            }

        }
        NSLog(@"Watched list Success");
        onComplete(@{@"success": @1, @"message": @"Sucesso"});
    }];

}


- (void)downloadAllShowsOnComplete:(void (^)(NSDictionary *dicReturn))onComplete {

    NSArray *arrayShows = [MTSShow getAllDataWhere:@"1=1"];
    [self _downloadShows:arrayShows index:0 OnComplete:onComplete];

}

- (void)_downloadShows:(NSArray *)pArray index:(int)pIndex OnComplete:(void (^)(NSDictionary *dicReturn))onComplete {

    if (pArray.count == pIndex) {
        onComplete(@{@"success": @1, @"message": @"Sucesso"});
        NSLog(@"All shows Downloaded");
        return;
    }

    [self downloadSeasonsFromShow:[pArray objectAtIndex:pIndex] OnComplete:^(NSDictionary *dicReturn) {
        [self _downloadShows:pArray index:pIndex + 1 OnComplete:onComplete];
    }];

}

- (void)downloadSeasonsFromShow:(MTSShow *)pShow OnComplete:(void (^)(NSDictionary *dicReturn))onComplete {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@shows/%@/seasons?extended=episodes", DEF_trakt_base_api_url, pShow.showIds.slug]];

        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (error) {
            onComplete(@{@"success": @0, @"message": [NSString stringWithFormat:@"Erro ao requisitar os temporadas da série [%@]", error.localizedDescription]});
            return;
        }

        for (NSDictionary *dicData in jsonResponse.body.array) {

            MTSSeason *season = [[MTSSeason alloc] initWithJSONDictionary:dicData];
            season.showId = pShow.traktId;
            [season saveData];
        }

        onComplete(@{@"success": @1, @"message": @"Sucesso"});
    }];
}


- (void)addToHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^)(NSDictionary *dicReturn))onComplete {

    NSString *lastWatched = [NSString stringWithFormat:@"%@", [NSDate date]];
    MTSEpisodeWatched *watched = [[MTSEpisodeWatched alloc] initWithNumber:pEpisode.number lastWatched:lastWatched showId:pEpisode.showId seasonId:pEpisode.seasonId];

    NSDictionary *pParameters = @{@"watched_at": watched.last_watched_at,
            @"ids": @{
                    @"trakt": (pEpisode.episodeIds.trakt == nil ? @0 : pEpisode.episodeIds.trakt),
                    @"tvdb": (pEpisode.episodeIds.tvdb == nil ? @0 : pEpisode.episodeIds.tvdb),
                    @"imdb": (pEpisode.episodeIds.imdb == nil ? @0 : pEpisode.episodeIds.imdb),
                    @"tmdb": (pEpisode.episodeIds.tmdb == nil ? @0 : pEpisode.episodeIds.tmdb),
                    @"tvrage": (pEpisode.episodeIds.tvrage == nil ? @0 : pEpisode.episodeIds.tvrage)
            }
    };

    NSString *strJSON = [self _convertDictionaryToJsonString:@{@"episodes": @[pParameters]}];
    NSLog(@" -----\n    %@    \n-----", strJSON);

    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@sync/history", DEF_trakt_base_api_url]];

        [bodyRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];

        [bodyRequest setBody:jsonData];

    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if ([[[jsonResponse.body.object objectForKey:@"added"] objectForKey:@"episodes"] intValue] > 0) {
            [watched saveData];
            onComplete(@{@"success": @1, @"message": @"Sucesso"});
        } else {
            onComplete(@{@"success": @0, @"message": @"Não pode enviar as informações"});
        }

    }];

}


- (void)removeFromHistoryWatched:(MTSEpisode *)pEpisode OnComplete:(void (^)(NSDictionary *dicReturn))onComplete {


    NSDictionary *pParameters = @{@"watched_at": pEpisode.watched.last_watched_at,
            @"ids": @{
                    @"trakt": (pEpisode.episodeIds.trakt == nil ? @0 : pEpisode.episodeIds.trakt),
                    @"tvdb": (pEpisode.episodeIds.tvdb == nil ? @0 : pEpisode.episodeIds.tvdb),
                    @"imdb": (pEpisode.episodeIds.imdb == nil ? @0 : pEpisode.episodeIds.imdb),
                    @"tmdb": (pEpisode.episodeIds.tmdb == nil ? @0 : pEpisode.episodeIds.tmdb),
                    @"tvrage": (pEpisode.episodeIds.tvrage == nil ? @0 : pEpisode.episodeIds.tvrage)
            }
    };

    NSString *strJSON = [self _convertDictionaryToJsonString:@{@"episodes": @[pParameters]}];
    NSLog(@" -----\n    %@    \n-----", strJSON);

    NSData *jsonData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[UNIRest postEntity:^(UNIBodyRequest *bodyRequest) {
        [bodyRequest setUrl:[NSString stringWithFormat:@"%@sync/history/remove", DEF_trakt_base_api_url]];

        [bodyRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];

        [bodyRequest setBody:jsonData];

    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if ([[[jsonResponse.body.object objectForKey:@"deleted"] objectForKey:@"episodes"] intValue] > 0) {
            [pEpisode.watched deleteData];
            onComplete(@{@"success": @1, @"message": @"Sucesso"});
        } else {
            onComplete(@{@"success": @0, @"message": @"Não pode enviar as informações"});
        }
    }];

}

#pragma mark - Get data

- (void)getTrendingListOnComplete:(void (^)(NSArray *arrayShows))onComplete {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        [simpleRequest setUrl:[NSString stringWithFormat:@"%@shows/trending", DEF_trakt_base_api_url]];

        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        NSMutableArray *arrayShows = [NSMutableArray new];

        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [arrayShows addObject:show];
        }

        onComplete(arrayShows);
    }];

}

- (void)getShowsWithQuery:(NSString *)pQuery OnComplete:(void (^)(NSArray *arrayShows))onComplete {


    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {
        NSString *urlScaped = [pQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        [simpleRequest setUrl:[NSString stringWithFormat:@"%@search/show?query=%@", DEF_trakt_base_api_url, urlScaped]];

        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        NSMutableArray *arrayShows = [NSMutableArray new];

        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [arrayShows addObject:show];
        }

        onComplete(arrayShows);
    }];
}


- (void)nextEpisodeOfShow:(MTSShow *)pShow OnComplete:(void (^)(NSArray *arrayShows))onComplete {


    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[UNIRest get:^(UNISimpleRequest *simpleRequest) {

        [simpleRequest setUrl:[NSString stringWithFormat:@"%@shows/%@/next_episode", DEF_trakt_base_api_url, pShow.showIds.slug]];

        [simpleRequest setHeaders:@{@"Content-Type": @"application/json",
                @"trakt-api-version": @"2",
                @"trakt-api-key": DEF_trakt_client_id,
                @"Authorization": [NSString stringWithFormat:@"Bearer %@", [MTSTrakt sharedMTSTrakt].accessToken]}];
    }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        NSMutableArray *arrayShows = [NSMutableArray new];

        for (NSDictionary *dicData in jsonResponse.body.array) {
            MTSShow *show = [[MTSShow alloc] initWithJSONDictionary:[dicData objectForKey:@"show"]];
            [arrayShows addObject:show];
        }

        onComplete(arrayShows);
    }];
}

#pragma mark - Helper

- (BOOL)showError:(NSDictionary *)pDicError {
    if ([[pDicError objectForKey:@"success"] isEqualToNumber:@0]) {
        UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"Atenção"
                                 message:[pDicError objectForKey:@"message"]
                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction
                actionWithTitle:@"OK"
                          style:UIAlertActionStyleCancel
                        handler:^(UIAlertAction *action) {
                            //Handle no, thanks button
                        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [alert addAction:okButton];
        });

        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return YES;
    } else {
        return NO;
    }
}

@end
