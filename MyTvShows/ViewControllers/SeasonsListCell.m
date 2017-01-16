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
    self.textLabel.text = [NSString stringWithFormat:@"Temporada %@",season.number];
}

@end
