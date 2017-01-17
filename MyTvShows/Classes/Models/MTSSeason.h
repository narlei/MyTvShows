//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MTSObjectModel.h"

@class MTSSeasonIds;

@interface MTSSeason : MTSObjectModel


@property(strong, nonatomic) NSNumber *number;
@property(strong, nonatomic) MTSSeasonIds *seasonIds;
@property(strong, nonatomic) NSArray *arrayEpisodes;
@property(strong, nonatomic) NSNumber *traktId;

@property(strong, nonatomic) NSNumber *showId;


- (id)initWithJSONDictionary:(NSDictionary *)dic;

- (void)parseJSONDictionary:(NSDictionary *)dic;

@end
