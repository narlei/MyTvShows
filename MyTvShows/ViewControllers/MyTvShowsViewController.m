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
@end

@implementation MyTvShowsViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [LCLoadingHUD showLoading:@"Carregando" inView:self.view];
    
    [self.notification displayNotificationWithMessage:@"Buscando novos dados..." completion:nil];
    
    
    if (![[MTSTrakt sharedMTSTrakt] authenticateForce:NO]) {
        [self loadData];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:DEF_OBSERVER_TOKEN_RECEIVED object:nil];
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
    
    [self refreshData];
    
    [[MTSTrakt sharedMTSTrakt] downloadWatchedListOnComplete:^(NSDictionary *dicReturn) {
        if (![[MTSTrakt sharedMTSTrakt] showError:dicReturn]) {
            [[MTSTrakt sharedMTSTrakt] downloadAllShowsOnComplete:^(NSDictionary *dicReturn) {
            
                [[MTSTrakt sharedMTSTrakt] showError:dicReturn];
                
                [self refreshData];
                [self.notification dismissNotification];
            }];
        }else{
            [LCLoadingHUD hideInView:self.view];
            [self.notification dismissNotification];
        }
    }];
}

-(void) refreshData{
    self.arrayAllValues = [[NSMutableArray alloc] initWithArray:[MTSShow getAllDataWhere:@"traktId IN (SELECT DISTINCT showId FROM MTSEpisodeWatched)"]];
    self.arrayValues = [[NSMutableArray alloc] initWithArray:self.arrayAllValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        //                    [LCLoadingHUD hideInView:self.view];
        
        [self.tableViewShows reloadData];
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
