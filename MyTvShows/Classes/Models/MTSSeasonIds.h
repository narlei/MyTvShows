//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSObjectModel.h"


@interface MTSSeasonIds : MTSObjectModel


@property(strong, nonatomic) NSNumber *trakt;
@property(strong, nonatomic) NSNumber *tvdb;
@property(strong, nonatomic) NSNumber *tmdb;
@property(strong, nonatomic) NSNumber *tvrage;

- (id)initWithJSONDictionary:(NSDictionary *)dic;

- (void)parseJSONDictionary:(NSDictionary *)dic;

@end
