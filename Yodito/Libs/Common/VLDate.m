
#import "VLDate.h"
#import "VL_NSString_Category.h"
#import "VLCommon.h"
#import "VL_NSObjects_Categories.h"
#import "VLTime.h"

static const int _daysToMonth365[13] = { 0, 0x1f, 0x3b, 90, 120, 0x97, 0xb5, 0xd4, 0xf3, 0x111, 0x130, 0x14e, 0x16d };
static const int _daysToMonth366[13] = { 0, 0x1f, 60, 0x5b, 0x79, 0x98, 0xb6, 0xd5, 0xf4, 0x112, 0x131, 0x14f, 0x16e };
static const int _daysPerYear365 = 365;
static const int _daysInMonthsMonth365[13] = { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
static const int _daysInMonthsMonth366[13] = { 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

@implementation VLDate

@synthesize ticks = _ticks;
@dynamic year;
@dynamic month;
@dynamic day;
@dynamic hours;
@dynamic minutes;
@dynamic seconds;
@dynamic milliSeconds;
@dynamic isEmpty;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_ticks = [aDecoder decodeInt64ForKey:@"_ticks"];
	}
	return self;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_ticks = 0;
	}
	return self;
}

- (id)initWithTicks:(int64_t)ticks
{
	self = [super init];
	if(self)
	{
		_ticks = ticks;
	}
	return self;
}

- (id)initWithNSDate:(NSDate*)other
{
	self = [super init];
	if(self)
	{
		if(other)
		{
			NSTimeInterval ti = [other timeIntervalSince1970];
			_ticks = kVLDateTicksUntil1970 + (int64_t)(ti * kVLDateTicksPerSecond);
		}
	}
	return self;
}

- (id)initWithYear:(int)year month:(int)mon day:(int)day
{
	self = [super init];
	if(self)
	{
		_ticks = [VLDate ticksFromYear:year month:mon day:day];
	}
	return self;
}

- (id)initWithYear:(int)year month:(int)mon day:(int)day
			 hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec
{
	self = [super init];
	if(self)
	{
		_ticks = [VLDate ticksFromYear:year month:mon day:day hours:hour minutes:mint seconds:sec milliseconds:msec];
	}
	return self;
}

- (id)initWithYear:(int)year month:(int)mon day:(int)day
			 hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec timeZone:(NSTimeZone *)tz {
	self = [super init];
	if(self) {
		_ticks = [VLDate ticksFromYear:year month:mon day:day hours:hour minutes:mint seconds:sec milliseconds:msec];
		long offsetSeconds = (long)[tz secondsFromGMTForDate:[self toNSDate]];
		_ticks -= offsetSeconds * kVLDateTicksPerSecond;
	}
	return self;
}

- (id)initWithYear:(int)year month:(int)mon day:(int)day timeZone:(NSTimeZone *)tz {
	self = [self initWithYear:year month:mon day:day hours:0 minutes:0 seconds:0 milliseconds:0 timeZone:tz];
	if(self) {
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt64:_ticks forKey:@"_ticks"];
}

+ (VLDate*)fromNSDate:(NSDate*)other
{
	if(!other)
		return [[VLDate new] autorelease];
	return [[[VLDate alloc] initWithNSDate:other] autorelease];
}

- (int)year
{
	return [self getDatePart:0];
}

- (int)month
{
	return [self getDatePart:2];
}

- (int)day
{
	return [self getDatePart:3];
}

- (int)hours
{
	return (int) ((_ticks / kVLDateTicksPerHour) % kVLDateHoursPerDay);
}

- (int)minutes
{
	return (int) ((_ticks / kVLDateTicksPerMinute) % kVLDateMinutesPerHour);
}

- (int)seconds
{
	return (int) ((_ticks / kVLDateTicksPerSecond) % kVLDateSecondsPerMinute);
}

- (int)milliSeconds
{
	return (int) (_ticks / kVLDateTicksPerMillisecond % kVLDateMillisecondsPerSecond);
}

