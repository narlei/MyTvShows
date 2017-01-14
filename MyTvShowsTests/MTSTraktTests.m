//
//  MTSTraktTests.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 13/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MTSTrakt.h"

@interface MTSTraktTests : XCTestCase

@end

@implementation MTSTraktTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDownloadSeasonsFromShow {
    MTSShow *show = [[MTSShow getAllDataWhere:@"1=1"] firstObject];
    XCTAssertNotNil(show.traktId, @"Show can't be nil");

    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    [[MTSTrakt sharedMTSTrakt] downloadSeasonsFromShow:show OnComplete:^(NSDictionary *dicReturn) {
        if (![[dicReturn objectForKey:@"success"] boolValue]) {
            XCTFail(@"Expectation Failed with error: %@", [dicReturn objectForKey:@"message"]);
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {

        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testAddToHistoryWatched {
    MTSEpisode *episode = [[MTSEpisode getAllDataWhere:@"1=1"] firstObject];

    XCTAssertNotNil(episode, @"Show can't be nil");
    NSLog(@"Episode: %@ | ShowId: %@",episode.title,episode.showId);

    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    [[MTSTrakt sharedMTSTrakt] addToHistoryWatched:episode OnComplete:^(NSDictionary *dicReturn) {
        if (![[dicReturn objectForKey:@"success"] boolValue]) {
            XCTFail(@"Expectation Failed with error: %@", [dicReturn objectForKey:@"message"]);
        }else{
            NSLog(@"%@",[dicReturn objectForKey:@"message"]);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {

        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testRemoveFromHistoryWatched {
    MTSEpisodeWatched *episodeWatched = [[MTSEpisodeWatched getAllDataWhere:@"1=1"] firstObject];
    MTSEpisode *episode = [[MTSEpisode getAllDataWhere:[NSString stringWithFormat:@"number = %@ and seasonId = %@ and showId = %@",episodeWatched.number,episodeWatched.seasonId,episodeWatched.showId]] firstObject];
    
    XCTAssertNotNil(episode, @"Episode can't be nil");
    NSLog(@"Episode: %@ | ShowId: %@",episode.title,episode.showId);
    
    //Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    [[MTSTrakt sharedMTSTrakt] removeFromHistoryWatched:episode OnComplete:^(NSDictionary *dicReturn) {
        if (![[dicReturn objectForKey:@"success"] boolValue]) {
            XCTFail(@"Expectation Failed with error: %@", [dicReturn objectForKey:@"message"]);
        }else{
            NSLog(@"%@",[dicReturn objectForKey:@"message"]);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}


@end
