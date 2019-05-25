//
//  FSPageTitleView.m
//  FSPageViewDemo
//
//  Created by Fat brother on 2019/5/12.
//  Copyright © 2019 Fat brother. All rights reserved.
//

#import "FSPageTitleView.h"

/**
 *  颜色r.g.b方法
 */
#define FSRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface FSPageTitleView ()
/**
 用来存放外部传进来的标题数组
 */
@property(nonatomic,strong) NSArray *titles;
/**
 滚动视图
 */
@property(nonatomic,strong) UIScrollView *scrollView;
/**
 用来存放UILabel的数组
 */
@property(nonatomic,strong) NSMutableArray *titleLabels;
/**
 滚动的滑块
 */
@property(nonatomic,strong) UIView *scrollLine;
@end

@implementation FSPageTitleView {
    CGFloat scrollLineH;    //滑块的高度
    NSInteger currentIndex;
    
}
//颜色rgb的值
float normalColor[3] = {85, 85, 85};
float selectColor[3] = {255, 128, 0};

#pragma mark 懒加载
- (UIView *)scrollLine {
    if (!_scrollLine) {
        _scrollLine = [[UIView alloc] init];
        _scrollLine.backgroundColor = FSRGBColor(selectColor[0], selectColor[1], selectColor[2]);
    }
    return _scrollLine;
}

- (NSMutableArray *)titleLabels {
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        //0、保存外部传进来的值;
        self.titles = titles;
        
        //1、初始化一些值
        scrollLineH = 2;
        currentIndex = 0;
        
        //2、添加子视图
        [self addSubviews];
    }
    
    return self;
}

#pragma mark 设置UI界面
/**
 添加子视图
 */
- (void)addSubviews {
    //1、添加scrollView
    [self addSubview:self.scrollView];
    self.scrollView.frame = self.bounds;
    
    //2、添加title对应的label
    [self addTitleLabels];
    
    //3、设置底线和滚动的滑块
    [self addBottomLineAndScrollLine];
}

/**
 添加title对应的label
 */
- (void)addTitleLabels {
    //0.确定label的一些frame的值
    CGFloat labelW = self.frame.size.width / self.titles.count;
    CGFloat labelH = self.frame.size.height - scrollLineH;
    CGFloat labelY = 0;
    
    for (int i=0; i<self.titles.count; i++) {
        
        //1、创建UILabel
        UILabel *label = [[UILabel alloc] init];
        
        //2、设置label的一些属性
        label.text = self.titles[i];
        label.tag = i;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = FSRGBColor(normalColor[0], normalColor[1], normalColor[2]);
        
        //3、设置label的frame
        CGFloat labelX = labelW * i;
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        //4、将label添加到scrollView
        [self.scrollView addSubview:label];
        
        //5、给label添加手势
        //打开用户交互功能
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelClick:)];
        [label addGestureRecognizer:tapGes];
        
        //将UILabel添加到数组
        [self.titleLabels addObject:label];
    }
}

/**
 添加底线和滑动的滑块
 */
- (void)addBottomLineAndScrollLine {
    //1.添加底线
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    CGFloat bottomLineH = 0.5;
    bottomLine.frame = CGRectMake(0, self.frame.size.height - bottomLineH, self.frame.size.width, bottomLineH);
    [self addSubview:bottomLine];
    
    //2.添加scrollLine
    //2.1获取第一个Label
    if (!self.titleLabels) { return; }
    UILabel *firstLabel = [self.titleLabels firstObject];
    firstLabel.textColor = FSRGBColor(selectColor[0], selectColor[1], selectColor[2]);
    CGFloat scrollLineX = firstLabel.frame.origin.x;
    CGFloat scrollLineY = self.frame.size.height - scrollLineH;
    CGFloat scrollLineW = firstLabel.frame.size.width;
    self.scrollLine.frame = CGRectMake(scrollLineX, scrollLineY, scrollLineW, scrollLineH);
    [self.scrollView addSubview:self.scrollLine];
    
}

#pragma mark 监听事件
/**
 监听Label的点击
 */
- (void)titleLabelClick:(UITapGestureRecognizer *)tapGes {
    //1.获取当前label
    UILabel *currentLabel = (UILabel *)tapGes.view;
    
    //2.获取之前的label
    UILabel *oldLabel = self.titleLabels[currentIndex];
    
    //3.切换文字的颜色
    if (currentLabel.tag != oldLabel.tag) {
        currentLabel.textColor = FSRGBColor(selectColor[0], selectColor[1], selectColor[2]);
        oldLabel.textColor = FSRGBColor(normalColor[0], normalColor[1], normalColor[2]);
    }else {
        oldLabel.textColor = FSRGBColor(selectColor[0], selectColor[1], selectColor[2]);
    }
    
    //4.保存最新Label的下标值
    currentIndex = currentLabel.tag;
    
    //5.滚动条位置发生改变
    CGFloat scrollLineX = currentIndex * self.scrollLine.frame.size.width;
    CGRect tempFrame = self.scrollLine.frame;
    tempFrame.origin.x = scrollLineX;
    [UIView animateWithDuration:0.15 animations:^{
        self.scrollLine.frame = tempFrame;
    }];
    
    //6.通知代理
    if ([self.delegate respondsToSelector:@selector(pageTitleView:selectedIndex:)]) {
        [self.delegate pageTitleView:self selectedIndex:currentIndex];
    }
}

#pragma mark 对外暴露的方法
- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    //1.取出sourceLabel/targetLabel
    UILabel *sourceLabel = self.titleLabels[sourceIndex];
    UILabel *targetLabel = self.titleLabels[targetIndex];
    
    //2.处理滑块的逻辑
    CGFloat moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x;
    CGFloat moveX = moveTotalX * progress;
    CGRect tempFrame = self.scrollLine.frame;
    tempFrame.origin.x = sourceLabel.frame.origin.x + moveX;
    self.scrollLine.frame = tempFrame;
    
    //3.颜色的渐变(复杂)
    //3.1取出颜色变化的范围
    float colorDelta[3] = {selectColor[0] - normalColor[0], selectColor[1] - normalColor[1], selectColor[2] - normalColor[2]};
    
    //3.2变化sourceLabel.textColor
    sourceLabel.textColor = FSRGBColor(selectColor[0] - colorDelta[0] * progress, selectColor[1] - colorDelta[1] * progress, selectColor[2] - colorDelta[2] * progress);
    
    //3.2变化targetLabel.textColor
    targetLabel.textColor = FSRGBColor(normalColor[0] + colorDelta[0] * progress, normalColor[1] + colorDelta[1] * progress, normalColor[2] + colorDelta[2] * progress);
    
    //4.记录最新的index
    currentIndex = targetLabel.tag;
    
}

@end
