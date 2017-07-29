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
#define QLLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

@class QLPlayerView;
@protocol QLPlayerViewDelegate <NSObject>
@optional
//点击全屏按钮
-(void)qlplayer:(QLPlayerView *)qlplayer clickedFullScreenButton:(UIButton *)fullScreenBtn;
//点击关闭按钮代理方法
-(void)qlplayer:(QLPlayerView *)qlplayer clickedCloseButton:(UIButton *)closeBtn;
//蒙版视图变化时调用
-(void)qlplayer:(QLPlayerView *)qlplayer isHiddenCoverView:(BOOL)isHidden;

//将要播放时调用代理方法
-(void)qlplayerReadyToPlay:(QLPlayerView *)qlplayer;
//播放完毕的代理方法
-(void)qlplayerFinishedPlay:(QLPlayerView *)qlplayer;


@end

@interface QLPlayerView : UIView
@property (nonatomic, weak) id<QLPlayerViewDelegate> delegate;
@property (nonatomic, copy) NSString *url;
// 控制返回按钮的样式和功能
@property (nonatomic, assign ) BOOL isFullscreen;

-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate url:(NSString *)url;
- (void)releasePlayer;
- (void)startPlay;
@end
