//
//  ViewController.m
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

#import "QLPlayerView/QLPlayerView.h"

@interface ViewController ()<QLPlayerViewDelegate>
@property(nonatomic,strong)QLPlayerView * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)pushToNext:(UIButton *)sender {
    TestViewController *vc = [[TestViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
