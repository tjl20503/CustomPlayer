//
//  PlayMenu.m
//  Player
//
//  Created by Future on 2017/8/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "PlayMenu.h"
#import "UIView+Utils.h"

@interface PlayMenu ()
{
    BOOL isPlay;
    BOOL isHour;
}

@property (nonatomic,strong) UIView *topMenu;
@property (nonatomic,strong) UIView *bottomMenu;

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *collectionButton;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *fullButton;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UISlider *playSlider;

@end

@implementation PlayMenu

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self creatUI];
    }
    return self;
}

- (void)creatUI
{
    [self addSubview:self.topMenu];
    [self addSubview:self.bottomMenu];
    
    [self.topMenu addSubview:self.backButton];
    [self.topMenu addSubview:self.collectionButton];
    self.topMenu.hidden = YES;
    
    [self.bottomMenu addSubview:self.playButton];
    [self.bottomMenu addSubview:self.playSlider];
    [self.bottomMenu addSubview:self.fullButton];
    [self.bottomMenu addSubview:self.timeLabel];
}


#pragma mark - 懒加载
- (UIView *)topMenu
{
    if (!_topMenu) {
        _topMenu = [[UIView alloc] init];
        _topMenu.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.7];
    }
    return _topMenu;
}

- (UIView *)bottomMenu
{
    if (!_bottomMenu) {
        _bottomMenu = [[UIView alloc] init];
        _bottomMenu.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.7];
    }
    return _bottomMenu;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(go_back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)collectionButton
{
    if (!_collectionButton) {
        _collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectionButton setImage:[UIImage imageNamed:@"collection_no"] forState:UIControlStateNormal];
        [_collectionButton setImage:[UIImage imageNamed:@"collection_select"] forState:UIControlStateSelected];
        [_collectionButton addTarget:self action:@selector(collection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectionButton;
}

- (UIButton *)fullButton
{
    if (!_fullButton) {
        _fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [_fullButton addTarget:self action:@selector(fullOrSmallAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playOrPauseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UISlider *)playSlider{
    if (_playSlider == nil) {
        _playSlider = [[UISlider alloc] init];
        _playSlider.minimumValue = 0.0;
        
        UIGraphicsEndImageContext();
        [self.playSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        
        [_playSlider addTarget:self action:@selector(playSliderValueChanging:) forControlEvents:UIControlEventValueChanged];
        [_playSlider addTarget:self action:@selector(playSliderValueDidChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playSlider;
}

- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:00:00/00:00:00";
    }
    return _timeLabel;
}

#pragma mark - 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topMenu.frame = CGRectMake(0, 0, self.width, 40);
    self.bottomMenu.frame = CGRectMake(0, self.height - 40, self.width, 40);
    
    self.backButton.frame = CGRectMake(0, 0, 30, 40);
    self.collectionButton.frame = CGRectMake(self.width - 30, 0, 30, 40);
    
    self.playButton.frame = CGRectMake(5, 0, 36, 40);
    self.fullButton.frame = CGRectMake(self.width-35, 0, 35, 40);
    self.timeLabel.frame = CGRectMake(self.fullButton.left-108, 10, 108, 20);
    self.playSlider.frame = CGRectMake(self.playButton.right+5, 5, self.timeLabel.left-self.playButton.right-14 + 4, 31);
}

#pragma mark - 事件点击
- (void)go_back
{
    self.xjFull = NO;
    [self.fullButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    if (self.xjFullOrSmallBlock) {
        self.xjFullOrSmallBlock(self.xjFull);
    }
    self.topMenu.hidden = YES;
}

- (void)collection
{
    
}

- (void)fullOrSmallAction
{
    if (self.xjFull) {
        self.xjFull = NO;
        [self.fullButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        self.topMenu.hidden = YES;
    }else{
        self.xjFull = YES;
        [self.fullButton setImage:[UIImage imageNamed:@"nofull"] forState:UIControlStateNormal];
        self.topMenu.hidden = NO;
    }
    
    if (self.xjFullOrSmallBlock) {
        self.xjFullOrSmallBlock(self.xjFull);
    }
}

- (void)playOrPauseAction
{
    if (isPlay) {
        isPlay = NO;
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        isPlay = YES;
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    if (self.xjPlayOrPauseBlock) {
        self.xjPlayOrPauseBlock(isPlay);
    }
}

- (void)playSliderValueChanging:(UISlider *)sender
{
    isPlay = NO;
    UISlider *slider = (UISlider*)sender;
    if (self.xjSliderValueChangeBlock) {
        self.xjSliderValueChangeBlock(slider.value);
    }
}

- (void)playSliderValueDidChanged:(UISlider *)sender
{
    UISlider *slider = (UISlider*)sender;
    if (self.xjSliderValueChangeEndBlock) {
        self.xjSliderValueChangeEndBlock(slider.value);
    }
    [self playOrPauseAction];
}

#pragma mark - 初始数据
//总时长
- (void)setXjTotalTime:(CGFloat)xjTotalTime{
    _xjTotalTime = xjTotalTime;
    NSString *time = [self xjPlayerTimeStyle:_xjTotalTime];
    if (isHour) {
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/%@",time];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/00:%@",time];
    }
    self.playSlider.maximumValue = _xjTotalTime;//设置slider的最大值就是总时长
}

//定义视屏时长样式
- (NSString *)xjPlayerTimeStyle:(CGFloat)time{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (time/3600>1) {
        isHour = YES;
        [formatter setDateFormat:@"HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showTimeStyle = [formatter stringFromDate:date];
    return showTimeStyle;
}

- (void)setXjPlayEnd:(BOOL)xjPlayEnd{
    _xjPlayEnd = xjPlayEnd;
    if (_xjPlayEnd) {
        isPlay = NO;
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playSlider setValue:0.0 animated:YES];
        NSString *time = [self xjPlayerTimeStyle:self.xjTotalTime];
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/00:%@",time];
    }
}

- (void)setXjPlay:(BOOL)xjPlay{
    
    [self playOrPauseAction];
}

//已加载
- (void)setXjLoadedTimeRanges:(CGFloat)xjLoadedTimeRanges{
    _xjLoadedTimeRanges = xjLoadedTimeRanges;
}

//已播放
- (void)setXjCurrentTime:(CGFloat)xjCurrentTime{
    _xjCurrentTime = xjCurrentTime;
    [self.playSlider setValue:xjCurrentTime animated:YES];
    NSString *time1 = [self xjPlayerTimeStyle:xjCurrentTime];
    NSString *time2 = [self xjPlayerTimeStyle:self.xjTotalTime];
    if (isHour) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",time1,time2];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%@/00:%@",time1,time2];
    }
}

@end
