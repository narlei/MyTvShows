//
//  EpisodesListViewController.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "EpisodesListViewController.h"
#import "EpisodesListCell.h"
@interface EpisodesListViewController ()

@property(strong, nonatomic) NSMutableArray *arrayValues;
@property(strong, nonatomic) NSMutableArray *arrayAllValues;

@end

@implementation EpisodesListViewController


#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [LCLoadingHUD showLoading:@"Carregando" inView:self.view];
    [self loadData];
    
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
    
    self.arrayAllValues = [[NSMutableArray alloc] initWithArray:self.season.arrayEpisodes];
    self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        //                    [LCLoadingHUD hideInView:self.view];
        [self.tableViewEpisodes reloadData];
    });
    
}

#pragma TableView Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    MTSShow *show = [self.arrayValues objectAtIndex:indexPath.row];
    
//    SeasonsListViewController *viewController = [[UIStoryboard storyboardWithName:@"SeasonsList" bundle:nil] instantiateInitialViewController];
//    viewController.show = show;
//    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellEpisodesList"];
    EpisodesListCell *currentCell = (EpisodesListCell *) cell;
    currentCell.episode = [self.arrayValues objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayValues.count;
}

@end
