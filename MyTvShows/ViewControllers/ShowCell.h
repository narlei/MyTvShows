//
//  ShowCell.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 14/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowCell : UITableViewCell


@property (strong, nonatomic) MTSShow *show;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;

@end
