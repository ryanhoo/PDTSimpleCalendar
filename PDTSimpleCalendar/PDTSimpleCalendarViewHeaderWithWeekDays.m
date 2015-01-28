//
//  PDTSimpleCalendarViewHeaderWithWeekDays.m
//  PDTSimpleCalendarDemo
//
//  Created by Ryan Hoo on 1/27/15.
//  Copyright (c) 2015 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewHeaderWithWeekDays.h"

@implementation PDTSimpleCalendarViewHeaderWithWeekDays

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.titleLabel = [[UILabel alloc] init];
//        [self.titleLabel setFont:self.textFont];
//        [self.titleLabel setTextColor:self.textColor];
//        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
//        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.weekDaysView = [[PDTSimpleCalendarWeekDayView alloc] init];

        [self addSubview:self.weekDaysView];
        [self.weekDaysView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.titleLabel];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UIView *separatorView = [[UIView alloc] init];
        [separatorView setBackgroundColor:self.separatorColor];
        [self addSubview:separatorView];
        [separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        CGFloat weekDaysViewHeight = 30.f;
        CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
        NSDictionary *metricsDictionary = @{@"onePixel" : [NSNumber numberWithFloat:onePixel], @"weekDaysViewHeight": [NSNumber numberWithFloat:weekDaysViewHeight]};
        NSDictionary *viewsDictionary = @{@"titleLabel" : self.titleLabel, @"separatorView" : separatorView, @"weekDaysView" : self.weekDaysView};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==10)-[titleLabel]-(==10)-|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(==onePixel)]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[weekDaysView]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[weekDaysView(==weekDaysViewHeight)]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
    }
    return self;
}

@end
