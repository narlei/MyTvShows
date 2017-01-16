//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

// Import
#import "MTSSeason.h"
#import "MTSSeasonIds.h"
#import "MTSEpisode.h"


@implementation MTSSeason{
    NSArray *__arrayEpisodes;
}


- (id)initWithJSONDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self parseJSONDictionary:dic];
    }

    return self;
}

- (void)parseJSONDictionary:(NSDictionary *)dic {
    // PARSER
    id number_ = [dic objectForKey:@"number"];
    if ([number_ isKindOfClass:[NSNumber class]]) {
        self.number = number_;
    }

    id ids_ = [dic objectForKey:@"ids"];
    if ([ids_ isKindOfClass:[NSDictionary class]]) {
        self.seasonIds = [[MTSSeasonIds alloc] initWithJSONDictionary:ids_];
        self.traktId = self.seasonIds.trakt;
    }

    id episodes_ = [dic objectForKey:@"episodes"];
    if ([episodes_ isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *itemDic in episodes_) {
            MTSEpisode *item = [[MTSEpisode alloc] initWithJSONDictionary:itemDic];
            [array addObject:item];
        }
        self.arrayEpisodes = [NSArray arrayWithArray:array];
    }
}

#pragma mark - Database

- (void)saveData {
    [super saveData];
    [self.seasonIds saveData];
    for (MTSEpisode *episode in self.arrayEpisodes) {
        episode.showId = self.showId;
        [episode saveData];
    }
}

#pragma mark - Database

+(NSArray *)primaryKeys{
    return @[@"traktId"];
}

+ (NSArray *)ignoredProperties{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super ignoredProperties]];
    [array addObject:@"seasonIds"];
    return array;
}

#pragma mark - Getters and Setters


-(void)setArrayEpisodes:(NSArray *)arrayEpisodes{
    __arrayEpisodes = arrayEpisodes;
}

-(NSArray *)arrayEpisodes{
    if (!__arrayEpisodes) {
        __arrayEpisodes = [MTSEpisode getAllDataWhere:[NSString stringWithFormat:@"showId = %@ AND seasonId = %@",self.showId,self.number]];
    }
    return __arrayEpisodes;
}



@end
