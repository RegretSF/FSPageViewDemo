//
//  FSPageContentView.m
//  FSPageViewDemo
//
//  Created by Fat brother on 2019/5/12.
//  Copyright © 2019 Fat brother. All rights reserved.
//

#import "FSPageContentView.h"

@interface FSPageContentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**
 外部传进来的子控制器数组
 */
@property(nonatomic,strong) NSArray *childVCs;
/**
 外部传进来的父类控制器
 */
@property(nonatomic,weak) UIViewController *parentViewController;
/**
 UICollectionView
 */
@property(nonatomic,strong) UICollectionView *collectionView;
@end

@implementation FSPageContentView {
    CGFloat startOffsetX;
    BOOL isForbidScrollDelegate;
}
//***********************************cellID***************************************//
static NSString * const UICollectionViewCellID = @"UICollectionViewCellID";
//********************************************************************************//
#pragma mark 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        //1、1.创建layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = self.frame.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        //2、创建collectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollsToTop = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:UICollectionViewCellID];
        _collectionView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
    }
    return _collectionView;
}

#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentViewController:(UIViewController *)parentViewController {
    self = [super initWithFrame:frame];
    if (self) {
        //0、保存外部传进来的值;
        self.childVCs = childVCs;
        self.parentViewController = parentViewController;
        
        //1、初始化一些值
        startOffsetX = 0;
        isForbidScrollDelegate = NO;
        
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
    //1.将所有的子控制器添加到父类控制器中
    for (UIViewController *childVC in self.childVCs) {
        [self.parentViewController addChildViewController:childVC];
    }
    
    //2.添加UICollectionView
    self.collectionView.frame = self.bounds;
    [self addSubview:self.collectionView];
}

#pragma mark UICollectionViewDataSource / UICollectionViewDelegate
//设置组内行数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.childVCs.count;
}

//细化单元格
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //1、创建cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UICollectionViewCellID forIndexPath:indexPath];
    
    //2.给cell设置内容
    //防止循环利用cell时多次添加 childVC.view ，所以在添加childVC.view之前先把之前缓存的视图给移除
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UIViewController *childVC = self.childVCs[indexPath.item];
    childVC.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:childVC.view];
    
    return cell;
}

//开始滑动时
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isForbidScrollDelegate = NO;
    
    startOffsetX = scrollView.contentOffset.x;
}

//监听滚动的变化
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    //0.判断是否是点击事件
    if (isForbidScrollDelegate == YES) { return; }
    
    //1.获取需要的数据
    CGFloat progress = 0;
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;
    
    //2.判断左滑还是右滑
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    if (currentOffsetX > startOffsetX) {    //左滑
        //1.计算progress,floor是取整的意思
        CGFloat ratio = currentOffsetX / scrollViewW;
        progress = ratio - floor(ratio);
        
        //2.计算sourceIndex
        sourceIndex = (NSInteger)ratio;
        
        //3.计算targetIndex
        targetIndex = sourceIndex + 1;
        if (targetIndex >= self.childVCs.count) {
            targetIndex = self.childVCs.count - 1;
            progress = 1;
        }
        
        //4.如果完全滑过去
        if ((currentOffsetX - startOffsetX) == scrollViewW) {
            progress = 1;
            targetIndex = sourceIndex;
        }
        
    }else {                                 //右滑
        //1.计算progress
        CGFloat ratio = currentOffsetX / scrollViewW;
        progress = 1 - (ratio - floor(ratio));
        
        //2.计算targetIndex
        targetIndex = (NSInteger)ratio;
        
        //3.计算sourceIndex
        sourceIndex = targetIndex + 1;
        if (sourceIndex >= self.childVCs.count) {
            sourceIndex = self.childVCs.count - 1;
        }
    }
    
    //3.将progress/targetIndex/sourceIndex传递给titleView
    if ([self.delegate respondsToSelector:@selector(pageContentView:progress:sourceIndex:targetIndex:)]) {
        [self.delegate pageContentView:self progress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    }
}

#pragma mark 对外暴露的方法
- (void)setCurrentIndex:(NSInteger)index {
    //1.记录需要禁止执行的代理方法
    isForbidScrollDelegate = YES;
    
    //2、滚动到正确的位置
    CGFloat offsetX = index * self.collectionView.frame.size.width;
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0)];
}
@end
