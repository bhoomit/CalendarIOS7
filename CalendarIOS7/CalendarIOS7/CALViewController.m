//
//  CALViewController.m
//  CalendarIOS7
//
//  Created by Jerome Morissard on 3/9/14.
//  Copyright (c) 2014 Jerome Morissard. All rights reserved.
//

#import "CALViewController.h"

//model
#import "NSDate+ETI.h"
#import "NSDateFormatter+CAT.h"
#import "NSDate+Agenda.h"
#import "CALDay.h"

//UI
#import "CALMonthHeaderView.h"
#import "CALDayCollectionViewCell.h"
#import "CALAgendaCollectionView.h"

//Layout
#import "CALAgendaMonthCollectionViewLayout.h"


@interface CALViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSDate *currentDate;

@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateComponents *timeComponents;

@property (strong, nonatomic) NSDate *fromFirstDayMonth;
@property (strong, nonatomic) CALAgendaMonthCollectionViewLayout *collectionMonthLayout;
//Quarts selection
@property (strong, nonatomic) CALDay *dayStructured;
@property (strong, nonatomic) NSDateFormatter *sectionFormater;

@property (strong, nonatomic) CALAgendaCollectionView *calendarCollectionView;

@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@property (assign, nonatomic) CALDayCollectionViewCellDayUIStyle dayStyle;
@property (assign, nonatomic) UICollectionViewScrollDirection calendarScrollDirection;
@property (weak, nonatomic) IBOutlet UIView *calendarView;

- (void)reloadContent;
- (void)refreshLayout;

@end

@implementation CALViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (CALAgendaCollectionView *)calendarCollectionView{
	if(!_calendarCollectionView){
		CGRect frame = self.calendarView.bounds;
		frame.size.height += 35;
		_calendarCollectionView = [[CALAgendaCollectionView alloc] initWithFrame:frame collectionViewLayout:self.collectionMonthLayout];
	}
	return _calendarCollectionView;
}

- (CALAgendaMonthCollectionViewLayout *)collectionMonthLayout{
	if(!_collectionMonthLayout){
		_collectionMonthLayout = [CALAgendaMonthCollectionViewLayout new];
	}
	return _collectionMonthLayout;
}

#pragma mark - UICollectionViewDelegate

