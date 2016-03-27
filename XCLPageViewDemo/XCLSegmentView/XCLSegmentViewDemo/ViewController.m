//
//  ViewController.m
//  XCLSegmentViewDemo
//
//  Created by stone on 16/3/25.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "ViewController.h"
#import "XCLSegmentView.h"

@interface ViewController () <XCLSegmentViewDelegate>

@property (weak, nonatomic) IBOutlet XCLSegmentView *segmentView1;
@property (weak, nonatomic) IBOutlet XCLSegmentView *segmentView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.segmentView1 setTitles:@[@"1", @"2", @"3"]];
    
    self.segmentView1.delegate = self;
    self.segmentView1.enableGradualColor = YES;
    self.segmentView1.font = [UIFont systemFontOfSize:30];
    self.segmentView1.normalColor = [UIColor blueColor];
    self.segmentView1.selectedColor = [UIColor redColor];
    self.segmentView1.indicator.backgroundColor = self.segmentView1.selectedColor;
    self.segmentView1.indicatorEdgeInsets = UIEdgeInsetsMake(self.segmentView1.bounds.size.height - 4, 10, 0, 10);
    
    [self.segmentView2 setTitles:@[@"A", @"B", @"C", @"D"]];
    self.segmentView2.delegate = self;
    self.segmentView2.enableIndicatorAnimated = NO;
    self.segmentView2.font = [UIFont systemFontOfSize:14];
    self.segmentView2.normalColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.segmentView2.selectedColor = [UIColor whiteColor];
    self.segmentView2.indicator.backgroundColor = self.segmentView2.normalColor;
    self.segmentView2.layer.borderColor = self.segmentView2.normalColor.CGColor;
    self.segmentView2.layer.borderWidth = 1;
    self.segmentView2.layer.cornerRadius = 4;
    
    for (NSInteger i = 0; i < self.segmentView2.titles.count; ++i) {
        UIButton *button = [self.segmentView2 buttonAtIndex:i];
        button.layer.borderColor = self.segmentView2.normalColor.CGColor;
        button.layer.borderWidth = 0.5;
    }
}

- (IBAction)onChanged:(UISlider *)slider
{
    self.segmentView1.indicatorPosition = slider.value;
    self.segmentView2.indicatorPosition = slider.value;
}

#pragma mark - XCLSegmentViewDelegate

- (void)segmentView:(XCLSegmentView *)segmentView clickedAtIndex:(NSUInteger)index
{
    NSLog(@"clickedAtIndex : %@", @(index));
}

@end
