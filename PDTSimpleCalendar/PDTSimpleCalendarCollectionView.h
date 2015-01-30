//
// PDTSimpleCalendarCollectionView.h
// PDTSimpleCalendarDemo
//
// Created by Ryan Hoo on 1/26/15.
// Copyright (c) 2015 Ryan Hoo. All rights reserved.
//

/**
 * Notice: 
 *      This view is another copy of PDTSimpleCalendarViewController, but much more flexible. And added some special flavor for our project's needs.
 */
#import <UIKit/UIKit.h>

@protocol PDTSimpleCalendarCollectionViewDelegate;

@interface PDTSimpleCalendarCollectionView : UICollectionView <UICollectionViewDataSource>

/** @name Calendar Setup */

@property (strong, nonatomic) NSArray *dayOfWeeks;

/**
 *  The calendar used to generate the view.
 *
 *  If not set, the default value is `[NSCalendar currentCalendar]`
 */
@property (nonatomic, strong) NSCalendar *calendar;

/**
 *  First date enabled in the calendar. If not set, the default value is the first day of the current month (based on `[NSDate date]`).
 *  You can pass every `NSDate`, if the firstDate is not the first day of its month, the previous days will be automatically disabled.
 */
@property (nonatomic, strong) NSDate *firstDate;

/**
 *  Last date enabled in the calendar. If not set, the default value is the first day of the month of `firstDate` + one year using `calendar` for calculation
 *  You can pass every `NSDate`, if the lastDate is not the last day of its month, the following days will be automatically disabled.
 */
@property (nonatomic, strong) NSDate *lastDate;

/**
 *  Selected date displayed by the calendar.
 *  Changing this value will cause the calendar to scroll to this date (without animation).
 */
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSArray *markedDates;

@property (nonatomic, strong) NSArray *enabledDates;

@property (nonatomic, assign) BOOL defaultDateEnabled;

/** @name Customizing Appearance */

/**
 *  Background color of the Calendar. This will also affect the value of the background color for the overlay view.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  Text color for the overlay view (Month and Year when the user scrolls the calendar)
 */
@property (nonatomic, strong) UIColor *overlayTextColor;

/** @name Getting Notified of changes */

/**
 *  The delegate of the calendar.
 *  Must adopt the `PDTSimpleCalendarViewDelegate` protocol.
 *
 *  @see PDTSimpleCalendarViewDelegate
 */
@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) id calendarDelegate;

/** @name Getting Notified of changes */

/**
 *  Change the selected date of the calendar, and scroll to it
 *
 *  @param newSelectedDate the date that will be selected
 *  @param animated        if you want to animate the scrolling
 */
- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated __attribute__((deprecated("Use setSelectedDate: instead. Also setSelectedDate doesn't automatically scroll to the selected date. You need to explicitly call scrollToDate:animated: (or scrollToSelectedDate:)")));

/**
 *  Scroll to the current selected date in the calendar.
 *
 *  @param animated if you want to animate the scrolling
 */
- (void)scrollToSelectedDate:(BOOL)animated;

/**
 *  Scroll to a certain date in the calendar.
 *
 *  @param date     the date you wanna scroll to.
 *  @param animated if you want to animate the scrolling
 */
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

@end


/**
 *  The methods in `PDTSimpleCalendarCollectionViewDelegate` are all optional. It allows the delegate to be notified when the user interacts with the Calendar.
 */
@protocol PDTSimpleCalendarCollectionViewDelegate <UICollectionViewDelegate>

@optional

/**
 *  Asks the delegate if the Calendar may enable selection for the specified date
 *
 *  @param controller the calendarView Controller
 *  @param date       the date (Midnight GMT)
 *
 *  @return YES if the calendar can select the specified date, NO otherwise.
 */
- (BOOL)simpleCalendarView:(PDTSimpleCalendarCollectionView *)calendar isEnabledDate:(NSDate *)date;

/**
 *  Tells the delegate that a date was selected by the user.
 *
 *  @param controller the calendarView Controller
 *  @param date       the date being selected (Midnight GMT).
 */
- (void)simpleCalendarView:(PDTSimpleCalendarCollectionView *)calendar didSelectDate:(NSDate *)date;

/** @name Color Customization */

/**
 *  Asks the delegate if the Calendar should use custom colors for the specified date.
 *
 *  @param controller the calendarView Controller
 *  @param date       the date (Midnight GMT)
 *
 *  @return YES if the calendar must ask the delegate for text and circle color, NO if it should use default values.
 */
- (BOOL)simpleCalendarView:(PDTSimpleCalendarCollectionView *)calendar shouldUseCustomColorsForDate:(NSDate *)date;

/**
 *  Asks the delegate for the circle color for a custom added date
 *
 *  @param controller the calendarView Controller
 *  @param date       the date (Midnight GMT)
 */
- (UIColor *)simpleCalendarView:(PDTSimpleCalendarCollectionView *)calendar circleColorForDate:(NSDate *)date;

/**
 *  Asks the delegate for the text color for a custom added date
 *
 *  @param controller the calendarView Controller
 *  @param date       the date (Midnight GMT)
 */
- (UIColor *)simpleCalendarView:(PDTSimpleCalendarCollectionView *)calendar textColorForDate:(NSDate *)date;

@end;