- (IBAction)showMyCalendariOS7Horizontal:(id)sender
{
	[self showMyCalendarWithScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (void)showMyCalendarWithScrollDirection:(UICollectionViewScrollDirection)direction
{
	
	NSDateComponents *components = [NSDateComponents new];
	components.month = 4;
	components.day = 1;
	components.year = 2014;
	NSDate *fromDate = [[NSDate gregorianCalendar] dateFromComponents:components];
	components.month = 5;
	components.day = 15;
	NSDate *toDate = [[NSDate gregorianCalendar] dateFromComponents:components];
	[self setFromDate:fromDate];
	[self setToDate:toDate];
	
	// Do any additional setup after loading the view from its nib.
	self.title = @"Agenda";
	self.calendar = [NSDate gregorianCalendar];
	self.calendarScrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.sectionFormater = [NSDateFormatter dateFormatterForType:CALDateFormatterType_dd_MM_yyyy];
	
	self.calendarCollectionView.delegate = self;
	[self.calendarView addSubview:self.calendarCollectionView];
	self.calendarCollectionView.dataSource = self;
	self.dayStyle = CALDayCollectionViewCellDayUIStyleIOS7;
	self.dayStructured = [CALDay new];
}

#pragma mark - CALAgendaCollectionViewDelegate

- (void)viewDidLayoutSubviews
{
	[self refreshLayout];
}

- (void)setFromDate:(NSDate *)fromDate
{
	_fromDate = fromDate;
	self.fromFirstDayMonth = [_fromDate firstDayOfTheMonth];
	if (nil != _toDate) {
		[self.calendarCollectionView reloadData];
	}
}

- (void)setToDate:(NSDate *)toDate
{
	_toDate = toDate;
	if (nil != _fromDate) {
		[self.calendarCollectionView reloadData];
	}
}

- (void)refreshLayout
{
	if (self.calendarCollectionView) {
		//Compute itemSize
		self.collectionMonthLayout = [[CALAgendaMonthCollectionViewLayout alloc] initWithWidth:CGRectGetWidth(self.calendarCollectionView.bounds)];
	}
	self.collectionMonthLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	[self.calendarCollectionView setCollectionViewLayout:self.collectionMonthLayout animated:YES];
	[self.calendarCollectionView reloadData];
}

- (void)reloadContent
{
	self.fromFirstDayMonth = [_fromDate firstDayOfTheMonth];
	[self.calendarCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	if([collectionView.collectionViewLayout isKindOfClass:[CALAgendaMonthCollectionViewLayout class]]) {
		return [NSDate numberOfMonthFromDate:self.fromFirstDayMonth toDate:self.toDate];
	}
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if([collectionView.collectionViewLayout isKindOfClass:[CALAgendaMonthCollectionViewLayout class]]) {
		NSDate *firstDay = [self dateForFirstDayInSection:section];
		NSInteger weekDay = [firstDay weekDay] -1;
		NSInteger items =  weekDay + [NSDate numberOfDaysInMonthForDate:firstDay];
		return items;
	}
	
	return 24 * 4;
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
{
	NSDateComponents *dateComponents = [NSDateComponents new];
	dateComponents.month = section;
	return [self.calendar dateByAddingComponents:dateComponents toDate:self.fromFirstDayMonth options:0];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if([collectionView.collectionViewLayout isKindOfClass:[CALAgendaMonthCollectionViewLayout class]]) {
		CALDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CALDayCollectionViewCell"
																				   forIndexPath:indexPath];
		NSDate *date = [self dateAtIndexPath:indexPath];
		cell.style = self.dayStyle;
		if(date){
			if([date compare:self.toDate] == NSOrderedDescending || [date compare:self.fromDate] == NSOrderedAscending){
				cell.type = CALDayCollectionViewCellDayTypeEmpty;
			}else{
				cell.type = CALDayCollectionViewCellDayTypeFutur;
			}
			[cell updateCellWithDate:date];
		}else{
			cell.type = CALDayCollectionViewCellDayTypeEmpty;
		}
		return cell;
	}
	NSAssert(0, @"UICollectionViewCell is nit??");
	return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	if ([self.calendarCollectionView.collectionViewLayout isKindOfClass:[CALAgendaMonthCollectionViewLayout class]]) {
		if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
			CALMonthHeaderView *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CALMonthHeaderView" forIndexPath:indexPath];
			monthHeader.masterLabel.text = [self monthAtIndexPath:indexPath];
			[monthHeader updateWithDayNames:[NSDate weekdaySymbols] cellSize:self.collectionMonthLayout.itemSize];
			monthHeader.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95f];
			return monthHeader;
		}
	}
	NSAssert(0, @"UICollectionReusableView is nit??");
	return nil;
}

#pragma mark - Private method

- (NSDate *)dateAtIndexPath:(NSIndexPath *)indexPath
{
	NSDate *firstDay = [self dateForFirstDayInSection:indexPath.section];
	NSInteger weekDay = [firstDay weekDay];
	NSDate *dateToReturn = nil;
	
	if (indexPath.row < (weekDay-1)) {
		dateToReturn = nil;
	}
	else {
		NSDateComponents *components = [[NSDate gregorianCalendar] components:NSMonthCalendarUnit| NSCalendarUnitDay fromDate:firstDay];
		[components setDay:indexPath.row - (weekDay - 1)];
		[components setMonth:indexPath.section];
		dateToReturn = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:self.fromFirstDayMonth options:0];
	}
	return dateToReturn;
}

- (NSString *)monthAtIndexPath:(NSIndexPath *)indexPath
{
	NSDate *date = [self dateForFirstDayInSection:indexPath.section];
	NSDateComponents *components = [[NSDate gregorianCalendar] components:NSMonthCalendarUnit fromDate:date];
	return [NSDate monthSymbolAtIndex:components.month];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	CALDayCollectionViewCell *cell = (CALDayCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	cell.type = CALDayCollectionViewCellDayTypeToday;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
	CALDayCollectionViewCell *cell = (CALDayCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	cell.type = -1;
}

@end
