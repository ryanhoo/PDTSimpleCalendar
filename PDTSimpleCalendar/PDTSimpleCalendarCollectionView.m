//
//  PDTSimpleCalendarCollectionView.m
//  PDTSimpleCalendarDemo
//
//  Created by Ryan Hoo on 1/26/15.
//  Copyright (c) 2015 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarCollectionView.h"
#import "PDTSimpleCalendarViewFlowLayout.h"
#import "PDTSimpleCalendarViewCell.h"
#import "PDTSimpleCalendarViewHeader.h"
#import "PDTSimpleCalendarWeekDayView.h"
#import "PDTSimpleCalendarViewHeaderWithWeekDays.h"

#define DAYS_PER_WEEK 7
#define ROW_NUMBER_IN_SECTION 6

static NSString *PDTSimpleCalendarViewCellIdentifier = @"com.producteev.collection.cell.identifier";
static NSString *PDTSimpleCalendarViewHeaderIdentifier = @"com.producteev.collection.header.identifier";

@interface PDTSimpleCalendarCollectionView () <PDTSimpleCalendarViewCellDelegate>

@property (nonatomic, strong) NSDateFormatter *headerDateFormatter; //Will be used to format date in header view and on scroll.

// First and last date of the months based on the public properties first & lastDate
@property (nonatomic, readonly) NSDate *firstDateMonth;
@property (nonatomic, readonly) NSDate *lastDateMonth;

//Number of days per week
@property (nonatomic, assign) NSUInteger daysPerWeek;

@end

@implementation PDTSimpleCalendarCollectionView

//Explicitly @synthesize the var (it will create the iVar for us automatically as we redefine both getter and setter)
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;
@synthesize calendar = _calendar;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[[PDTSimpleCalendarViewFlowLayout alloc] init]];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit:nil];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[PDTSimpleCalendarViewFlowLayout alloc] init]];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit:nil];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super init];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit:nil];
    }
    
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super init];
    if (self) {
        [self simpleCalendarCommonInit:layout];
    }
    
    return self;
}

- (void)simpleCalendarCommonInit:(UICollectionViewLayout *)layout
{
    if (layout == nil) {
        layout = [[PDTSimpleCalendarViewFlowLayout alloc] init];
    }

    self.backgroundColor = [UIColor whiteColor];
    self.overlayTextColor = [UIColor darkGrayColor];
    self.daysPerWeek = DAYS_PER_WEEK;
    
    //Configure the Collection View
    [self registerClass:[PDTSimpleCalendarViewCell class] forCellWithReuseIdentifier:PDTSimpleCalendarViewCellIdentifier];
    [self registerClass:[PDTSimpleCalendarViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PDTSimpleCalendarViewHeaderIdentifier];

    self.delegate = self;
    self.dataSource = self;
    [self setBackgroundColor:self.backgroundColor];
}

- (NSDateFormatter *)headerDateFormatter;
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        _headerDateFormatter.dateFormat = @"yyyy年M月";
    }
    return _headerDateFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        [self setCalendar:[NSCalendar currentCalendar]];
    }
    return _calendar;
}

-(void)setCalendar:(NSCalendar*)calendar
{
    _calendar = calendar;
    self.headerDateFormatter.calendar = calendar;
    self.daysPerWeek = [_calendar maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                        fromDate:[NSDate date]];
        components.day = 1;
        _firstDate = [self.calendar dateFromComponents:components];
    }
    
    return _firstDate;
}

- (void)setFirstDate:(NSDate *)firstDate
{
    _firstDate = [self clampDate:firstDate toComponents:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
}

//TODO: Store the value in the variable to avoid calculation everytime.
- (NSDate *)firstDateMonth
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                    fromDate:self.firstDate];
    components.day = 1;
    
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = 1;
        offsetComponents.day = -1;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDateMonth options:0]];
    }
    
    return _lastDate;
}

