//
//  XJAVPlyer.m
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XJAVPlyer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+XJDevice.h"

#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

@interface XJAVPlyer (){
    BOOL isSuccess;//是否播放成功
    BOOL isPlayNow;
}

@property (nonatomic, strong) AVPlayer       *xjPlayer;
@property (nonatomic, strong) AVPlayerItem   *xjPlayerItem;
@property (nonatomic, strong) AVURLAsset     *videoURLAsset;

@property (nonatomic, strong) id playbackTimeObserver;//界面更新时间ID
@property (nonatomic, strong) CADisplayLink *link;//以屏幕刷新率进行定时操作
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) NSURL *filePath;

@end

@implementation XJAVPlyer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)p {
    [(AVPlayerLayer *)[self layer] setPlayer:p];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];//注册监听，屏幕方向改变
    }
    return self;
}

#pragma mark - **************************** 初始化播放器 *************************************
- (void)xjPlayerInit{
    //限制锁屏
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    if (self.xjPlayer) {
        self.xjPlayer = nil;
        [self xjRemoveObserver];
    }
    
    [self fileExistsAtPath:self.xjPlayerUrl];
    
    self.videoURLAsset = [AVURLAsset URLAssetWithURL:self.filePath options:nil];
    self.xjPlayerItem = [AVPlayerItem playerItemWithAsset:self.videoURLAsset];
    if (self.xjPlayer.currentItem) {
        [self.xjPlayer replaceCurrentItemWithPlayerItem:self.xjPlayerItem];
    }else {
        self.xjPlayer = [AVPlayer playerWithPlayerItem:self.xjPlayerItem];
    }
    [self setPlayer:self.xjPlayer];
    
    [self.xjPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听status属性变化
    [self.xjPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//监听loadedTimeRanges属性变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xjPlayerEndPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.xjPlayerItem];//注册监听，视屏播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
}


#pragma mark - **************************** 监听事件 *************************************
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            NSLog(@"播放成功");
            
            isSuccess = YES;
            
            CMTime duration = self.xjPlayerItem.duration;//获取视屏总长
            CGFloat totalSecond = CMTimeGetSeconds(duration);//转换成秒
            if (self.xjTotalTimeBlock) {
                self.xjTotalTimeBlock(totalSecond);
            }
            
            if (self.xjPlaySuccessBlock) {
                self.xjPlaySuccessBlock();
            }
        
            CGFloat currentSecond = self.xjPlayerItem.currentTime.value/self.xjPlayerItem.currentTime.timescale;//获取当前时间
            if (self.xjCurrentTimeBlock) {
                self.xjCurrentTimeBlock(currentSecond);
            }
            
            [self monitoringXjPlayerBack];//监听播放状态
            
        }else if (playerItem.status == AVPlayerItemStatusUnknown){
            NSLog(@"播放未知");
            isSuccess = NO;
            if (self.xjPlayFailBlock) {
                self.xjPlayFailBlock();
            }
        }else if (playerItem.status == AVPlayerStatusFailed){
            NSLog(@"播放失败");
            isSuccess = NO;
            if (self.xjPlayFailBlock) {
                self.xjPlayFailBlock();
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSTimeInterval timeInterval = [self xjPlayerAvailableDuration];
        CMTime duration = self.xjPlayerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        if (self.xjLoadedTimeBlock) {
            self.xjLoadedTimeBlock(timeInterval/totalDuration);
        }
    }
    
}

//视屏播放完后的通知事件。从头开始播放；
- (void)xjPlayerEndPlay:(NSNotification*)notification{
    WS(weakSelf);
    [weakSelf.xjPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (weakSelf.xjPlayEndBlock) {
            weakSelf.xjPlayEndBlock();
        }
    }];
}

#pragma mark - 屏幕方向改变的监听
//屏幕方向改变时的监听
- (void)orientChange:(NSNotification *)notification
{
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    if (self.xjDirectionChange) {
        self.xjDirectionChange(orient);
    }
}

