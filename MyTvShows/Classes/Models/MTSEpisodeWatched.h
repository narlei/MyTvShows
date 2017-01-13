//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSObjectModel.h"

@interface MTSEpisodeWatched : MTSObjectModel


@property (strong, nonatomic) NSNumber *showId;
@property (strong, nonatomic) NSNumber *seasonId;
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSNumber *plays;
@property (strong, nonatomic) NSString *last_watched_at;

- (id) initWithJSONDictionary:(NSDictionary *)dic;
- (void) parseJSONDictionary:(NSDictionary *)dic;

#pragma mark - Initializer

- (id)initWithNumber:(NSNumber *)pNumber lastWatched:(NSString *)pLastWatched showId:(NSNumber *)pShowId seasonId:(NSNumber *)pSeasonId;

@end