- (void)setLastDate:(NSDate *)lastDate
{
    _lastDate = [self clampDate:lastDate toComponents:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
}

//TODO: Store the value in the variable to avoid calculation everytime.
- (NSDate *)lastDateMonth
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.lastDate];
    components.month++;
    components.day = 0;
    
    return [self.calendar dateFromComponents:components];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
	[self setSelectedDate:selectedDate callDelegate:YES];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate callDelegate:(BOOL)callOrNot
{
    //if newSelectedDate is nil, unselect the current selected cell
    if (!newSelectedDate) {
        [[self cellForItemAtDate:_selectedDate] setSelected:NO];
        _selectedDate = newSelectedDate;
        
        return;
    }
    
    //Test if selectedDate between first & last date
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDateMonth] == NSOrderedAscending) || ([startOfDay compare:self.lastDateMonth] == NSOrderedDescending)) {
        //the newSelectedDate is not between first & last date of the calendar, do nothing.
        return;
    }
    
    [[self cellForItemAtDate:_selectedDate] setSelected:NO];
    [[self cellForItemAtDate:startOfDay] setSelected:YES];
    
    _selectedDate = startOfDay;
    
    NSIndexPath *indexPath = [self indexPathForCellAtDate:_selectedDate];
    [self reloadItemsAtIndexPaths:@[ indexPath ]];

    if (callOrNot && [self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:didSelectDate:)]) {
        [self.calendarDelegate simpleCalendarView:self didSelectDate:self.selectedDate];
    }
}

- (void)setMarkedDates:(NSArray *)markedDates
{
    if (_markedDates) {
        for (NSDate *date in _markedDates) {
            [self setDate:date mark:NO];
        }
    }
    
    for (NSDate *date in markedDates) {
        [self setDate:date mark:YES];
    }
    _markedDates = markedDates;
}

- (void)setDate:(NSDate *)date mark:(BOOL) isMarked
{
    //Test if selectedDate between first & last date
    NSDate *startOfDay = [self clampDate:date toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDateMonth] == NSOrderedAscending) || ([startOfDay compare:self.lastDateMonth] == NSOrderedDescending)) {
        //the newSelectedDate is not between first & last date of the calendar, do nothing.
        return;
    }
    
    [[self cellForItemAtDate:date] setIsMarked:isMarked];
    
//    NSIndexPath *indexPath = [self indexPathForCellAtDate:date];
//    [self reloadItemsAtIndexPaths:@[ indexPath ]];
    [self reloadData];
}

//Deprecated, You need to use setSelectedDate: and call scrollToDate:animated: or scrollToSelectedDate:animated:
//TODO: Remove this in next release
- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated
{
    [self setSelectedDate:newSelectedDate];
    [self scrollToSelectedDate:animated];
}

#pragma mark - Scroll to a specific date

- (void)scrollToSelectedDate:(BOOL)animated
{
    if (_selectedDate) {
        [self scrollToDate:_selectedDate animated:animated];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    @try {
        NSIndexPath *selectedDateIndexPath = [self indexPathForCellAtDate:date];
        
        if (![[self indexPathsForVisibleItems] containsObject:selectedDateIndexPath]) {
            //First, tried to use [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:selectedDateIndexPath]; but it causes the header to be redraw multiple times (X each time you use scrollToDate:)
            //TODO: Investigate & eventually file a radar.
            
            NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:selectedDateIndexPath.section];
            UICollectionViewLayoutAttributes *sectionLayoutAttributes = [self layoutAttributesForItemAtIndexPath:sectionIndexPath];
            CGPoint origin = sectionLayoutAttributes.frame.origin;
            origin.x = 0;
            origin.y -= (PDTSimpleCalendarFlowLayoutHeaderHeight + PDTSimpleCalendarFlowLayoutInsetTop + self.contentInset.top);
            [self setContentOffset:origin animated:animated];
        }
    }
    @catch (NSException *exception) {
        //Exception occured (it should not according to the documentation, but in reality...) let's scroll to the IndexPath then
        NSInteger section = [self sectionForDate:date];
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        [self scrollToItemAtIndexPath:sectionIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

#pragma mark - Rotation Handling

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDateMonth toDate:self.lastDateMonth options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
	
    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    NSInteger numberOfItems = (rangeOfWeeks.length * self.daysPerWeek);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDTSimpleCalendarViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:PDTSimpleCalendarViewCellIdentifier
                                                                                     forIndexPath:indexPath];
    cell.delegate = self;
    
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];

    BOOL isToday = NO;
    BOOL isSelected = NO;
    BOOL isCustomDate = NO;
    BOOL isMarked = NO;
    BOOL isDisabled = self.defaultDateEnabled;
    
    if (cellDateComponents.month == firstOfMonthsComponents.month) {
        isSelected = ([self isSelectedDate:cellDate] && (indexPath.section == [self sectionForDate:cellDate]));
        isToday = [self isTodayDate:cellDate];
        isMarked = [self isMarkedDate:cellDate];
        isDisabled = ![self isEnabledDate:cellDate];
        
        [cell setDate:cellDate calendar:self.calendar];

        if ([self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:shouldUseCustomColorsForDate:)]) {
            isCustomDate = [self.calendarDelegate simpleCalendarView:self shouldUseCustomColorsForDate:cellDate];
		}
		
		if (isToday) {
			[cell setIsToday:isToday];
		}
		[cell setSelected:isSelected];
		[cell setIsMarked:isMarked];
		[cell setIsDisabled:isDisabled];

        [cell refreshCellColors];
		cell.hidden = NO;
    } else {
		cell.hidden = YES;
    }
    
    //If the current Date is not enabled, or if the delegate explicitely specify custom colors
    if (![self isEnabledDate:cellDate] || isCustomDate) {
        [cell refreshCellColors];
    }
    
    //We rasterize the cell for performances purposes.
    //The circle background is made using roundedCorner which is a super expensive operation, specially with a lot of items on the screen to display (like we do)
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    //We don't want to select Dates that are "disabled"
    if (![self isEnabledDate:cellDate]) {
        return NO;
    }
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDate = [self dateForCellAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        PDTSimpleCalendarViewHeader *headerView = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PDTSimpleCalendarViewHeaderIdentifier forIndexPath:indexPath];
        headerView.titleLabel.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:indexPath.section]].uppercaseString;

        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        return headerView;
    }
    
    return nil;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (self.frame.size.width - PDTSimpleCalendarFlowLayoutInsetLeft - PDTSimpleCalendarFlowLayoutInsetRight) / self.daysPerWeek;
    return CGSizeMake(itemWidth, itemWidth);
}

