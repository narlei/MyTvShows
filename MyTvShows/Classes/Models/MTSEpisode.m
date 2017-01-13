//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

// Import
#import "MTSEpisode.h"
#import "MTSEpisodeIds.h"


@implementation MTSEpisode{
    MTSEpisodeWatched *__watched;
}

#pragma mark - API

- (id)initWithJSONDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self parseJSONDictionary:dic];
    }

    return self;
}

- (void)parseJSONDictionary:(NSDictionary *)dic {
    // PARSER
    id season_ = [dic objectForKey:@"season"];
    if ([season_ isKindOfClass:[NSNumber class]]) {
        self.seasonId = season_;
    }

    id number_ = [dic objectForKey:@"number"];
    if ([number_ isKindOfClass:[NSNumber class]]) {
        self.number = number_;
    }

    id title_ = [dic objectForKey:@"title"];
    if ([title_ isKindOfClass:[NSString class]]) {
        self.title = title_;
    }

    id ids_ = [dic objectForKey:@"ids"];
    if ([ids_ isKindOfClass:[NSDictionary class]]) {
        self.episodeIds = [[MTSEpisodeIds alloc] initWithJSONDictionary:ids_];
        self.traktId = self.episodeIds.trakt;
    }
}

#pragma mark - Database

- (void)saveData {
    [super saveData];
    [self.episodeIds saveData];
}

+(NSArray *)primaryKeys{
    return @[@"traktId"];
}

+ (NSArray *)ignoredProperties{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super ignoredProperties]];
    [array addObject:@"episodeIds"];
    return array;
}

#pragma mark - Gettes and Setters

- (void)setWatched:(MTSEpisodeWatched *)watched{
    __watched = watched;
}

- (MTSEpisodeWatched *)watched{
    if (!__watched) {
        __watched = [[MTSEpisodeWatched getAllDataWhere:[NSString stringWithFormat:@"showId = %@ AND seasonId = %@ and number = %@",self.showId,self.seasonId,self.number]] firstObject];
    }
    return __watched;
}


@end
