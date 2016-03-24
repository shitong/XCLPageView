//
//  XCLPageView.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/19.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "XCLPageView.h"

@interface XCLTableHeaderView : UIView
@end

@implementation XCLTableHeaderView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL ret = [super pointInside:point withEvent:event];
    if (!ret) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                ret = YES;
            }
        }
    }
    
    return ret;
}

@end

@interface XCLPageView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView       *scrollView;
@property (nonatomic, strong) UIView             *headerView;
@property (nonatomic, strong) NSMutableArray     *headerViewConstraints;
@property (nonatomic, strong) NSLayoutConstraint *headerViewHeightConttraint;
@property (nonatomic, strong) NSLayoutConstraint *headerViewTopConttraint;
@property (nonatomic        ) BOOL               headerViewLastUserInteractionEnabled;

@property (nonatomic, weak  ) UIViewController   *parentViewController;
@property (nonatomic, strong) NSArray            *childViewControllers;

@property (nonatomic        ) CGFloat            headerViewDefaultHeight;
@property (nonatomic        ) CGFloat            headerViewMinHeight;
@property (nonatomic        ) NSUInteger         currentIndex;

@end

@implementation XCLPageView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_init];
    }
    return self;
}

- (void)awakeFromNib
{
    [self pri_init];
}

- (void)pri_init
{
    self.clipsToBounds = YES;
    _currentIndex = 0;
}

- (void)dealloc
{
    for (UIViewController <XCLPageViewProtocol> *controller in self.childViewControllers) {
        [controller.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)layoutSubviews
{
    NSLog(@"%s", __FUNCTION__);
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat x = self.currentIndex * width;
    if (x != self.scrollView.contentOffset.x && !self.scrollView.isDragging && !self.scrollView.isDecelerating) {
        [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    }
    
    // 旋转屏幕时会触发tableView的contentOffset的变化，这里需要重新计算一下约束，否则headerView位置可能不对
    [self reloadHeaderViewTopConttraint];
}

#pragma mark - publish methods

- (void)setHeaderView:(UIView *)headerView
        defaultHeight:(CGFloat)defaultHeight
            minHeight:(CGFloat)minHeight
{
    self.headerView                                           = headerView;
    self.headerViewDefaultHeight                              = defaultHeight;
    self.headerViewMinHeight                                  = minHeight;
    self.headerViewLastUserInteractionEnabled                 = headerView.userInteractionEnabled;
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setHeaderViewIfNeeded];
}



- (void)setParentViewController:(UIViewController *)parentViewController childViewControllers:(NSArray <UIViewController <XCLPageViewProtocol> *> *)childViewControllers
{
    self.parentViewController = parentViewController;
    self.childViewControllers = childViewControllers;
    [self addChildToParent];
    [self setHeaderViewIfNeeded];
}

- (void)setIndex:(NSUInteger)index
{
    if (index >= self.childViewControllers.count) {
        return;
    }
    
    if (index == self.currentIndex) {
        return;
    }
    
    [self reloadChildTableViewContentOffset];
    
    CGFloat width = self.bounds.size.width;
    CGFloat x = index * width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    self.currentIndex = index;
    [self addHeaderViewToChildTableHeaderView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!self.headerView) {
        return;
    }
    
    // 这里有可能已经添加到self上面了又调用，此时不再处理
    if ([self.headerView.superview isEqual:self]) {
        return;
    }
    
    CGRect frame = [self.headerView.superview convertRect:self.headerView.frame toView:self];
    [self reloadChildTableViewContentOffset];
    [self.headerView.superview removeConstraints:self.headerViewConstraints];
    // 添加到self上之后禁止响应
    self.headerViewLastUserInteractionEnabled = self.headerView.userInteractionEnabled;
    self.headerView.userInteractionEnabled = NO;
    [self addSubview:self.headerView];
    [self addHeaderViewConstraintsWithOffsetTop:frame.origin.y];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = (scrollView.contentOffset.x + scrollView.bounds.size.width/2)/scrollView.bounds.size.width;
    [self addHeaderViewToChildTableHeaderView];
    if ([self.delegate respondsToSelector:@selector(pageView:scrollDidEndAtIndex:)]) {
        [self.delegate pageView:self scrollDidEndAtIndex:self.currentIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageViewDidScroll:)]) {
        [self.delegate pageViewDidScroll:self];
    }
}

#pragma mark - event response

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%s", __FUNCTION__);
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    [self reloadHeaderViewTopConttraint];
}

#pragma mark - private methods

- (void)addChildToParent
{
    self.parentViewController.automaticallyAdjustsScrollViewInsets = NO;
    
    UIView *lastView = nil;
    for (NSInteger i = 0; i < self.childViewControllers.count; ++i) {
        UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers[i];
        [self.parentViewController addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self.parentViewController];
        
        controller.automaticallyAdjustsScrollViewInsets = NO;
        controller.view.translatesAutoresizingMaskIntoConstraints = NO;
        [controller.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        
        [controller.view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:controller.view
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:controller.view.superview
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f
                                       constant:0]];
        
        [controller.view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:controller.view
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:controller.view.superview
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f
                                       constant:0]];
        
        [controller.view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:controller.view
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:controller.view.superview
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0]];
        [controller.view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:controller.view
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:controller.view.superview
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                       constant:0]];
        
        [controller.view.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:controller.view
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:lastView ? lastView : self.scrollView
                                      attribute:lastView ? NSLayoutAttributeRight : NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0]];
        lastView = controller.view;
        
    }
    
    UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers.lastObject;
    
    [controller.view.superview addConstraint:
     [NSLayoutConstraint constraintWithItem:controller.view
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:controller.view.superview
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1.0f
                                   constant:0]];
}

