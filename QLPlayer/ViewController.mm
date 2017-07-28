//
//  ViewController.m
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import "ViewController.h"

#import <IJKMediaFramework/IJKMediaFramework.h>

@interface ViewController ()
@property(nonatomic,strong)IJKFFMoviePlayerController * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    [self.view addSubview:v];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault]; //使用默认配置
    NSURL * url = [NSURL URLWithString:@"http://cdn.shjujiao.com/video/2.201707141119.flv"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options]; //初始化播放器，播放在线视频或直播(RTMP)
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = v.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit; //缩放模式
    self.player.shouldAutoplay = NO; //开启自动播放
    
    self.view.autoresizesSubviews = YES;
    [v addSubview:self.player.view];
//    [self setupLayout];
}

- (void)setupLayout {
    self.player.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.player.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.player.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.player.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.player.view.heightAnchor constraintEqualToConstant:200].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player prepareToPlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
    
    

    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player shutdown];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
