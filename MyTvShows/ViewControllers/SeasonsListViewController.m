//
//  SeasonsListViewController.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "SeasonsListViewController.h"
#import "SeasonsListCell.h"
#import "EpisodesListViewController.h"
#import "LCLoadingHUD.h"

@interface SeasonsListViewController ()

@property(strong, nonatomic) NSMutableArray *arrayValues;
@property(strong, nonatomic) NSMutableArray *arrayAllValues;

@end

@implementation SeasonsListViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LCLoadingHUD showLoading:@"Carregando" inView:self.view];
    
    if (self.show.arraySeasons.count == 0) {
        [[MTSTrakt sharedMTSTrakt] downloadSeasonsFromShow:self.show OnComplete:^(NSDictionary *dicReturn) {
            [self.show reloadArraySeasons];
            [self loadData];
        }];
    }else{
        
        [self loadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tokenReceived:(NSDictionary *)pDicData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

#pragma mark - Data

- (void)loadData {
    
    self.arrayAllValues = [[NSMutableArray alloc] initWithArray:self.show.arraySeasons];
    self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        [LCLoadingHUD hideInView:self.view];
        [self.tableViewSeasons reloadData];
    });
    
}

#pragma TableView Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MTSSeason *season = [self.arrayValues objectAtIndex:indexPath.row];
    
    EpisodesListViewController *viewController = [[UIStoryboard storyboardWithName:@"EpisodesList" bundle:nil] instantiateInitialViewController];
    viewController.season = season;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellSeasonsList"];
    SeasonsListCell *currentCell = (SeasonsListCell *) cell;
    currentCell.season = [self.arrayValues objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayValues.count;
}

@end
