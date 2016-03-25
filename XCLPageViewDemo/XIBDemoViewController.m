//
//  XIBDemoViewController.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/22.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "XIBDemoViewController.h"
#import "XCLPageView.h"

#import "DemoTableViewController.h"
#import "XIBHeaderView.h"

@interface XIBDemoViewController () <XCLPageViewDelegate>


@property (weak  , nonatomic) IBOutlet XCLPageView *pageView;
@property (strong, nonatomic) XIBHeaderView *headerView;

@end

@implementation XIBDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    DemoTableViewController *controller1 = [[DemoTableViewController alloc] initWithItemCount:30];
    DemoTableViewController *controller2 = [[DemoTableViewController alloc] initWithItemCount:100];
    
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XIBHeaderView class]) owner:self options:nil] firstObject];
    [self.headerView.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.pageView.delegate = self;
    [self.pageView setParentViewController:self childViewControllers:@[controller1, controller2]];
    [self.pageView setHeaderView:self.headerView defaultHeight:200 minHeight:50];
    [self.pageView setIndex:1];
    self.headerView.segmentedControl.selectedSegmentIndex = 1;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAdd)];
}



//- (void)onAdd
//{
//    UIViewController *controller = [[UIViewController alloc] init];
////    [self presentViewController:controller animated:YES completion:nil];
//    [self.navigationController pushViewController:controller animated:YES];
//}

- (void)segmentedControlValueChanged:(id)sender
{
    [self.pageView setIndex:self.headerView.segmentedControl.selectedSegmentIndex];
}

#pragma mark - XCLPageViewDelegate

- (void)pageViewDidScroll:(XCLPageView *)pageView
{
    NSLog(@"%s x: %@", __FUNCTION__, @(pageView.scrollView.contentOffset.x));
}

- (void)pageView:(XCLPageView *)pageView scrollDidEndAtIndex:(NSUInteger)index
{
    NSLog(@"%s index: %@", __FUNCTION__, @(index));
    self.headerView.segmentedControl.selectedSegmentIndex = index;
}

@end
