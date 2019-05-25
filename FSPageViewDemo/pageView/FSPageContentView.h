//
//  FSPageContentView.h
//  FSPageViewDemo
//
//  Created by Fat brother on 2019/5/12.
//  Copyright © 2019 Fat brother. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FSPageContentView;
@protocol FSPageContentViewDelegate <NSObject>

- (void)pageContentView:(FSPageContentView *)pageContentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex;

@end

/**
 内容视图
 */
@interface FSPageContentView : UIView

@property(nonatomic,weak) id <FSPageContentViewDelegate>delegate;

/**
 重载初始化方法

 @param frame 视图的尺寸
 @param childVCs 装子控制器的数组
 @param parentViewController 传进来父控制器
 @return 返回self
 */
-(instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentViewController:(UIViewController *)parentViewController;

/**
 对外暴露的方法

 @param currentIndex  外部传进来的索引
 */
- (void)setCurrentIndex:(NSInteger)currentIndex;
@end

NS_ASSUME_NONNULL_END
