//
//  ViewController.m
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import "ViewController.h"

#import "QLPlayerView/QLPlayerView.h"

@interface ViewController ()<QLPlayerViewDelegate>
@property(nonatomic,strong)QLPlayerView * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[QLPlayerView alloc]initWithFrame:CGRectMake(0, 64, QLSCREEN_W, 200) delegate:self url:@""];
    [self.view addSubview:self.player];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
