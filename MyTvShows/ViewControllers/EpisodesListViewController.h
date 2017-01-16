//
//  EpisodesListViewController.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "MTSBaseViewController.h"

@interface EpisodesListViewController : MTSBaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViewEpisodes;

@property (strong, nonatomic) MTSSeason *season;

@end
