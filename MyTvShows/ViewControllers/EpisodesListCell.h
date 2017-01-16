//
//  EpisodesListCell.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpisodesListCell : UITableViewCell

@property (strong, nonatomic) MTSEpisode *episode;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchWatched;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

- (IBAction)actionSwitchWatched:(id)sender;


@end
