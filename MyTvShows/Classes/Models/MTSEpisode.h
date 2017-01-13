//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSObjectModel.h"
#import "MTSEpisodeIds.h"
#import "MTSEpisodeWatched.h"

@interface MTSEpisode : MTSObjectModel

@property (strong, nonatomic) NSNumber *showId;
@property (strong, nonatomic) NSNumber *seasonId;
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) MTSEpisodeIds *episodeIds;
@property (strong, nonatomic) NSNumber *traktId;

@property (strong, nonatomic) MTSEpisodeWatched *watched;

- (id) initWithJSONDictionary:(NSDictionary *)dic;
- (void) parseJSONDictionary:(NSDictionary *)dic;

@end
