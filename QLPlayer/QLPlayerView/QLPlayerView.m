//
//  QLPlayerView.m
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import "QLPlayerView.h"
#import "Masonry.h"

@interface QLPlayerView ()<UIGestureRecognizerDelegate>
{
    BOOL _hasPrepareToPlay;
}
@property (nonatomic, strong)IJKFFMoviePlayerController * player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIImageView *coverImageView;
// topView
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *labelTitle;
// bottomView
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIProgressView *loadingProgress;
// middleView
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *errorLabel;
// 定时器
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation QLPlayerView
- (void)dealloc {
    QLLog(@"释放播放器");
    [self releaseTimer];   
}

#pragma mark ******** 初始化方法
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<QLPlayerViewDelegate>)delegate url:(NSString *)url {
    if (self = [super initWithFrame:frame]) {
        [self creatCoverView];
        self.delegate = delegate;
        self.url = url;
    }
    return self;
}

- (void)setUrl:(NSString *)url {
    [self resetPlayer];
    _url = url;
    [self setupPlayerView];
}

- (void)resetPlayer {
    [_player stop];
    [self releaseTimer];
    _playOrPauseBtn.selected = YES;
    _progressSlider.value = 0.0;
    _loadingProgress.progress = 0.0;
    _leftTimeLabel.text = @"00:00:00/";
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    _coverView.alpha = 1.0;
    _coverView.hidden = NO;
    _hasPrepareToPlay = NO;
    
}

//MARK:开始播放
- (void)startPlay {
    [_loadingView startAnimating];
    if (_hasPrepareToPlay) {
        [self.player play];
    } else {
        [self.player prepareToPlay];
    }
    
}


#pragma mark ******** 滑杆事件
- (void)updateProgress:(UISlider *)slider{
    if (!self.player.isPlaying) {
        slider.value = 0.0;
        return;
    }
    //取消收回工具栏的动作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    _player.currentPlaybackTime = slider.value*_player.duration;
    [self performSelector:@selector(hide) withObject:nil afterDelay:4];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    if (!self.player.isPlaying) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    UISlider * slider = (UISlider *)sender.view;
    
    CGPoint point = [sender locationInView:_progressSlider];
    
    [_progressSlider setValue:point.x/_progressSlider.bounds.size.width*1 animated:YES];
    
    _player.currentPlaybackTime = slider.value*_player.duration;
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:4];

}
#pragma mark ******** 按钮事件
- (void)backBtnClick:(UIButton *)sender {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(qlplayer:clickedCloseButton:)]) {
        [self.delegate qlplayer:self clickedCloseButton:sender];
    }
}
- (void)PlayOrPause:(UIButton *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.loadingView stopAnimating];
        [self.player pause];
        
    }else{
        [self startPlay];
    }
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:4];
}
-  (void)fullScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(qlplayer:clickedFullScreenButton:)]) {
        [self.delegate qlplayer:self clickedFullScreenButton:sender];
    }
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    self.backBtn.hidden = !isFullscreen;
    self.labelTitle.hidden = !isFullscreen;
}

#pragma mark-点击了playerView
BOOL _hideCover;
-(void)playerViewTap:(UITapGestureRecognizer *)recognizer{
    //每次点击取消还在进程中的隐藏方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.25 animations:^{
        if (!_hideCover) {
            self.coverView.alpha = 0;
            if (self.delegate && [self.delegate respondsToSelector:@selector(qlplayer:isHiddenCoverView:)]) {
                [self.delegate qlplayer:self isHiddenCoverView:YES];
            }
        }else{
            self.coverView.alpha = 1;
            if (self.delegate && [self.delegate respondsToSelector:@selector(qlplayer:isHiddenCoverView:)]) {
                [self.delegate qlplayer:self isHiddenCoverView:NO];
            }
        }
    } completion:^(BOOL finished) {
        if (!_hideCover) {
            self.coverView.hidden = YES;
        }else{
            self.coverView.hidden = NO;
            _hideCover = NO;
            //如果最后没隐藏,在调用隐藏的代码
            [self performSelector:@selector(hide) withObject:nil afterDelay:4];
        }
    }];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}
#pragma mark-隐藏cover

-(void)hide{
    if (!self.player.isPlaying) {
        _hideCover = YES;
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.alpha =0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(qlplayer:isHiddenCoverView:)]) {
            [self.delegate qlplayer:self isHiddenCoverView:YES];
        }
    }completion:^(BOOL finished) {
        self.coverView.hidden = YES;
        _hideCover = YES;
    }];
}

#pragma mark-touchBengan
CGPoint startP;
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touchbegan=======%d",_hideCover);
    
    startP = [[touches anyObject] locationInView:self.playerView];
    
    if (!_hideCover) {
        [self hide];
    }
}

