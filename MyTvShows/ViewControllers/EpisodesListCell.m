//
//  EpisodesListCell.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "EpisodesListCell.h"

@implementation EpisodesListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setEpisode:(MTSEpisode *)episode{
    _episode = episode;
    self.textLabel.text = episode.title;
}

@end
