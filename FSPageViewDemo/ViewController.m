//
//  ViewController.m
//  FSPageViewDemo
//
//  Created by Fat brother on 2019/5/12.
//  Copyright © 2019 Fat brother. All rights reserved.
//

#import "ViewController.h"
#import "FSPageTitleView.h"
#import "FSPageContentView.h"

#define FSScreenW [UIScreen mainScreen].bounds.size.width   //屏幕的宽度
#define FSScreenH [UIScreen mainScreen].bounds.size.height   //屏幕的高度
#define FSStatusBarH [UIApplication sharedApplication].statusBarFrame.size.height  //状态栏的高度

@interface ViewController () <FSPageTitleViewDelegate, FSPageContentViewDelegate>
/**
 标题视图
 */
@property(nonatomic,strong) FSPageTitleView *pageTitleView;
/**
 内容视图
 */
@property(nonatomic,strong) FSPageContentView *pageContentView;
@end

@implementation ViewController {
    CGFloat navigationBarH; //导航栏高度
    CGFloat tabBarH;        //标签栏高度
}
#pragma mark 懒加载
- (FSPageContentView *)pageContentView {
    if (!_pageContentView) {
        //1.设置contentFrame
        CGFloat y = CGRectGetMaxY(self.pageTitleView.frame);
        CGFloat h = FSScreenH - (y + tabBarH);
        CGRect frame = CGRectMake(0, y, FSScreenW, h);
        
        //2.确定所有的子控制器
        NSMutableArray *childVCs = [NSMutableArray array];
        for (int i=0; i<4; i++) {
            UIViewController *childVC = [[UIViewController alloc] init];
            childVC.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
            [childVCs addObject:childVC];
        }
        
        //3、创建pageContentView
        _pageContentView = [[FSPageContentView alloc] initWithFrame:frame childVCs:childVCs parentViewController:self];
        _pageContentView.delegate = self;
    }
    return _pageContentView;
}

- (FSPageTitleView *)pageTitleView {
    if (!_pageTitleView) {
        //1、设置标题视图的尺寸
        CGRect frame = CGRectMake(0, FSStatusBarH + navigationBarH, FSScreenW, 40);
        
        //2、设置标题数组
        NSArray *titles = [NSArray arrayWithObjects:@"标题一", @"标题二", @"标题三", @"标题四", nil];
        
        //3、创建标题视图
        _pageTitleView = [[FSPageTitleView alloc] initWithFrame:frame titles:titles];
        _pageTitleView.delegate = self;
    }
    
    return _pageTitleView;
}

#pragma mark 系统回调函数
- (void)viewDidLoad {
    [super viewDidLoad];
    //0.获取导航栏的高度和标签栏的高度
    navigationBarH = self.navigationController.navigationBar.frame.size.height;
    tabBarH = self.tabBarController.tabBar.frame.size.height;
    
    //1、添加子视图
    [self addSubviews];
    
}

#pragma mark 设置UI界面
/**
 添加子视图
 */
- (void)addSubviews {
    //1.添加标题视图
    [self.view addSubview:self.pageTitleView];
    
    //2.添加contentView
    [self.view addSubview:self.pageContentView];
}

#pragma mark FSPageTitleViewDelegate / FSPageContentViewDelegate
-(void)pageTitleView:(FSPageTitleView *)pageTitleView selectedIndex:(NSInteger)index {
    [self.pageContentView setCurrentIndex:index];
}

-(void)pageContentView:(FSPageContentView *)pageContentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
}

@end
