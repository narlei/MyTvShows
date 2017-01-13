//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSObjectModel.h"

@interface MTSShowIds : MTSObjectModel

@property (strong, nonatomic) NSNumber *trakt;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) NSNumber *tvdb;
@property (strong, nonatomic) NSString *imdb;
@property (strong, nonatomic) NSNumber *tmdb;
@property (strong, nonatomic) NSNumber *tvrage;

- (id) initWithJSONDictionary:(NSDictionary *)dic;
- (void) parseJSONDictionary:(NSDictionary *)dic;

@end