+ (CGFloat)calculateItemSizeByWidth:(CGFloat)width andNumberOfRow:(NSInteger)column
{
    return (width - PDTSimpleCalendarFlowLayoutInsetLeft - PDTSimpleCalendarFlowLayoutInsetRight) / column;
}

#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)isMarkedDate:(NSDate *)date
{
    if (self.markedDates) {
        for (NSDate *markedDate in self.markedDates) {
            if ([self clampAndCompareDate:markedDate withReferenceDate:date]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isEnabledDate:(NSDate *)date
{
    if (self.defaultDateEnabled) {
        NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
        if (([clampedDate compare:self.firstDate] == NSOrderedAscending) || ([clampedDate compare:self.lastDate] == NSOrderedDescending)) {
            return NO;
        }

        if ([self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:isEnabledDate:)]) {
            return [self.calendarDelegate simpleCalendarView:self isEnabledDate:date];
        }
        return YES;
    }
    if (self.enabledDates) {
        for (NSDate *enabledDate in self.enabledDates) {
            if ([self clampAndCompareDate:enabledDate withReferenceDate:date]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    
    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDateMonth options:0];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDateMonth toDate:date options:0].month;
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}

- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    NSInteger item = (dateComponents.day - firstOfMonthComponents.day) - (1 - ordinalityOfFirstDay);
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (PDTSimpleCalendarViewCell *)cellForItemAtDate:(NSDate *)date
{
    return (PDTSimpleCalendarViewCell *)[self cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}

#pragma mark PDTSimpleCalendarViewCellDelegate

- (BOOL)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell shouldUseCustomColorsForDate:(NSDate *)date
{
    //If the date is not enabled (aka outside the first/lastDate) return YES
    if (![self isEnabledDate:date]) {
        return YES;
    }
    
    //Otherwise we ask the delegate
    if ([self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:shouldUseCustomColorsForDate:)]) {
        return [self.calendarDelegate simpleCalendarView:self shouldUseCustomColorsForDate:date];
    }
    
    return NO;
}

- (UIColor *)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell circleColorForDate:(NSDate *)date
{
    if (![self isEnabledDate:date]) {
        return cell.circleDefaultColor;
    }

    if ([self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:circleColorForDate:)]) {
        return [self.calendarDelegate simpleCalendarView:self circleColorForDate:date];
    }
    
    return nil;
}

- (UIColor *)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell textColorForDate:(NSDate *)date
{
    if (![self isEnabledDate:date]) {
        return cell.textDisabledColor;
    }

    if ([self.calendarDelegate respondsToSelector:@selector(simpleCalendarView:textColorForDate:)]) {
        return [self.calendarDelegate simpleCalendarView:self textColorForDate:date];
    }
    
    return nil;
}

+ (CGFloat)suggestedHeightForWidth:(CGFloat) width withHeaderHeight:(CGFloat)headerHeight
{
    return headerHeight + width * ROW_NUMBER_IN_SECTION / DAYS_PER_WEEK + PDTSimpleCalendarFlowLayoutHeaderHeight + PDTSimpleCalendarFlowLayoutInsetTop + PDTSimpleCalendarFlowLayoutInsetBottom;
}

@end