+ (BOOL)isLeapYear:(int)year
{
	if ((year % 4) != 0)
		return NO;
	if ((year % 100) == 0)
		return ((year % 400) == 0);
	return YES;
}

+ (int64_t)ticksFromYear:(int)year month:(int)mon day:(int)day
{
	//if (((year >= 1) && (year <= 0x270f)) && ((mon >= 1) && (mon <= 12)))
	if ((year >= 1) && ((mon >= 1) && (mon <= 12)))
	{
		const int *numArray = [VLDate isLeapYear: year] ? _daysToMonth366 : _daysToMonth365;
        if ((day >= 1) && (day <= (numArray[mon] - numArray[mon - 1])))
		{
			int num = year - 1;
			int num2 = ((((((num * _daysPerYear365) + (num / 4)) - (num / 100)) + (num / 400)) + numArray[mon - 1]) + day) - 1;
			return (num2 * kVLDateTicksPerDay);
		}
	}
	return 0;
}

+ (int)daysInMonth:(int)month ofYear:(int)year
{
	if(month > 12)
		month = 12;
	if(month < 1)
		month = 1;
	const int *numArray = [VLDate isLeapYear: year] ? _daysInMonthsMonth366 : _daysInMonthsMonth365;
	int daysInMonth = numArray[month];
	return daysInMonth;
}

+ (int64_t)ticksFromHours:(int)hour minutes:(int)mint seconds:(int)sec
{
	int64_t num = ((hour * kVLDateSecondsPerHour) + (mint * kVLDateSecondsPerMinute)) + sec;
    return (num * kVLDateTicksPerSecond);
}

+ (int64_t)ticksFromYear:(int)year month:(int)mon day:(int)day
				   hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec
{
	int64_t res = [VLDate ticksFromYear:year month:mon day:day]
		+ [VLDate ticksFromHours:hour minutes:mint seconds:sec] + msec * kVLDateTicksPerMillisecond;
	return res;
}

- (NSString*)toString
{
	NSString *sYear;
	if(self.year <= 9999)
		sYear = [NSString stringWithFormat:@"%.4d", self.year];
	else
		sYear = [NSString stringWithFormat:@"%d", self.year];
	NSString *res = [NSString stringWithFormat:@"%@-%.2d-%.2d %.2d:%.2d:%.2d.%.3d", sYear, self.month, self.day,
					 self.hours, self.minutes, self.seconds, self.milliSeconds];
	return res;
}

- (NSString *)toStringWithTimezone:(NSTimeZone*)timezone {
	NSDate *date = [self toNSDate];
	NSDateFormatter *frm = [[NSDateFormatter alloc] init];
	frm.timeZone = timezone;
	frm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	NSString *sDate = [frm stringFromDate:date];
	[frm release];
	return sDate;
}

+ (VLDate*)fromString:(NSString*)str
{
	int64_t ticks = 0;
	if(![NSString isEmpty:str])
	{
		BOOL error = NO;
		int sLen = (int)[str length];
		int iYear = -1, iMon = -1, iDay = -1, iHour = -1, iMin = -1, iSec = -1, iMSec = -1;
		int lastPos = -1;
		for(int i = 0; i <= sLen; i++)
		{
			unichar c = (i < sLen) ? [str characterAtIndex:i] : '.';
			if(c == '-' || c == ' ' || c == ':' || c == '.')
			{
				NSString *s = [str substringWithRange:NSMakeRange(lastPos+1, i-lastPos-1)];
				lastPos = i;
				if(![NSString isEmpty:s])
				{
					BOOL valid = YES;
					for(int k=0; k<[s length]; k++)
					{
						unichar c1 = [s characterAtIndex:k];
						if(![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c1])
							valid = NO;
					}
					if(valid)
					{
						int val = [s intValue];
						if(c == '-' || c == ' ')
						{
							if(iYear < 0)
								iYear = val;
							else if(iMon < 0)
								iMon = val;
							else if(iDay < 0)
								iDay = val;
							else
								error = YES;
						}
						else if(c == ':' || c == '.')
						{
							if(iHour < 0)
								iHour = val;
							else if(iMin < 0)
								iMin = val;
							else if(iSec < 0)
								iSec = val;
							else if(iMSec < 0)
								iMSec = val;
							else
								error = YES;
						}
					}
				}
			}
		}
		if(iSec < 0)
			iSec = 0;
		if(iMSec < 0)
			iMSec = 0;
		if(!error && iYear >= 0 && iMon >= 1 && iMon <= 12 && iDay >= 1 && iDay <= 31
		   && iHour >= 0 && iMin >= 0 && iSec >= 0 && iMSec >= 0)
		{
			ticks = [VLDate ticksFromYear:iYear month:iMon day:iDay
								   hours:iHour minutes:iMin seconds:iSec milliseconds:iMSec];
		}
	}
	VLDate *res = [[[VLDate alloc] initWithTicks:ticks] autorelease];
	return res;
}

