//
//  RootTableViewController.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/23.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "RootTableViewController.h"
#import "XIBDemoViewController.h"
#import "CodeDemoViewController.h"

@interface RootTableViewController ()

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PageView Demo";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            CodeDemoViewController *controller = [[CodeDemoViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
