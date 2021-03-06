//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

// Import
#import "MTSEpisodeIds.h"


@implementation MTSEpisodeIds




- (void) dealloc
{
	

}

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
	id trakt_ = [dic objectForKey:@"trakt"];
	if([trakt_ isKindOfClass:[NSNumber class]])
	{
		self.trakt = trakt_;
	}

	id tvdb_ = [dic objectForKey:@"tvdb"];
	if([tvdb_ isKindOfClass:[NSNumber class]])
	{
		self.tvdb = tvdb_;
	}

	id imdb_ = [dic objectForKey:@"imdb"];
	if([imdb_ isKindOfClass:[NSNull class]])
	{
		self.imdb = imdb_;
	}

	id tmdb_ = [dic objectForKey:@"tmdb"];
	if([tmdb_ isKindOfClass:[NSNumber class]])
	{
		self.tmdb = tmdb_;
	}

	id tvrage_ = [dic objectForKey:@"tvrage"];
	if([tvrage_ isKindOfClass:[NSNumber class]])
	{
		self.tvrage = tvrage_;
	}
}

#pragma mark - Database

+ (NSArray *)primaryKeys{
    return @[@"trakt"];
}

@end