- (NSDate*)toNSDate
{
	NSTimeInterval tiSince = (_ticks - kVLDateTicksUntil1970) / (double)kVLDateTicksPerSecond;
	NSDate *res = [[[NSDate alloc] initWithTimeIntervalSince1970:tiSince] autorelease];
	return res;
}

- (NSString*)toStringEnglishDate
{
	NSDate *nsDate = [self toNSDate];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateString = [dateFormatter stringFromDate:nsDate];
	return dateString;
}

+ (VLDate*)now
{
	NSDate *other = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	NSTimeInterval ti = [other timeIntervalSince1970];
	[other release];
	VLDate *res = [[[VLDate alloc] initWithTicks:(kVLDateTicksUntil1970 + (int64_t)(ti * kVLDateTicksPerSecond))] autorelease];
	return res;
}

+ (VLDate*)date {
	return [VLDate now];
}

- (int64_t)ticksSinceDate:(VLDate*)other
{
	if(!other)
		return 0;
	int64_t res = self.ticks - other.ticks;
	return res;
}

- (int)getDatePart:(int)part
{
	int num = (int) (_ticks / kVLDateTicksPerDay);
	int num2 = num / 0x23ab1;
    num -= num2 * 0x23ab1;
    int num3 = num / 0x8eac;
    if (num3 == 4)
    {
        num3 = 3;
    }
    num -= num3 * 0x8eac;
    int num4 = num / 0x5b5;
    num -= num4 * 0x5b5;
    int num5 = num / 0x16d;
    if (num5 == 4)
    {
        num5 = 3;
    }
    if (part == 0)
    {
        return (((((num2 * 400) + (num3 * 100)) + (num4 * 4)) + num5) + 1);
    }
    num -= num5 * 0x16d;
    if (part == 1)
    {
        return (num + 1);
    }
    const int *numArray = ((num5 == 3) && ((num4 != 0x18) || (num3 == 3))) ? _daysToMonth366 : _daysToMonth365;
    int index = num >> 6;
    while (num >= numArray[index])
    {
        index++;
    }
    if (part == 2)
    {
        return index;
    }
    return ((num - numArray[index - 1]) + 1);
}

- (NSComparisonResult)compare:(VLDate*)other
{
	if(self.ticks > other.ticks)
		return 1;
	else if(self.ticks < other.ticks)
		return -1;
	return 0;
}

- (BOOL)isEqual:(id)object
{
	VLDate *other = ObjectCast(object, VLDate);
	if(!other)
		return NO;
	return self.ticks == other.ticks;
}

- (id)copyWithZone:(NSZone *)zone
{
	VLDate *other = [[VLDate allocWithZone:zone] initWithTicks:self.ticks];
	return other;
}

+ (VLDate*)empty
{
	static VLDate *_empty = nil;
	if(!_empty)
		_empty = [VLDate new];
	return _empty;
}

+ (BOOL)isEmpty:(VLDate*)date {
	return !date || date.isEmpty;
}

