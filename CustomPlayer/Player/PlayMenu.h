//
//  PlayMenu.h
//  Player
//
//  Created by Future on 2017/8/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayMenu : UIView

@property (nonatomic, assign)CGFloat xjTotalTime;
@property (nonatomic, assign)CGFloat xjCurrentTime;
@property (nonatomic, assign)CGFloat xjLoadedTimeRanges;
@property (nonatomic, assign)BOOL xjPlay;//双击时的播放暂停
@property (readwrite)BOOL xjFull;
@property (nonatomic, assign)BOOL xjPlayEnd;

/**
 *  播放/暂停
 */
@property (nonatomic, copy)void (^xjPlayOrPauseBlock)(BOOL flag);

/**
 *  滑动条滑动时
 */
@property (nonatomic, copy)void (^xjSliderValueChangeBlock)(CGFloat value);

/**
 *  滑动条滑动完成
 */
@property (nonatomic, copy)void (^xjSliderValueChangeEndBlock)(CGFloat value);

/**
 *  放大/缩小
 */
@property (nonatomic, copy)void (^xjFullOrSmallBlock)(BOOL flag);

@end
