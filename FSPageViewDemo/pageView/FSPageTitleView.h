//
//  FSPageTitleView.h
//  FSPageViewDemo
//
//  Created by Fat brother on 2019/5/12.
//  Copyright © 2019 Fat brother. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FSPageTitleView;
@protocol FSPageTitleViewDelegate <NSObject>

- (void)pageTitleView:(FSPageTitleView *)pageTitleView selectedIndex:(NSInteger)index;

@end

/**
 标题视图
 */
@interface FSPageTitleView : UIView
@property(nonatomic,weak) id <FSPageTitleViewDelegate>delegate;

/**
 重载初始化方法

 @param frame 视图的尺寸
 @param titles 标题数组
 @return 返回self
 */
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;

/**
 对外暴露的方法

 @param progress 进度
 @param sourceIndex 原来索引
 @param targetIndex 目标索引
 */
- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex;
@end

NS_ASSUME_NONNULL_END
