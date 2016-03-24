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
@property (nonatomic, readonly        ) NSUInteger   currentIndex;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

- (void)setHeaderView:(UIView *)headerView defaultHeight:(CGFloat)defaultHeight minHeight:(CGFloat)minHeight;
- (void)setParentViewController:(UIViewController *)parentViewController childViewControllers:(NSArray <UIViewController <XCLPageViewProtocol> *> *)childViewControllers;

- (void)setIndex:(NSUInteger)index;

@end
