//
//  QLPlayerView.h
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

#define QLSCREEN_W [UIScreen mainScreen].bounds.size.width
#define QLSCREEN_H [UIScreen mainScreen].bounds.size.height
#ifdef DEBUG//调试状态
#define QLLog(...) NSLog(__VA_ARGS__)
#endif

@class QLPlayerView;
@protocol QLPlayerViewDelegate <NSObject>
@optional
//点击全屏按钮
-(void)wmplayer:(QLPlayerView *)qlplayer clickedFullScreenButton:(UIButton *)fullScreenBtn;
//点击关闭按钮代理方法
-(void)wmplayer:(QLPlayerView *)qlplayer clickedCloseButton:(UIButton *)closeBtn;

@end

@interface QLPlayerView : UIView
@property (nonatomic, weak) id<QLPlayerViewDelegate> delegate;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong)IJKFFMoviePlayerController * player;

-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate url:(NSString *)url;
- (void)releasePlayer;
@end
