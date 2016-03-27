//
//  XCLSegmentView.m
//  XCLSegmentViewDemo
//
//  Created by stone on 16/3/25.
//  Copyright © 2016年 stone. All rights reserved.
//

#import "XCLSegmentView.h"

@interface XCLSegmentView ()

@property (nonatomic, strong) NSArray            *titles;
@property (nonatomic, strong) UIView             *indicator;
@property (nonatomic, strong) NSMutableArray     *indicatorConstraints;
@property (nonatomic, strong) NSLayoutConstraint *indicatorLeftConstraint;

@end

@implementation XCLSegmentView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_init];
    }
    return self;
}

- (void)awakeFromNib
{
    [self pri_init];
}

- (void)pri_init
{
    self.clipsToBounds       = YES;
    _selectedSegmentIndex    = 0;
    _indicatorEdgeInsets     = UIEdgeInsetsZero;
    _enableIndicatorAnimated = YES;
    _enableGradualColor      = NO;
    _font                    = [UIFont systemFontOfSize:18];
    _normalColor             = [UIColor blackColor];
    _selectedColor           = [UIColor redColor];
}

- (void)dealloc
{
    
}

#pragma mark - publish methods

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    
    for (NSInteger i = 0; i < _titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        [button setTitle:_titles[i] forState:UIControlStateNormal];
    }
    
    UIButton *button = [self creatButtonIfNeededAtIndex:0];
    [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectedColor forState:UIControlStateHighlighted];
    [self addButtonsConstraints];
    [self indicator];
    [self updateIndicatorConstraints];
}

- (void)setTitle:(NSString *)title atIndex:(NSUInteger)index
{
    if (index >= self.titles.count) {
        return;
    }
    
    UIButton *button = [self creatButtonIfNeededAtIndex:index];
    [button setTitle:title forState:UIControlStateNormal];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex
{
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animated:(BOOL)animated
{
    CGFloat indicatorLeftConstraint = self.indicatorEdgeInsets.left + selectedSegmentIndex * self.bounds.size.width/self.titles.count;
    
    if (self.indicatorLeftConstraint.constant != indicatorLeftConstraint) {
        self.indicatorLeftConstraint.constant = indicatorLeftConstraint;
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                [self layoutIfNeeded];
            }];
        }
    }
    
    _selectedSegmentIndex = selectedSegmentIndex;
    
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        if (i == _selectedSegmentIndex) {
            [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
            [button setTitleColor:self.selectedColor forState:UIControlStateHighlighted];
        } else {
            [button setTitleColor:self.normalColor forState:UIControlStateNormal];
            [button setTitleColor:self.normalColor forState:UIControlStateHighlighted];
        }
    }
}

- (UIButton *)buttonAtIndex:(NSUInteger )index
{
    if (index >= self.titles.count) {
        return nil;
    }
    
    return [self creatButtonIfNeededAtIndex:index];
}

- (void)setIndicatorEdgeInsets:(UIEdgeInsets)indicatorEdgeInsets
{
    _indicatorEdgeInsets = indicatorEdgeInsets;
    [self updateIndicatorConstraints];
}

