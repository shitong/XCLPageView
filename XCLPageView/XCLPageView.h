//
//  XCLPageView.h
//  XCLPageViewDemo
//
//  Created by stone on 16/3/19.
//  Copyright © 2016年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCLPageViewProtocol <NSObject>
- (UITableView *)tableView;
@end

@class XCLPageView;
@protocol XCLPageViewDelegate <NSObject>
@optional
- (void)pageViewDidScroll:(XCLPageView *)pageView;
- (void)pageView:(XCLPageView *)pageView scrollDidEndAtIndex:(NSUInteger)index;
@end

@interface XCLPageView : UIView

@property (nonatomic, weak) id<XCLPageViewDelegate>  delegate;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly        ) NSUInteger   currentIndex;

- (void)setParentViewController:(UIViewController *)parentViewController childViewControllers:(NSArray <UIViewController *> *)childViewControllers;

// 必须在setParentViewController:childViewControllers:之后调用
// 如果设置headerView，则childViewControllers中所有controller必须实现XCLPageViewProtocol
- (void)setHeaderView:(UIView *)headerView defaultHeight:(CGFloat)defaultHeight minHeight:(CGFloat)minHeight;

- (void)setIndex:(NSUInteger)index;

@end
