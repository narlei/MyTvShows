//
//  AppDelegate.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 12/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "AppDelegate.h"
#import "NAMDatabase.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        [[NAMDatabase sharedNAMDatabase] createAllTables];
    }


    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {

    // react to shortcut item selections
    NSLog(@"A shortcut item was pressed. It was %@.", shortcutItem.localizedTitle);

    // have we launched Deep Link Level 1
    if ([shortcutItem.type isEqualToString:@"DISCOVER"]) {
        [self openTabBar:1];
    }

    // have we launched Deep Link Level 2
    if ([shortcutItem.type isEqualToString:@"WATCH"]) {
        [self openTabBar:0];
    }

}

- (void)openTabBar:(int)index {
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *) self.window.rootViewController;
        tabBar.selectedIndex = index;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    NSString *urlString = [url absoluteString];
    NSString *authCode = [[urlString componentsSeparatedByString:@"="] lastObject];

    [MTSTrakt sharedMTSTrakt].authCode = authCode;

    [[MTSTrakt sharedMTSTrakt] getTokenOnComplete:^(NSDictionary *dicReturn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DEF_OBSERVER_TOKEN_RECEIVED object:dicReturn];

    }];

    return YES;

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