- (void)setIndicatorPosition:(CGFloat)indicatorPosition
{
    if (_indicatorPosition == indicatorPosition) {
        return;
    }
    
    indicatorPosition = MAX(indicatorPosition, 0);
    indicatorPosition = MIN(indicatorPosition, 1);
    
    if (self.enableIndicatorAnimated) {
        _indicatorPosition = indicatorPosition;
        CGFloat buttonWidth = self.bounds.size.width/self.titles.count;
        CGFloat distance = buttonWidth*(self.titles.count - 1);
        CGFloat left = distance * _indicatorPosition + self.indicatorEdgeInsets.left;
        self.indicatorLeftConstraint.constant = left;
    } else {
        CGFloat index = indicatorPosition * (self.titles.count - 1);
        CGFloat buttonWidth = self.bounds.size.width/self.titles.count;
        _indicatorPosition = round(index) / (self.titles.count - 1);
        CGFloat left = round(index) * buttonWidth + self.indicatorEdgeInsets.left;
        self.indicatorLeftConstraint.constant = left;
    }
    
    CGFloat index = indicatorPosition * (self.titles.count - 1);
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        
        if (self.enableGradualColor) {
            if (i == floor(index)) {
                UIColor *gradualColor = [self gradualColorWithProgress:index - floor(index) fromColor:self.selectedColor toColor:self.normalColor];
                [button setTitleColor:gradualColor forState:UIControlStateNormal];
                [button setTitleColor:gradualColor forState:UIControlStateHighlighted];
            } else if (i == ceil(index)) {
                UIColor *gradualColor = [self gradualColorWithProgress:ceil(index) - index fromColor:self.selectedColor toColor:self.normalColor];
                [button setTitleColor:gradualColor forState:UIControlStateNormal];
                [button setTitleColor:gradualColor forState:UIControlStateHighlighted];
            } else {
                [button setTitleColor:self.normalColor forState:UIControlStateNormal];
                [button setTitleColor:self.normalColor forState:UIControlStateHighlighted];
            }
        } else {
            if (i == round(index)) {
                [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
                [button setTitleColor:self.selectedColor forState:UIControlStateHighlighted];
            } else {
                [button setTitleColor:self.normalColor forState:UIControlStateNormal];
                [button setTitleColor:self.normalColor forState:UIControlStateHighlighted];
            }
        }
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        button.titleLabel.font = _font;
    }
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        if (i != self.selectedSegmentIndex) {
            [button setTitleColor:self.normalColor forState:UIControlStateNormal];
            [button setTitleColor:self.normalColor forState:UIControlStateHighlighted];
        }
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        if (i == self.selectedSegmentIndex) {
            [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
            [button setTitleColor:self.selectedColor forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - event response

- (void)onClicked:(UIButton *)button
{
    NSUInteger index = [self indexAtTag:button.tag];
    BOOL isChanged = self.selectedSegmentIndex != index;
    [self setSelectedSegmentIndex:index animated:self.enableIndicatorAnimated];
    
    if (isChanged && [self.delegate respondsToSelector:@selector(segmentView:clickedAtIndex:)]) {
        [self.delegate segmentView:self clickedAtIndex:index];
    }
}

#pragma mark - private methods

- (void)addButtonsConstraints
{
    
    UIView *leftView = nil;
    for (NSInteger i = 0; i < self.titles.count; ++i) {
        UIButton *button = [self creatButtonIfNeededAtIndex:i];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:button
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:button.superview
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                       constant:0]];
        [button.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:button
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:button.superview
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                       constant:0]];
        
        [button.superview addConstraint:
         [NSLayoutConstraint constraintWithItem:button
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:leftView ? : button.superview
                                      attribute:leftView ? NSLayoutAttributeRight : NSLayoutAttributeLeft
                                     multiplier:1.0f
                                       constant:0]];
        
        if (leftView) {
            [button.superview addConstraint:
             [NSLayoutConstraint constraintWithItem:button
                                          attribute:NSLayoutAttributeWidth
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:leftView
                                          attribute:NSLayoutAttributeWidth
                                         multiplier:1.0f
                                           constant:0]];
        }
        leftView = button;
    }
    
    UIButton *button = [self creatButtonIfNeededAtIndex:self.titles.count - 1];
    [button.superview addConstraint:
     [NSLayoutConstraint constraintWithItem:button
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:button.superview
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1.0f
                                   constant:0]];
    
    
    
}

- (void)updateIndicatorConstraints
{
    if (!self.indicatorConstraints) {
        self.indicatorConstraints = [NSMutableArray array];
    }
    
    [self.indicator.superview removeConstraints:self.indicatorConstraints];
    [self.indicator.superview removeConstraint:self.indicatorLeftConstraint];
    [self.indicatorConstraints removeAllObjects];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.indicator
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.indicator.superview
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0/self.titles.count
                                                                   constant:-(self.indicatorEdgeInsets.left + self.indicatorEdgeInsets.right)];
    [self.indicatorConstraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.indicator
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.indicator.superview
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:self.indicatorEdgeInsets.top];
    [self.indicatorConstraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.indicator
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.indicator.superview
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-self.indicatorEdgeInsets.bottom];
    [self.indicatorConstraints addObject:constraint];
    
    
    self.indicatorLeftConstraint = [NSLayoutConstraint constraintWithItem:self.indicator
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.indicator.superview
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0f
                                                                 constant:self.indicatorEdgeInsets.left + self.selectedSegmentIndex * self.bounds.size.width/self.titles.count];
    
    [self.indicator.superview addConstraints:self.indicatorConstraints];
    [self.indicator.superview addConstraint:self.indicatorLeftConstraint];
    
}


- (UIColor *)gradualColorWithProgress:(CGFloat)progress
                            fromColor:(UIColor *)fromColor
                              toColor:(UIColor *)toColor
{
    progress = MAX(progress, 0);
    progress = MIN(progress, 1);
    
    CGFloat fromRed   = CGColorGetComponents(fromColor.CGColor)[0];
    CGFloat fromGreen = CGColorGetComponents(fromColor.CGColor)[1];
    CGFloat fromBlue  = CGColorGetComponents(fromColor.CGColor)[2];
    CGFloat fromAlpha = CGColorGetComponents(fromColor.CGColor)[3];

    CGFloat toRed   = CGColorGetComponents(toColor.CGColor)[0];
    CGFloat toGreen = CGColorGetComponents(toColor.CGColor)[1];
    CGFloat toBlue  = CGColorGetComponents(toColor.CGColor)[2];
    CGFloat toAlpha = CGColorGetComponents(toColor.CGColor)[3];

    CGFloat red   = fromRed  <toRed  ?(toRed  -fromRed  )*progress+fromRed   : fromRed  -(fromRed  -toRed  )*progress;
    CGFloat green = fromGreen<toGreen?(toGreen-fromGreen)*progress+fromGreen : fromGreen-(fromGreen-toGreen)*progress;
    CGFloat blue  = fromBlue <toBlue ?(toBlue -fromBlue )*progress+fromBlue  : fromBlue -(fromBlue -toBlue )*progress;
    CGFloat alpha = fromAlpha<toAlpha?(toAlpha-fromAlpha)*progress+fromAlpha : fromAlpha-(fromAlpha-toAlpha)*progress;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


#pragma mark - getters and setters

- (UIView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIView alloc] init];
        _indicator.backgroundColor = [UIColor blackColor];
        _indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:_indicator atIndex:0];
    }
    
    return _indicator;
}

- (UIButton *)creatButtonIfNeededAtIndex:(NSUInteger)index
{
    NSUInteger tag = [self tagAtIndex:index];
    UIButton *button = [self viewWithTag:tag];
    if (!button) {
        button = [[UIButton alloc] init];
        button.tag = tag;
        button.titleLabel.font = self.font;
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
        [button setTitleColor:self.normalColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    return button;
}

- (NSUInteger)tagAtIndex:(NSUInteger)index
{
    return index + 1;
}

- (NSUInteger)indexAtTag:(NSUInteger)tag
{
    return tag - 1;
}

@end
