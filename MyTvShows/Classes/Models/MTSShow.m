//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

// Import
#import "MTSShow.h"
#import "MTSShowIds.h"


@implementation MTSShow{
    MTSShowIds *__showIds;
    NSMutableArray *__arraySeasons;
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
	id title_ = [dic objectForKey:@"title"];
	if([title_ isKindOfClass:[NSString class]])
	{
		self.title = title_;
	}

	id year_ = [dic objectForKey:@"year"];
	if([year_ isKindOfClass:[NSNumber class]])
	{
		self.year = year_;
	}

	id ids_ = [dic objectForKey:@"ids"];
	if([ids_ isKindOfClass:[NSDictionary class]])
	{
		self.showIds = [[MTSShowIds alloc] initWithJSONDictionary:ids_];
        self.traktId = self.showIds.trakt;
	}
}


#pragma mark - Database

+ (NSArray *)primaryKeys{
    return @[@"traktId"];
}

- (void)saveData {
	[super saveData];
	[self.showIds saveData];
}

+ (NSArray *)ignoredProperties{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super ignoredProperties]];
    [array addObject:@"showIds"];
    return array;
}

#pragma mark - Getters and Setters

- (void)setShowIds:(MTSShowIds *)showIds{
    __showIds = showIds;
}

- (MTSShowIds *)showIds{
    if (!__showIds) {
        __showIds = [[MTSShowIds getAllDataWhere:[NSString stringWithFormat:@"trakt = %@",self.traktId]] firstObject];
    }
    return __showIds;
}

- (NSMutableArray *)arraySeasons{
    if (!__arraySeasons) {
        __arraySeasons = [MTSSeason getAllDataWhere:[NSString stringWithFormat:@"showId = %@",self.traktId]];
    }
    return __arraySeasons;
}

- (void) reloadArraySeasons{
    __arraySeasons = [MTSSeason getAllDataWhere:[NSString stringWithFormat:@"showId = %@",self.traktId]];
}

@end
