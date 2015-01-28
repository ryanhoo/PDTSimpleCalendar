//
//  PDTSimpleCalendarWeekDayView.m
//  PDTSimpleCalendarDemo
//
//  Created by Ryan Hoo on 1/27/15.
//  Copyright (c) 2015 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarWeekDayView.h"
#import "PDTSimpleCalendarViewFlowLayout.h"

@implementation PDTSimpleCalendarWeekDayView

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // init week day views
    NSArray *daysOfWeek = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    for(NSString *day in daysOfWeek){
        UILabel *view = [[UILabel alloc] init];
        
        // view.font = self.calendarManager.calendarAppearance.weekDayTextFont;
        // view.textColor = self.calendarManager.calendarAppearance.weekDayTextColor;
        
        view.textAlignment = NSTextAlignmentCenter;
        view.text = day;
        
        [self addSubview:view];
    }
}

- (void)layoutSubviews
{
    CGFloat x = 0;
    CGFloat width = (self.frame.size.width - PDTSimpleCalendarFlowLayoutInsetLeft - PDTSimpleCalendarFlowLayoutInsetRight) / 7.;
    CGFloat height = self.frame.size.height;
    
    for(UIView *view in self.subviews){
        view.frame = CGRectMake(x, 0, width, height);
        x = CGRectGetMaxX(view.frame);
    }
    
    // [super layoutSubviews];
}

- (void)setWeekDayViewsColor:(UIColor *)color font:(UIFont *)font{
    for (UILabel *view in self.subviews) {
        if (color)
            view.textColor = color;
        if (font)
            view.font = font;
    }
}

@end
