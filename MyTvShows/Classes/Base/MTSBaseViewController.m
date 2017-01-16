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
    // Do any additional setup after loading the view.
    
    // Configuração da Barra de Navegação
    
    
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.78 blue:0.91 alpha:1.00];
//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
//    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
