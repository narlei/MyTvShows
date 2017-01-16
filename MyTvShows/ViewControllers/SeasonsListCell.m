//
//  SeasonsListCell.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "SeasonsListCell.h"

@implementation SeasonsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSeason:(MTSSeason *)season{
    _season = season;
    self.labelTitle.text = [NSString stringWithFormat:@"Temporada %@",season.number];
    
    int totalWatchedInt = (int)[MTSEpisodeWatched getAllDataWhere:[NSString stringWithFormat:@"showId = %@ AND seasonId = %@",season.showId,season.number]].count;
    
    int percentageWatched = (totalWatchedInt * 100) / (int)season.arrayEpisodes.count;
    
    NSString *status = [NSString stringWithFormat:@"Status: Assistidos %d/%lu (%d%%)",totalWatchedInt,(unsigned long)season.arrayEpisodes.count,percentageWatched];
    
    self.labelStatus.text = status;
}

@end
