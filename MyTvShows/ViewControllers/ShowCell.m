//
//  ShowCell.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 14/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "ShowCell.h"

@implementation ShowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setShow:(MTSShow *)show {
    _show = show;
    self.labelTitle.text = show.title;

    self.labelStatus.text = @"Carregando Status...";

    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    int totalWatchedInt = (int) [MTSEpisodeWatched getAllDataWhere:[NSString stringWithFormat:@"showId = %@", show.traktId]].count;
    int totalEpisodes = (int) [MTSEpisode getAllDataWhere:[NSString stringWithFormat:@"showId = %@", show.traktId]].count;

    int percentageWatched = (totalWatchedInt * 100) / totalEpisodes;

    NSString *status = [NSString stringWithFormat:@"Status: Assistidos %d/%d (%d%%)", totalWatchedInt, totalEpisodes, percentageWatched];
    self.labelStatus.text = status;
    //    });
}


@end