#pragma mark ******** ObserversActions
- (void)loadStateDidChange:(NSNotification *)noti {
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {//可以播放
        _errorLabel.hidden = YES;
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {//网速不好
        [_loadingView startAnimating];
    } else {
        QLLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }

}
//播放结束
- (void)moviePlayBackFinish:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qlplayerFinishedPlay:)]) {
        [self.delegate qlplayerFinishedPlay:self];
    }
    
    int reason =[[[noti userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            self.url = _url;
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            QLLog(@"playbackStateDidChange: 用户退出播放: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            [_loadingView stopAnimating];
            _errorLabel.hidden = NO;
            _hasPrepareToPlay = NO;
            break;
            
        default:
            QLLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}
// 准备开始播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qlplayerReadyToPlay:)]) {
        [self.delegate qlplayerReadyToPlay:self];
    }
    _hasPrepareToPlay = YES;
    _rightTimeLabel.text =[NSString stringWithFormat:@"%@",[self TimeformatFromSeconds:self.player.duration]];
    
    
}

// 播放状态改变
- (void)moviePlayBackStateDidChange:(NSNotification *)noti {
    if (self.player.playbackState==IJKMPMoviePlaybackStatePlaying) {
        //视频开始播放的时候开启计时器
        [self releaseTimer];//由于这里会运行不止一次, 所以添加之前要释放原来的
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateVideoUI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
        if (self.playOrPauseBtn.isSelected) {//在播放时需要把播放按钮置为播放状态
            self.playOrPauseBtn.selected = NO;
        }
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:4];
        _coverImageView.hidden = YES;
        
        [_loadingView stopAnimating];
        
    } else if(_player.playbackState == IJKMPMoviePlaybackStatePaused) {//暂停
        QLLog(@"视频暂停播放");
        
    } else if(_player.playbackState == IJKMPMoviePlaybackStateStopped) {//停止
        QLLog(@"视频停止播放");
        
    } else if(_player.playbackState == IJKMPMoviePlaybackStateInterrupted) {//打断
        QLLog(@"视频被打断");
        
    } else if(_player.playbackState == IJKMPMoviePlaybackStateSeekingForward) {//快进
        QLLog(@"视频快进");
        
    } else if(_player.playbackState == IJKMPMoviePlaybackStateSeekingBackward) {//快退
        QLLog(@"视频快退");
        
    }
}
#pragma mark ******** 更新播放进度
- (void)updateVideoUI {
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@/",[self TimeformatFromSeconds:self.player.currentPlaybackTime]];
    
    CGFloat current = self.player.currentPlaybackTime;
    CGFloat total = self.player.duration;
    CGFloat able = self.player.playableDuration;
    [_progressSlider setValue:current/total animated:YES];
    [_loadingProgress setProgress:able/total animated:YES];
}

#pragma mark ******** UI
//MARK:释放播放器
- (void)ql_releasePlayer {
    [self releasePlayer];
    if (self.playerView.superview) {
        [self.playerView removeFromSuperview];
        self.player = nil;
        self.playerView = nil;
    }
}
- (void)releasePlayer {
    [self releaseTimer];
     [self removeMovieNotificationObservers];
    [self.player shutdown];
    self.player = nil;
}

- (void)releaseTimer {
    if (!self.timer) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark-初始化playerView
- (void)setupPlayerView {
    [self ql_releasePlayer];
    //MARK:ijkPlayer初始配置
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    
    //设置日志级别
    [IJKFFMoviePlayerController setLogReport:NO];
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    //MARK:创建播放器
    NSString *urlStr = self.url.length > 0 ? self.url : @"";
    NSURL *url = [NSURL URLWithString:urlStr];
    self.player = [[IJKFFMoviePlayerController alloc]initWithContentURL:url withOptions:options];
    [self.player setScalingMode:IJKMPMovieScalingModeFill];
    self.player.shouldAutoplay = YES;//放在前面才有效
    [self installMovieNotificationObservers];
    
    //获取播放视图
    self.playerView = [self.player view];
    self.playerView.frame = self.bounds;
    //把播放视图插到最上面去
    [self insertSubview:self.playerView atIndex:0];
    
    //封面图片视图
    self.coverImageView = [[UIImageView alloc]init];
    [self.playerView addSubview:self.coverImageView];
    _coverImageView.userInteractionEnabled = YES;
    _coverImageView.image = [UIImage imageNamed:@"placeHolderbg"];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.playerView);
    }];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.playerView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
    }];
    
    self.errorLabel = [[UILabel alloc]init];
    _errorLabel.textColor = [UIColor whiteColor];
    _errorLabel.text = @"视频播放失败";
    _errorLabel.hidden = YES;
    _errorLabel.font = [UIFont systemFontOfSize:18];
    _errorLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
    [_errorLabel sizeToFit];
    [self.playerView addSubview:_errorLabel];
    [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
    }];
    
    //点击手势
    UITapGestureRecognizer * tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerViewTap:)];
    tap.delegate = self;
    [self.playerView addGestureRecognizer:tap];
    // 添加蒙版视图
    [self.playerView addSubview:self.coverView];
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.playerView);
    }];
}

