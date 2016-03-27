# XCLPageView

## Screenshots
---------
![image](https://github.com/shitong/XCLPageView/blob/master/Screenshots/Screenshots0) 

## 用法
---------
```objc

DemoTableViewController *controller1 = [[DemoTableViewController alloc] initWithItemCount:4];
DemoTableViewController *controller2 = [[DemoTableViewController alloc] initWithItemCount:20];
[self.pageView setParentViewController:self childViewControllers:@[controller1, controller2]];

// 如果需要可以设置headerView，并指定高度，minHeight如果不为0，则在想上滚动时，headerView底部会保留最小高度
[self.pageView setHeaderView:[[UIView alloc] init] defaultHeight:200 minHeight:50];

```
