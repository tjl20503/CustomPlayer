//
//  ViewController.m
//  CustomPlayer
//
//  Created by Future on 2017/8/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

#import "ViewController.h"
#import "XjAVPlayerSDK.h"


@interface ViewController ()
{
    XjAVPlayerSDK *myPlayer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ self player1];
}

- (void)player1
{
    WS(weakSelf);
    myPlayer = [[XjAVPlayerSDK alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    myPlayer.xjAutoOrient = YES;
    //    myPlayer.XjAVPlayerSDKDelegate = self;
    myPlayer.IsfullBlock = ^(BOOL tag) {
        weakSelf.navigationController.navigationBarHidden = tag;
    };
    myPlayer.xjPlayerUrl = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    [self.view addSubview:myPlayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
