
#import "VL_NSObjects_Categories.h"
#import "VLStringResources.h"


@implementation NSError(VL_NSError_Category)

+ (NSError *)makeWithText:(NSString*)text code:(int)code
{
	NSError *error = [NSError errorWithDomain:@"" code:code
									 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:text, NSLocalizedDescriptionKey, nil]];
	return error;
}

+ (NSError *)makeWithText:(NSString *)text
{
	return [NSError makeWithText:text code:1];
}

+ (NSError *)makeCancelWithText:(NSString *)text
{
	return [NSError makeWithText:text code:NSUserCancelledError];
}

+ (NSError *)makeCancel
{
	return [NSError makeCancelWithText:[VLStringResources shared].errorCanceled];
}

- (BOOL)isCancel
{
	return (self.code == NSUserCancelledError);
}

@end



@implementation NSDate(VL_NSDate_Category)

- (NSString*)timeToLocalizedStringLocal
{
	//NSDateFormatter *formatter = [NSDateFormatter new];
	//[formatter setDateFormat:@"HH:mm"];
	//NSString *timeString = [formatter stringFromDate:self];
	//[formatter release];
	//return timeString;
	return [NSDateFormatter localizedStringFromDate:self
										  dateStyle:NSDateFormatterNoStyle
										  timeStyle:NSDateFormatterShortStyle];
}

- (NSString*)dateToLocalizedStringShortLocal
{
	return [NSDateFormatter localizedStringFromDate:self
										  dateStyle:NSDateFormatterShortStyle
										  timeStyle:NSDateFormatterNoStyle];
}

- (NSString*)toString
{
	NSString *str = [self description];
	return str;
}

+ (NSDate*)makeWithString:(NSString*)str
{
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
	NSDate *dateFromString = [dateFormatter dateFromString:str];
	if(!dateFromString)
		dateFromString = [NSDate makeWithStringRFC2822:str];
	while(YES)
	{
		if(!dateFromString)
		{
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.ZZZ"];
			dateFromString = [dateFormatter dateFromString:str];
		}
		if(!dateFromString)
		{
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.ZZZZ"];
			dateFromString = [dateFormatter dateFromString:str];
		}
		if(!dateFromString)
		{
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			dateFromString = [dateFormatter dateFromString:str];
		}
		if(!dateFromString)
		{
			str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSRange range = [str rangeOfString:@"."];
			if(range.length)
			{
				str = [str substringToIndex:range.location];
				continue;
			}
		}
		break;
	}
	[dateFormatter release];
	return dateFromString;
}

+ (NSDateFormatter*)dateFormatterRFC2822
{
	//static NSDateFormatter *_dateFormatter = nil;
	NSDateFormatter *_dateFormatter = nil;
	if(!_dateFormatter)
	{
		_dateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[_dateFormatter setLocale:usLocale];
		[usLocale release];
		_dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
	}
	//return _dateFormatter;
	return [_dateFormatter autorelease];
}
- (NSString*)toStringRFC2822WithTimezone:(NSTimeZone*)timezone
{
	NSDateFormatter *dateFormatter = [NSDate dateFormatterRFC2822];
	if(timezone)
		[dateFormatter setTimeZone:timezone];
	NSString *dateString = [dateFormatter stringFromDate:self];
	return dateString;
}
- (NSString*)toStringRFC2822
{
	return [self toStringRFC2822WithTimezone:nil];
}
+ (NSDate*)makeWithStringRFC2822:(NSString*)str
{
	//NSString *sample = @"Tue, 16 Dec 2008 11:45:13 +0000";
	NSDateFormatter *dateFormatter = [NSDate dateFormatterRFC2822];
	NSDate *formattedDate = [dateFormatter dateFromString:str];
	return formattedDate;
}

+ (NSDate*)empty
{
	return [NSDate dateWithTimeIntervalSinceReferenceDate:0];
}

+ (BOOL)isEmpty:(NSDate*)date
{
	return !date || [date isEqual:[NSDate empty]];
}

- (BOOL)isSameDayAs:(NSDate*)date timezone:(NSTimeZone*)timezone
{
	NSTimeInterval difference = [date timeIntervalSinceReferenceDate] - [self timeIntervalSinceReferenceDate];
	if(ABS(difference) >= 86400)
		return NO;
	NSTimeInterval timezoneOffset = [timezone secondsFromGMTForDate:self];
	int64_t secondsLocal = (int64_t)([self timeIntervalSinceReferenceDate] + timezoneOffset);
	NSTimeInterval secondsFromMidnight = secondsLocal - secondsLocal / 86400 * 86400;
	if(difference < 0 && ABS(difference) > secondsFromMidnight)
		return NO;
	else if(difference > 0 && difference >= (86400 - secondsFromMidnight))
		return NO;
	return YES;
}

- (int)diffDaysFrom:(NSDate*)other timezone:(NSTimeZone*)timezone
{
	NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:timezone];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
				 interval:NULL forDate:other];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
				 interval:NULL forDate:self];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
											   fromDate:fromDate toDate:toDate options:0];
    int result = (int)[difference day];
	return result;
}

- (int)diffMonthsFrom:(NSDate*)other timezone:(NSTimeZone*)timezone {
	NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:timezone];
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&fromDate
				 interval:NULL forDate:other];
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&toDate
				 interval:NULL forDate:self];
    NSDateComponents *difference = [calendar components:NSMonthCalendarUnit
											   fromDate:fromDate toDate:toDate options:0];
    int result = (int)[difference month];
	return result;
}

- (int)gregorianYearWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:self];
	int year = (int)[components year];
	[calendar release];
	return year;
}

- (int)gregorianMonthWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSMonthCalendarUnit fromDate:self];
	int month = (int)[components month];
	[calendar release];
	return month;
}

- (int)gregorianDayWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:self];
	int day = (int)[components day];
	[calendar release];
	return day;
}

- (int)gregorianWeekdayWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	int weekday = (int)[components weekday];
	[calendar release];
	return weekday;
}

- (int)gregorianHourWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:self];
	int hour = (int)[components hour];
	[calendar release];
	return hour;
}

- (int)gregorianMinuteWithTimezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *components = [calendar components:NSMinuteCalendarUnit fromDate:self];
	int minute = (int)[components minute];
	[calendar release];
	return minute;
}

+ (NSDate*)gregorianDateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second timezone:(NSTimeZone*)timezone
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timezone];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	NSDate *result = [calendar dateFromComponents:comps];
	[calendar release];
	[comps release];
	return result;
}

+ (NSDate*)gregorianDateWithYear:(int)year month:(int)month day:(int)day timezone:(NSTimeZone*)timezone
{
	return [NSDate gregorianDateWithYear:year month:month day:day hour:0 minute:0 second:0 timezone:timezone];
}

- (int64_t)secondsFromMidnightWithTimezone:(NSTimeZone *)timezone {
	int64_t result = [self timeIntervalSinceReferenceDate] + [timezone secondsFromGMTForDate:self];
	result = result % 86400;
	return result;
}

- (NSDate *)dateByAppendingDays:(int)days {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:days];
	NSDate *nextDate = [calendar dateByAddingComponents:offsetComponents toDate:self options:0];
	[offsetComponents release];
	return nextDate;
}

- (NSDate *)dateByAppendingMonths:(int)months {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setMonth:months];
	NSDate *nextDate = [calendar dateByAddingComponents:offsetComponents toDate:self options:0];
	[offsetComponents release];
	return nextDate;
}

@end


