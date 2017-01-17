//
//  DiscoverShowsListViewController.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "DiscoverShowsListViewController.h"
#import "LCLoadingHUD.h"
#import "ShowCell.h"
#import "LCLoadingHUD.h"
#import "SeasonsListViewController.h"

@interface DiscoverShowsListViewController () <UISearchBarDelegate, UIScrollViewDelegate>
@property(strong, nonatomic) NSMutableArray *arrayValues;
@property(strong, nonatomic) NSMutableArray *arrayAllValues;
@end

@implementation DiscoverShowsListViewController


#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.showsCancelButton = YES;

    [LCLoadingHUD showLoading:@"Carregando" inView:self.view];

    if (![[MTSTrakt sharedMTSTrakt] authenticateForce:NO]) {
        [self loadData];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:DEF_OBSERVER_TOKEN_RECEIVED object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tokenReceived:(NSDictionary *)pDicData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

#pragma mark - Data

- (void)loadData {
    [[MTSTrakt sharedMTSTrakt] getTrendingListOnComplete:^(NSArray *arrayShows) {

        self.arrayAllValues = [[NSMutableArray alloc] initWithArray:arrayShows];
        self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            [LCLoadingHUD hideInView:self.view];
            [self.tableViewShows reloadData];
        });

    }];
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

#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.activityIndicator startAnimating];
    [[MTSTrakt sharedMTSTrakt] getShowsWithQuery:searchBar.text OnComplete:^(NSArray *arrayShows) {

        self.arrayAllValues = [[NSMutableArray alloc] initWithArray:arrayShows];
        self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            [self.tableViewShows reloadData];
            [self.activityIndicator stopAnimating];
        });

    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        [self.activityIndicator stopAnimating];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self.activityIndicator stopAnimating];
}

@end
