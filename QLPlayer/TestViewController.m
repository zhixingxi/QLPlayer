//
//  TestViewController.m
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import "TestViewController.h"
#import "QLPlayerView.h"

@interface TestViewController ()
@property (nonatomic, strong)QLPlayerView *player;
@end

@implementation TestViewController

- (void)dealloc {
    QLLog(@"释放控制器");
//    [self.player.player shutdown];
    [self.player releasePlayer];
    self.player = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.player = [[QLPlayerView alloc]initWithFrame:CGRectMake(0, 64, QLSCREEN_W, 200) delegate:self url:@"http://cdn.shjujiao.com/video/10.201707141127.flv"];
    _player.isFullscreen = NO;
    [self.view addSubview:self.player];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.player.url = @"http://cdn.shjujiao.com/video/11.201707141128.flv";
        [self.player startPlay];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
