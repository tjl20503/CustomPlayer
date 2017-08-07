//
//  XJAVPlyer.h
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJAVPlyer : UIView

#pragma mark - **************************** 外部接口 *************************************
/**
 *  视屏链接
 */
@property (nonatomic, strong) NSString *xjPlayerUrl;
/**
 *  播放
 */
- (void)xjPlay;
/**
 *  暂停
 */
- (void)xjPause;
/**
 *  关闭播放器
 */
- (void)xjStop;

/**
 * 定位视频播放时间
 *
 */
- (void)xjSeekToTimeWithSeconds:(float)seconds;

/**
 * 取得当前播放时间
 *
 */
- (CGFloat)xjCurrentTime;
/**
 * 取得媒体总时长
 *
 */
- (CGFloat)xjTotalTime;
/**
 *  当前播放进度
 *
 */
- (CGFloat)xjCurrentRate;
/**
 *  播放成功回调
 */
@property (nonatomic, copy)void (^xjPlaySuccessBlock)();
/**
 *  播放失败回调
 */
@property (nonatomic, copy)void (^xjPlayFailBlock)();
/**
 *  取得加载进度
 */
@property (nonatomic, copy)void (^xjLoadedTimeBlock)(CGFloat time);
/**
 * 取得当前播放时间(回调，刷新时间栏)
 *
 */
@property (nonatomic, copy)void (^xjCurrentTimeBlock)(CGFloat time);
/**
 * 取得媒体总时长（为了回调）
 *
 */
@property (nonatomic, copy)void (^xjTotalTimeBlock)(CGFloat time);
/**
 *  播放完
 */
@property (nonatomic, copy)void (^xjPlayEndBlock)();
/**
 *  播放器关闭回调
 */
@property (nonatomic, copy)void (^xjPlayerStop)();
/**
 *  方向改变
 */
@property (nonatomic, copy)void (^xjDirectionChange)(UIDeviceOrientation orient);
/**
 *  播放是否延迟
 */
@property (nonatomic, copy)void (^xjDelayPlay)(BOOL flag);

@end
