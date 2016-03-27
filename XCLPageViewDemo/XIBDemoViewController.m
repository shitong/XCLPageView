//
//  XIBDemoViewController.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/22.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "XIBDemoViewController.h"
#import "DemoTableViewController.h"
#import "XIBHeaderView.h"

#import "XCLPageView.h"
#import "XCLSegmentView.h"

@interface XIBDemoViewController () <XCLPageViewDelegate, XCLSegmentViewDelegate>

@property (weak  , nonatomic) IBOutlet XCLPageView *pageView;
@property (strong, nonatomic) XIBHeaderView *headerView;

@end

@implementation XIBDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    DemoTableViewController *controller1 = [[DemoTableViewController alloc] initWithItemCount:30];
    DemoTableViewController *controller2 = [[DemoTableViewController alloc] initWithItemCount:100];
    
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XIBHeaderView class]) owner:self options:nil] firstObject];
    
    
    [self.headerView.segmentView setTitles:@[@"First", @"Second"]];
    self.headerView.segmentView.delegate = self;
    self.headerView.segmentView.font = [UIFont systemFontOfSize:14];
    self.headerView.segmentView.normalColor = [UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0];
    self.headerView.segmentView.selectedColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.headerView.segmentView.indicator.backgroundColor = self.headerView.segmentView.selectedColor;
    self.headerView.segmentView.indicatorEdgeInsets = UIEdgeInsetsMake(self.headerView.segmentView.bounds.size.height - 2, 10, 0, 10);
    self.headerView.segmentView.selectedSegmentIndex = 1;
    
    self.pageView.delegate = self;
    [self.pageView setParentViewController:self childViewControllers:@[controller1, controller2]];
    [self.pageView setHeaderView:self.headerView defaultHeight:200 minHeight:self.headerView.segmentView.bounds.size.height];
    [self.pageView setIndex:1];
}

#pragma mark - XCLSegmentViewDelegate

- (void)segmentView:(XCLSegmentView *)segmentView clickedAtIndex:(NSUInteger)index
{
    [self.pageView setIndex:index];
}

#pragma mark - XCLPageViewDelegate

- (void)pageViewDidScroll:(XCLPageView *)pageView
{
    CGFloat pageWidth = pageView.scrollView.contentSize.width/self.headerView.segmentView.titles.count;
    self.headerView.segmentView.indicatorPosition = pageView.scrollView.contentOffset.x / (pageWidth * (self.headerView.segmentView.titles.count - 1));
}

- (void)pageView:(XCLPageView *)pageView scrollDidEndAtIndex:(NSUInteger)index
{
    self.headerView.segmentView.selectedSegmentIndex = index;
}

@end
