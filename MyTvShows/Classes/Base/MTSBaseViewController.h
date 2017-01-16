//
//  MTSBaseViewController.h
//  MyTvShows
//
//  Created by Narlei A Moreira on 14/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStatusBarNotification.h"

@interface MTSBaseViewController : UIViewController

@property (strong, nonatomic) CWStatusBarNotification *notification;

@end
