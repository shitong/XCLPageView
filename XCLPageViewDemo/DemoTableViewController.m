//
//  DemoTableViewController.m
//  XCLPageViewDemo
//
//  Created by stone on 16/3/19.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "DemoTableViewController.h"

@interface DemoTableViewController ()

@property (nonatomic, assign) NSUInteger itemCount;

@end

@implementation DemoTableViewController

- (instancetype)initWithItemCount:(NSUInteger)itemCount
{
    self = [super init];
    if (self) {
        _itemCount = itemCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [@(indexPath.row) stringValue];
    
    return cell;
}

@end
