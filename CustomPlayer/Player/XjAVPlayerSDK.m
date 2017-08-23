//
//  XjAVPlayerSDK.m
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XjAVPlayerSDK.h"
#import "XJAVPlyer.h"
#import "UIDevice+XJDevice.h"
#import "UIView+Utils.h"
#import "PlayMenu.h"

#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

@interface XjAVPlayerSDK (){
    BOOL isStop;//是否关闭过播放器（关闭，不是暂停）
}

@property (nonatomic, strong)XJAVPlyer *xjPlayer;
@property (nonatomic,strong) PlayMenu *menu;
@property (nonatomic, assign)CGRect firstFrame;//初始化的视屏大小
@property (nonatomic, strong)NSString *saveUrl;//保存url;
@property (nonatomic, strong)NSString *saveTitle;//保存标题

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;//菊花图

@end

@implementation XjAVPlayerSDK

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
        self.firstFrame = frame;
        [self addAllView];
    }
    return self;
}

- (void)addAllView{
    [self.xjPlayer addSubview:self.menu];
    [self addSubview:self.xjPlayer];
    [self addSubview:self.loadingView];
}

#pragma mark - **************************** 外部接口 *************************************
- (void)xjStopPlayer
{
    [self.xjPlayer xjStop];
}

- (CGFloat)xjCurrentTime
{
    return self.xjPlayer.xjCurrentTime;
}

- (CGFloat)xjTotalTime
{
    return self.xjPlayer.xjTotalTime;
}

#pragma mark - **************************** xjAVPlayer方法 ************************
- (void)xjAVPlayerBLock
{
    WS(weakSelf);
    //加载成功回调
    self.xjPlayer.xjPlaySuccessBlock = ^{
        weakSelf.menu.xjPlay = YES;//如果想一进来就播放，就放开注释
        [weakSelf.loadingView stopAnimating];
//        [weakSelf.loadingView setHidesWhenStopped:YES];
    };
    //播放失败回调
    self.xjPlayer.xjPlayFailBlock = ^{
        weakSelf->isStop = YES;//保证点击播放按钮能播放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.loadingView) {
                [weakSelf.loadingView stopAnimating];
//                [weakSelf.loadingView setHidesWhenStopped:YES];
            }
        });
    };
    //加载进度
    self.xjPlayer.xjLoadedTimeBlock = ^(CGFloat time){
        weakSelf.menu.xjLoadedTimeRanges = time;
    };
    //视屏总长
    self.xjPlayer.xjTotalTimeBlock = ^(CGFloat time){
        weakSelf.menu.xjTotalTime = time;
    };
    //当前时间
    self.xjPlayer.xjCurrentTimeBlock = ^(CGFloat time){
        weakSelf.menu.xjCurrentTime = time;
    };
    //播放完
    self.xjPlayer.xjPlayEndBlock = ^{
        [weakSelf.loadingView stopAnimating];
//        [weakSelf.loadingView setHidesWhenStopped:YES];
        weakSelf.menu.xjPlayEnd = YES;
    };
    //关闭控件
    self.xjPlayer.xjPlayerStop = ^{
        weakSelf->isStop = YES;
        weakSelf.menu.xjPlayEnd = YES;
    };
    //方向改变
    self.xjPlayer.xjDirectionChange = ^(UIDeviceOrientation orient){
        if (weakSelf.xjAutoOrient) {
            if (orient == UIDeviceOrientationPortrait) {
                weakSelf.frame = weakSelf.firstFrame;
                weakSelf.menu.xjFull = NO;
            }else if(orient == UIDeviceOrientationLandscapeLeft||orient == UIDeviceOrientationLandscapeRight){
                weakSelf.frame = weakSelf.window.bounds;
                weakSelf.menu.xjFull = YES;
            }
        }
    };
    //播放延迟
    self.xjPlayer.xjDelayPlay = ^(BOOL flag){
        if (flag&&!weakSelf->isStop) {
            [weakSelf.loadingView startAnimating];
        }else{
            [weakSelf.loadingView stopAnimating];
        }
    };
}

#pragma mark - **************************** XJBottomMenu方法 **************************
- (void)xjBottomMenuBlock{
    WS(weakSelf);
    //播放/暂停
    self.menu.xjPlayOrPauseBlock = ^(BOOL isPlay){
        if (weakSelf->isStop) {
            weakSelf->isStop = NO;
            weakSelf.xjPlayer.xjPlayerUrl = weakSelf.saveUrl;
        }
        if (isPlay) {
            [weakSelf.xjPlayer xjPlay];
        }else{
            [weakSelf.xjPlayer xjPause];
        }
    };
    //滑动条滑动时
    self.menu.xjSliderValueChangeBlock = ^(CGFloat time){
        [weakSelf.xjPlayer xjSeekToTimeWithSeconds:time];
        [weakSelf.xjPlayer xjPause];
    };
    //滑动条拖动完成
    self.menu.xjSliderValueChangeEndBlock = ^(CGFloat time){
        [weakSelf.xjPlayer xjSeekToTimeWithSeconds:time];
    };
    //放大/缩小
    self.menu.xjFullOrSmallBlock = ^(BOOL isFull){
        if (weakSelf.IsfullBlock)
        {
            weakSelf.IsfullBlock(isFull);
        }
        if (isFull) {
            [UIDevice setOrientation:UIInterfaceOrientationLandscapeRight];
            weakSelf.frame = weakSelf.window.bounds;
            [weakSelf prefersStatusBarHidden];
        }else{
            [UIDevice setOrientation:UIInterfaceOrientationPortrait];
            weakSelf.frame = weakSelf.firstFrame;
        }
    };
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - **************************** 懒加载 ****************************************
- (XJAVPlyer *)xjPlayer{
    if (_xjPlayer == nil) {
        _xjPlayer = [[XJAVPlyer alloc] init];
        [self xjAVPlayerBLock];
    }
    return _xjPlayer;
}

- (void)setXjPlayerUrl:(NSString *)xjPlayerUrl{
    _xjPlayerUrl = xjPlayerUrl;
    self.saveUrl = _xjPlayerUrl;
    self.xjPlayer.xjPlayerUrl = _xjPlayerUrl;
}

- (PlayMenu *)menu
{
    if (!_menu) {
        _menu = [[PlayMenu alloc] init];
        [self xjBottomMenuBlock];
    }
    return _menu;
}

- (UIActivityIndicatorView *)loadingView{
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.hidesWhenStopped = YES;
        [_loadingView startAnimating];
    }
    return _loadingView;
}

#pragma mark - **************************** 布局 *************************************
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.xjPlayer.frame = CGRectMake(0, 0, self.width, self.height);
    self.menu.frame = CGRectMake(0, 0,self.xjPlayer.width, self.xjPlayer.height);
    self.loadingView.center = CGPointMake(self.xjPlayer.centerX, self.xjPlayer.centerY);
}

@end