- (VLDate *)dateByAppendingTimeInterval:(NSTimeInterval)timeInterval {
	VLDate *res = [[[VLDate alloc] initWithTicks:self.ticks + kVLDateTicksPerSecond*timeInterval] autorelease];
	return res;
}

- (VLDate*)dateByAppendingDays:(int)days
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:days];
	NSDate *nextDate = [calendar dateByAddingComponents:offsetComponents toDate:[self toNSDate] options:0];
	[offsetComponents release];
	return [[[VLDate alloc] initWithNSDate:nextDate] autorelease];
}

- (BOOL)isEmpty
{
	return (_ticks == 0);
}

+ (NSString*)daytimeStrFromTimeInterval:(NSTimeInterval)time
{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *result = [formatter stringFromDate:date];
	return result;
}

- (VLDate*)dateByAppendingMonths:(int)months
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setMonth:months];
	NSDate *nextDate = [calendar dateByAddingComponents:offsetComponents toDate:[self toNSDate] options:0];
	[offsetComponents release];
	return [[[VLDate alloc] initWithNSDate:nextDate] autorelease];
}

- (NSTimeInterval)timeIntervalSinceDate:(VLDate *)anotherDate {
	return (double)(self.ticks - anotherDate.ticks) / kVLDateTicksPerSecond;
}

- (int)gregorianYearWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianYearWithTimezone:timezone];
}

- (int)gregorianMonthWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianMonthWithTimezone:timezone];
}

- (int)gregorianDayWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianDayWithTimezone:timezone];
}

- (int)gregorianWeekdayWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianWeekdayWithTimezone:timezone];
}

- (int)gregorianHourWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianHourWithTimezone:timezone];
}

- (int)gregorianMinuteWithTimezone:(NSTimeZone*)timezone {
	return [[self toNSDate] gregorianMinuteWithTimezone:timezone];
}

- (int)yearWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianYearWithTimezone:timezone];
}

- (int)monthWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianMonthWithTimezone:timezone];
}

- (int)dayWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianDayWithTimezone:timezone];
}

- (int)weekdayWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianWeekdayWithTimezone:timezone];
}

- (int)hourWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianHourWithTimezone:timezone];
}

- (int)minuteWithTimezone:(NSTimeZone*)timezone {
	return [self gregorianMinuteWithTimezone:timezone];
}

- (VLDate *)dateByRoundingToMinutes {
	VLDate *res = [[[VLDate alloc] initWithTicks:(self.ticks + kVLDateTicksPerMinute/2) / kVLDateTicksPerMinute * kVLDateTicksPerMinute] autorelease];
	return res;
}

- (VLDate *)dateByRoundingToMinutesFloor {
	VLDate *res = [[[VLDate alloc] initWithTicks:self.ticks / kVLDateTicksPerMinute * kVLDateTicksPerMinute] autorelease];
	return res;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %x %@", NSStringFromClass([self class]), (unsigned int)self, [self toString]];
}

- (VLDate *)dateBySettingTime:(VLTime *)time timezone:(NSTimeZone*)timezone {
	VLDate *res = [[[VLDate alloc] initWithYear:[self gregorianYearWithTimezone:timezone]
										 month:[self gregorianMonthWithTimezone:timezone]
										   day:[self gregorianDayWithTimezone:timezone]
										 hours:time.hours
									   minutes:time.minutes
									   seconds:time.seconds
								  milliseconds:0
									  timeZone:timezone] autorelease];
	return res;
}

- (VLDate *)dateByResettingTimeWimezone:(NSTimeZone*)timezone {
	return [self dateBySettingTime:[VLTime empty] timezone:timezone];
}

- (int)diffDaysFrom:(VLDate *)other timezone:(NSTimeZone *)timezone {
	return [[self toNSDate] diffDaysFrom:[other toNSDate] timezone:timezone];
}

- (void)dealloc
{
	[super dealloc];
}

@end

