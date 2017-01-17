//
//  MTSBaseViewController.m
//  MyTvShows
//
//  Created by Narlei A Moreira on 14/01/17.
//  Copyright © 2017 Narlei A Moreira. All rights reserved.
//

#import "MTSBaseViewController.h"

@interface MTSBaseViewController ()

@end

@implementation MTSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor whiteColor];
    self.notification.notificationLabelTextColor = [UIColor blackColor];

    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
