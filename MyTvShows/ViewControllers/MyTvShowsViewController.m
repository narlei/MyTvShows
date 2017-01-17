//
//  MyTvShowsViewController.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 14/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "MyTvShowsViewController.h"
#import "ShowCell.h"
#import "LCLoadingHUD.h"
#import "SeasonsListViewController.h"

@interface MyTvShowsViewController ()
@property(strong, nonatomic) NSMutableArray *arrayValues;
@property(strong, nonatomic) NSMutableArray *arrayAllValues;

// Propriedade de Refresh
@property(weak, nonatomic) IBOutlet UIRefreshControl *refreshControl;
@end

@implementation MyTvShowsViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.notification displayNotificationWithMessage:@"Buscando novos dados..." forDuration:2];

    // First Access
    if ([MTSTrakt sharedMTSTrakt].authCode.length == 0) {
        UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"Atenção"
                                 message:@"Você será direcionado ao site Trakt.tv para efetuar o login."
                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction
                actionWithTitle:@"OK"
                          style:UIAlertActionStyleCancel
                        handler:^(UIAlertAction *action) {
                            [self initialize];
                        }];

        [alert addAction:okButton];

        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        [self initialize];
    }


}

- (void)initialize {
    if (![[MTSTrakt sharedMTSTrakt] authenticateForce:NO]) {
        [self loadData];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:DEF_OBSERVER_TOKEN_RECEIVED object:nil];
    }

    // Refresh TableView
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableViewShows addSubview:refreshControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tokenReceived:(NSDictionary *)pDicData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.notification displayNotificationWithMessage:@"Buscando novos dados..." forDuration:2];
        [self loadData];
    });
}

#pragma mark - Data

- (void)loadData {

    [self refreshData];

    int countOldWatched = (int) [MTSEpisodeWatched getAllDataWhere:@"1=1"].count;

    [[MTSTrakt sharedMTSTrakt] downloadWatchedListOnComplete:^(NSDictionary *dicReturn) {

        int countNewWatched = (int) [MTSEpisodeWatched getAllDataWhere:@"1=1"].count;

        if (countNewWatched > countOldWatched) {
            if (![[MTSTrakt sharedMTSTrakt] showError:dicReturn]) {
                [[MTSTrakt sharedMTSTrakt] downloadAllShowsOnComplete:^(NSDictionary *dicReturn) {

                    [[MTSTrakt sharedMTSTrakt] showError:dicReturn];

                    [self refreshData];
                }];
            }
        } else {
            [self refreshData];
        }
    }];
}

- (void)refreshData {
    self.arrayAllValues = [[NSMutableArray alloc] initWithArray:[MTSShow getAllDataWhere:@"traktId IN (SELECT DISTINCT showId FROM MTSEpisodeWatched)"]];
    self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        //                    [LCLoadingHUD hideInView:self.view];

        [self.tableViewShows reloadData];
        // Parar Refresh
        [self.refreshControl endRefreshing];
    });
}

#pragma TableView Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    MTSShow *show = [self.arrayValues objectAtIndex:indexPath.row];

    SeasonsListViewController *viewController = [[UIStoryboard storyboardWithName:@"SeasonsList" bundle:nil] instantiateInitialViewController];
    viewController.show = show;
    [self.navigationController pushViewController:viewController animated:YES];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellShowCell"];
    ShowCell *currentCell = (ShowCell *) cell;
    currentCell.show = [self.arrayValues objectAtIndex:indexPath.row];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayValues.count;
}


@end