- (void)setHeaderViewIfNeeded
{
    if (!self.headerView) {
        return;
    }
    
    if (self.childViewControllers.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < self.childViewControllers.count; ++i) {
        UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers[i];
        if (!controller.tableView.tableHeaderView) {
            controller.tableView.tableHeaderView = [[XCLTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, controller.tableView.bounds.size.width, self.headerViewDefaultHeight)];
        }
    }
    
    [self addHeaderViewToChildTableHeaderView];
}

- (void)addHeaderViewToChildTableHeaderView
{
    if (!self.headerView) {
        return;
    }
    
    UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers[self.currentIndex];
    [self.headerView.superview removeConstraints:self.headerViewConstraints];
    [controller.tableView.tableHeaderView addSubview:self.headerView];
    // 恢复响应状态
    self.headerView.userInteractionEnabled = self.headerViewLastUserInteractionEnabled;
    
    CGFloat offsetTop = 0;
    if (controller.tableView.contentOffset.y > 0) {
        if (self.headerViewDefaultHeight - self.headerViewMinHeight > controller.tableView.contentOffset.y) {
            offsetTop = 0;
        } else {
            offsetTop = controller.tableView.contentOffset.y - (self.headerViewDefaultHeight - self.headerViewMinHeight);
        }
    } else {
        offsetTop = controller.tableView.contentOffset.y;
    }
    
    [self addHeaderViewConstraintsWithOffsetTop:offsetTop];
}

- (void)addHeaderViewConstraintsWithOffsetTop:(CGFloat)offsetTop
{
    if (!self.headerView) {
        return;
    }
    
    if (!self.headerViewConstraints) {
        self.headerViewConstraints = [NSMutableArray array];
    }
    
    [self.headerViewConstraints removeAllObjects];
    
    
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    [layoutAttributes addObject:@(NSLayoutAttributeLeft)];
    [layoutAttributes addObject:@(NSLayoutAttributeRight)];
    
    for (NSNumber *num in layoutAttributes) {
        [self.headerViewConstraints addObject:
         [NSLayoutConstraint constraintWithItem:self.headerView
                                      attribute:[num integerValue]
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.headerView.superview
                                      attribute:[num integerValue]
                                     multiplier:1.0f
                                       constant:0]];
    }
    
    self.headerViewTopConttraint = [NSLayoutConstraint
                                    constraintWithItem:self.headerView
                                    attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.headerView.superview
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                    constant:offsetTop];
    
    self.headerViewHeightConttraint = [NSLayoutConstraint
                                       constraintWithItem:self.headerView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:nil
                                       attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1.0f
                                       constant:self.headerViewDefaultHeight];
    [self.headerViewConstraints addObject:self.headerViewTopConttraint];
    [self.headerViewConstraints addObject:self.headerViewHeightConttraint];
    [self.headerView.superview addConstraints:self.headerViewConstraints];
    // 添加约束后需要立刻生效，否则之后计算frame的时候会不准
    [self.headerView layoutIfNeeded];
}

- (void)reloadChildTableViewContentOffset
{
    if (!self.headerView) {
        return;
    }
    
    CGPoint offset = [self.childViewControllers[self.currentIndex] tableView].contentOffset;
    for (NSInteger i = 0; i < self.childViewControllers.count; ++i) {
        UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers[i];
        if (offset.y < self.headerViewDefaultHeight - self.headerViewMinHeight) {
            if (offset.y != controller.tableView.contentOffset.y) {
                controller.tableView.contentOffset = offset;
            }
        } else {
            if (controller.tableView.contentOffset.y < self.headerViewDefaultHeight) {
                offset.y = self.headerViewDefaultHeight - self.headerViewMinHeight;
                controller.tableView.contentOffset = offset;
            }
        }
    }
}

- (void)reloadHeaderViewTopConttraint
{
    if (!self.headerView) {
        return;
    }
    
    // 如果headerView在self上，则不需要更新约束
    if ([self.headerView.superview isEqual:self]) {
        return;
    }
    
    UIViewController <XCLPageViewProtocol> *controller = self.childViewControllers[self.currentIndex];
    CGPoint offset = [controller tableView].contentOffset;
    if (offset.y > 0) {
        if (self.headerViewDefaultHeight - self.headerViewMinHeight > offset.y) {
            self.headerViewTopConttraint.constant = 0;
        } else {
            self.headerViewTopConttraint.constant = offset.y - (self.headerViewDefaultHeight - self.headerViewMinHeight);
        }
        self.headerViewHeightConttraint.constant = self.headerViewDefaultHeight;
        
    } else {
        self.headerViewTopConttraint.constant = offset.y;
        self.headerViewHeightConttraint.constant = self.headerViewDefaultHeight - offset.y;
    }
}

#pragma mark - getters and setters

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [_scrollView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_scrollView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_scrollView.superview
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0]];
        [_scrollView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_scrollView
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_scrollView.superview
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                       constant:0]];
        [_scrollView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_scrollView
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_scrollView.superview
                                      attribute:NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0]];
        [_scrollView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_scrollView
                                      attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_scrollView.superview
                                      attribute:NSLayoutAttributeRight
                                     multiplier:1.0f
                                       constant:0]];
        
    }
    
    return _scrollView;
}

@end
