//
//  XCLSegmentView.h
//  XCLSegmentViewDemo
//
//  Created by stone on 16/3/25.
//  Copyright © 2016年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCLSegmentView;
@protocol XCLSegmentViewDelegate <NSObject>
- (void)segmentView:(XCLSegmentView *)segmentView clickedAtIndex:(NSUInteger)index;
@end

@interface XCLSegmentView : UIView

@property (nonatomic, weak) id<XCLSegmentViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *titles;
@property (nonatomic, strong, readonly) UIView  *indicator;

@property (nonatomic) NSUInteger   selectedSegmentIndex;        // default is 0
@property (nonatomic) UIEdgeInsets indicatorEdgeInsets;         // default is UIEdgeInsetsZero
@property (nonatomic) CGFloat      indicatorPosition;           // default is 0
@property (nonatomic) BOOL         enableIndicatorAnimated;     // default is YES
@property (nonatomic) BOOL         enableGradualColor;          // default is NO

@property (nonatomic, strong) UIFont  *font;                    // default is 18
@property (nonatomic, strong) UIColor *normalColor;             // default is blackColor
@property (nonatomic, strong) UIColor *selectedColor;           // default is redColor

- (void)setTitles:(NSArray *)titles;
- (void)setTitle:(NSString *)title atIndex:(NSUInteger)index;
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animated:(BOOL)animated;
- (UIButton *)buttonAtIndex:(NSUInteger )index;

@end