//程序进入后台（如果播放，则暂停，否则不管）
- (void)appDidEnterBackground
{
    if (isPlayNow) {
        [self.xjPlayer pause];
    }
}

//程序进入前台（退出前播放，进来后继续播放，否则不管）
- (void)appDidEnterPlayGround
{
    if (isPlayNow) {
        [self.xjPlayer play];
    }
}

//实时监听播放状态
- (void)monitoringXjPlayerBack{
    //一秒监听一次CMTimeMake(a, b),a/b表示多少秒一次；
    WS(weakSelf);
    self.playbackTimeObserver = [self.xjPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = self.xjPlayerItem.currentTime.value/self.xjPlayerItem.currentTime.timescale;//获取当前时间
        if (weakSelf.xjCurrentTimeBlock) {
            weakSelf.xjCurrentTimeBlock(currentSecond);
        }
    }];
}

//刷新，看播放是否卡顿
//- (void)upadte
//{
//    NSTimeInterval current = CMTimeGetSeconds(self.xjPlayer.currentTime);
//    if (current == self.lastTime) {
//        //卡顿
//        if (self.xjDelayPlay) {
//            self.xjDelayPlay(YES);
//        }
//    }else{//没有卡顿
//        if (self.xjDelayPlay) {
//            self.xjDelayPlay(NO);
//        }
//    }
//    self.lastTime = current;
//}

#pragma mark - **************************** 自定义方法 **********************************
//计算缓冲区
- (NSTimeInterval)xjPlayerAvailableDuration{
    NSArray *loadedTimeRanges = [[self.xjPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds+durationSeconds;//计算缓冲进度
    return result;
}

//判断是否存在已下载好的文件
- (void)fileExistsAtPath:(NSString *)url{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:url]) {
        self.filePath = [NSURL fileURLWithPath:url];
        NSLog(@"filePath:%@",self.filePath);
    }else{
        self.filePath = [NSURL URLWithString:url];
        NSLog(@"没有本地文件");
    }
    
}

#pragma mark - **************************** 懒加载 *************************************
- (void)setXjPlayerUrl:(NSString *)xjPlayerUrl{
    _xjPlayerUrl = xjPlayerUrl;
    [self xjPlayerInit];
}

#pragma mark - **************************** 外部接口 *************************************
- (void)xjPlay{
    [self.xjPlayer play];
    isPlayNow = YES;
//    if (!self.link) {
//        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(upadte)];//和屏幕频率刷新相同的定时器
//        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    }
}

- (void)xjPause{
    isPlayNow = NO;
//    if (self.link) {
//        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//        self.link = nil;
//    }
    [self.xjPlayer pause];
}

/**
 * 取得当前播放时间
 *
 */
- (CGFloat)xjCurrentTime {
    return CMTimeGetSeconds([self.xjPlayer currentTime]);
}

/**
 * 取得媒体总时长
 *
 */
- (CGFloat)xjTotalTime {
    return CMTimeGetSeconds(self.xjPlayer.currentItem.duration);
}

/**
 *  当前播放进度
 *
 */
- (CGFloat)xjCurrentRate{
    CMTime ctime =  [self.xjPlayer currentTime];
    if (isSuccess) {
        return ctime.value / ctime.timescale / CMTimeGetSeconds(self.xjPlayer.currentItem.duration);
    }else{
        return 0;
    }
}

- (void)xjStop{
    //开启锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self xjRemoveObserver];
    [self.xjPlayer pause];
    isPlayNow = NO;
    [self.xjPlayer setRate:0];
    [self.xjPlayer replaceCurrentItemWithPlayerItem:nil];
    self.xjPlayerItem = nil;
    self.xjPlayer = nil;
    if (self.xjPlayerStop) {
        self.xjPlayerStop();
    }
    
    [UIDevice setOrientation:UIInterfaceOrientationPortrait];
}

- (void)xjRemoveObserver{
//    if (self.link) {
//        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//        self.link = nil;
//    }
    [self.xjPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.xjPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.xjPlayer removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)xjSeekToTimeWithSeconds:(float)seconds{
    [self.xjPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

@end
