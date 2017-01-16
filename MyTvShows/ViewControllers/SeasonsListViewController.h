//
//  SeasonsListViewController.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "MTSBaseViewController.h"

@interface SeasonsListViewController : MTSBaseViewController

@property (strong, nonatomic) MTSShow *show;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSeasons;

@end
