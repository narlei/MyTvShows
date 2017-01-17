//
//  Created by Cocoa JSON Editor
//  http://www.cocoajsoneditor.com
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MTSObjectModel.h"
#import "MTSShowIds.h"

@interface MTSShow : MTSObjectModel

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSDecimalNumber *year;
@property(strong, nonatomic) MTSShowIds *showIds;
@property(strong, nonatomic) NSNumber *traktId;

@property(strong, nonatomic, readonly) NSArray *arraySeasons;

- (void)reloadArraySeasons;


- (id)initWithJSONDictionary:(NSDictionary *)dic;

- (void)parseJSONDictionary:(NSDictionary *)dic;

@end
