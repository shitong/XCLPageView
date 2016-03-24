//
//  CodeDemoViewController.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/23.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "CodeDemoViewController.h"
#import "DemoTableViewController.h"
#import "XCLPageView.h"

@interface CodeDemoViewController () <XCLPageViewDelegate>

@property (nonatomic, strong) UIView             *headerView;
@property (nonatomic, strong) XCLPageView        *pageView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation CodeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.segmentedControl;
    DemoTableViewController *controller1 = [[DemoTableViewController alloc] initWithItemCount:5];
    DemoTableViewController *controller2 = [[DemoTableViewController alloc] initWithItemCount:20];
    [self.pageView setParentViewController:self childViewControllers:@[controller1, controller2]];
//    [self.pageView setHeaderView:self.headerView defaultHeight:300 minHeight:0];
}

- (void)segmentedControlValueChanged:(id)sender
{
    [self.pageView setIndex:self.segmentedControl.selectedSegmentIndex];
}

#pragma mark - XCLPageViewDelegate

- (void)pageViewDidScroll:(XCLPageView *)pageView
{

}

- (void)pageView:(XCLPageView *)pageView scrollDidEndAtIndex:(NSUInteger)index
{
    self.segmentedControl.selectedSegmentIndex = index;
}

#pragma mark - getters and setters

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"first",@"second"]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

- (XCLPageView *)pageView
{
    if (!_pageView) {
        _pageView = [[XCLPageView alloc] init];
        _pageView.delegate = self;
        _pageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.pageView];
        [_pageView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_pageView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                       constant:0]];
        [_pageView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_pageView
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.bottomLayoutGuide
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0]];
        [_pageView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_pageView
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_pageView.superview
                                      attribute:NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0]];
        [_pageView.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:_pageView
                                      attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_pageView.superview
                                      attribute:NSLayoutAttributeRight
                                     multiplier:1.0f
                                       constant:0]];
    }
    
    return _pageView;
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor redColor];
    }
    
    return _headerView;
}

@end
