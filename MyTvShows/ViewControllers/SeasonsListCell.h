//
//  SeasonsListCell.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 16/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeasonsListCell : UITableViewCell

@property (strong, nonatomic) MTSSeason *season;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;

@end
