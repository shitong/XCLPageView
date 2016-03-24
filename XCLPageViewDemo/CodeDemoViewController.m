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

@interface CodeDemoViewController ()

@end

@implementation CodeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XCLPageView *pageView = [[XCLPageView alloc] init];
    pageView.frame = self.view.bounds;
    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:pageView];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor redColor];
    
    DemoTableViewController *controller1 = [[DemoTableViewController alloc] initWithItemCount:20];
    DemoTableViewController *controller2 = [[DemoTableViewController alloc] initWithItemCount:20];
    
    [pageView setParentViewController:self childViewControllers:@[controller1, controller2]];
    [pageView setHeaderView:headerView defaultHeight:300 minHeight:0];
    
}

@end