#pragma mark ******** 蒙版视图
- (void)creatCoverView {
    self.coverView = [[UIView alloc]init];
    self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self ql_creatTopView];
    [self ql_creatBottomView];
    
}
//MARK:上层建筑
- (void)ql_creatTopView {
    self.topView = [[UIView alloc]init];
    UIImage *img = [UIImage imageNamed:@"top_shadow"];
    _topView.layer.contents = (__bridge id _Nullable)img.CGImage;
    _topView.layer.contentsGravity = kCAGravityResize;
    _topView.layer.contentsScale = [UIScreen mainScreen].scale;
    [self.coverView addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_coverView.mas_left);
        make.top.equalTo(_coverView.mas_top);
        make.right.equalTo(_coverView.mas_right);
        make.height.mas_equalTo(70);
    }];
    
    //返回按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"play_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topView.mas_left).offset(5);
        make.top.equalTo(_topView.mas_top).offset(10);
        make.height.width.mas_equalTo(30);
    }];
    
    //标题
    self.labelTitle = [[UILabel alloc]init];
    _labelTitle.text = @"我是一个视频";
    [self.labelTitle sizeToFit];
    self.labelTitle.textColor = [UIColor whiteColor];
    self.labelTitle.backgroundColor = [UIColor clearColor];
    self.labelTitle.numberOfLines = 1;
    self.labelTitle.font = [UIFont systemFontOfSize:15.0];
    [self.topView addSubview:self.labelTitle];
    [_labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backBtn.mas_right).offset(5);
        make.right.lessThanOrEqualTo(_topView.mas_right).offset(-15);
        make.centerY.equalTo(_backBtn.mas_centerY);
    }];
}
//MARK:经济基础
- (void)ql_creatBottomView {
    self.bottomView = [[UIView alloc]init];
    UIImage *img = [UIImage imageNamed:@"bottom_shadow"];
    _bottomView.layer.contents = (__bridge id _Nullable)img.CGImage;
    _bottomView.layer.contentsGravity = kCAGravityResize;
    _bottomView.layer.contentsScale = [UIScreen mainScreen].scale;
    [self.coverView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_coverView.mas_left);
        make.bottom.equalTo(_coverView.mas_bottom);
        make.right.equalTo(_coverView.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    // 播放按钮
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    self.playOrPauseBtn.selected = YES;//默认状态，即默认是不自动播放
    [self.bottomView addSubview:self.playOrPauseBtn];
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.bottomView);
        make.width.mas_equalTo(50);
    }];
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"nonfullscreen"] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomView).with.offset(- 15);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
        make.centerY.equalTo(_bottomView);
    }];
    
    
    //rightTimeLabel显示右边的总时间
    self.rightTimeLabel = [[UILabel alloc]init];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.rightTimeLabel sizeToFit];
    [self.bottomView addSubview:self.rightTimeLabel];
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullScreenBtn.mas_left).with.offset(-5);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(20);
    }];
    self.rightTimeLabel.text = @"00:00:00";//设置默认值
    
    //leftTimeLabel显示左边的时间进度
    self.leftTimeLabel = [[UILabel alloc]init];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightTimeLabel.mas_left).with.offset(0);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.bottomView);
    }];
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%@/", @"00:00:00"];//设置默认值
    
    //滑杆套件
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.maximumValue = 1.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"dot"]  forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    self.progressSlider.value = 0.0;//指定初始值
    //进度条的拖拽事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:)  forControlEvents:UIControlEventValueChanged];
    //给进度条添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    tap.delegate = self;
    [self.progressSlider addGestureRecognizer:tap];
    [self.bottomView addSubview:self.progressSlider];
    self.progressSlider.backgroundColor = [UIColor clearColor];
    //autoLayout slider
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(50);
        make.right.equalTo(self.leftTimeLabel.mas_left).with.offset(-5);
        make.centerY.equalTo(self.bottomView.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    
    // 进度条
    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.loadingProgress.trackTintColor    = [UIColor clearColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(50);
        make.right.equalTo(self.progressSlider);
        make.centerY.equalTo(self.bottomView.mas_centerY);
    }];
}

#pragma mark ******** 工具代码
- (NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

#pragma mark-观察视频播放状态
- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}

@end
