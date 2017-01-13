//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

// Import
#import "MTSEpisodeWatched.h"


@implementation MTSEpisodeWatched

#pragma mark - Initializer

- (id)initWithNumber:(NSNumber *)pNumber lastWatched:(NSString *)pLastWatched showId:(NSNumber *)pShowId seasonId:(NSNumber *)pSeasonId{
    if (self = [super init]) {
        self.number = pNumber;
        self.last_watched_at = pLastWatched;
        self.showId = pShowId;
        self.seasonId = pSeasonId;
    }
    return self;
}


#pragma mark - API

- (id) initWithJSONDictionary:(NSDictionary *)dic
{
	if(self = [super init])
	{
		[self parseJSONDictionary:dic];
	}
	
	return self;
}

- (void) parseJSONDictionary:(NSDictionary *)dic
{
	// PARSER
	id number_ = [dic objectForKey:@"number"];
	if([number_ isKindOfClass:[NSNumber class]])
	{
		self.number = number_;
	}

	id plays_ = [dic objectForKey:@"plays"];
	if([plays_ isKindOfClass:[NSNumber class]])
	{
		self.plays = plays_;
	}

	id last_watched_at_ = [dic objectForKey:@"last_watched_at"];
	if([last_watched_at_ isKindOfClass:[NSString class]])
	{
		self.last_watched_at = last_watched_at_;
	}
}

#pragma mark - Database

+ (NSArray *)primaryKeys{
    return @[@"number",@"seasonId",@"showId"];
}


@end
