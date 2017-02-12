
#import "VLDateNoTime.h"
#import "VLCommon.h"
#import "VLDate.h"

@implementation VLDateNoTime

@synthesize days = _days;
@dynamic year;
@dynamic month;
@dynamic day;

- (id)initWithDays:(int)days {
	self = [super init];
	if(self) {
		_days = days;
	}
	return self;
}

- (id)initWithYear:(int)year month:(int)month day:(int)day {
	self = [super init];
	if(self) {
		VLDate *date = [[VLDate alloc] initWithYear:year month:month day:day];
		_days = date.ticks / kVLDateTicksPerDay;
		[date release];
	}
	return self;
}

- (id)initWithNSDate:(NSDate *)date timezone:(NSTimeZone *)tz {
	self = [super init];
	if(self) {
		long offsetSeconds = [tz secondsFromGMTForDate:date];
		VLDate *vldate = [[VLDate alloc] initWithNSDate:date];
		_days = (vldate.ticks + offsetSeconds * kVLDateTicksPerSecond) / kVLDateTicksPerDay;
		[vldate release];
	}
	return self;
}

- (id)initWithNSDate:(NSDate *)date {
	self = [super init];
	if(self) {
		VLDate *vldate = [[VLDate alloc] initWithNSDate:date];
		_days = vldate.ticks / kVLDateTicksPerDay;
		[vldate release];
	}
	return self;
}

- (id)initWithDate:(VLDate *)date timezone:(NSTimeZone *)tz {
	self = [super init];
	if(self) {
		long offsetSeconds = [tz secondsFromGMTForDate:[date toNSDate]];
		_days = (date.ticks + offsetSeconds * kVLDateTicksPerSecond) / kVLDateTicksPerDay;
	}
	return self;
}

- (int)year {
	VLDate *date = [[VLDate alloc] initWithTicks:self.days * kVLDateTicksPerDay];
	int res = date.year;
	[date release];
	return res;
}

- (int)month {
	VLDate *date = [[VLDate alloc] initWithTicks:self.days * kVLDateTicksPerDay];
	int res = date.month;
	[date release];
	return res;
}

- (int)day {
	VLDate *date = [[VLDate alloc] initWithTicks:self.days * kVLDateTicksPerDay];
	int res = date.day;
	[date release];
	return res;
}

- (NSComparisonResult)compare:(VLDateNoTime *)other {
	if(self.days > other.days)
		return 1;
	else if(self.days < other.days)
		return -1;
	return 0;
}

- (BOOL)isEqual:(id)object {
	VLDateNoTime *other = ObjectCast(object, VLDateNoTime);
	if(!other)
		return NO;
	return [self compare:other] == 0;
}

- (id)copyWithZone:(NSZone *)zone {
	VLDateNoTime *other = [[VLDateNoTime allocWithZone:zone] initWithDays:self.days];
	return other;
}

+ (VLDateNoTime *)empty {
	return [[[VLDateNoTime alloc] initWithDays:0] autorelease];
}

+ (BOOL)isEmpty:(VLDateNoTime *)date {
	return !date || (date.days == 0);
}

- (NSString *)toString {
	static NSDateFormatter *_formatter;
	if(!_formatter) {
		_formatter = [[NSDateFormatter alloc] init];
		_formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		_formatter.timeStyle = NSDateFormatterNoStyle;
		_formatter.dateFormat = @"yyyy-MM-dd";
	}
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:
					(self.days - (kVLDateTicksUntil1970/kVLDateTicksPerDay)) * kVLDateSecondsPerDay];
	NSString *res = [_formatter stringFromDate:date];
	[date release];
	return res;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %x %@", NSStringFromClass([self class]), (unsigned int)self,
			[self toString]];
}

+ (VLDateNoTime *)fromString:(NSString *)sDate {
	if(!sDate || !sDate.length)
		return [VLDateNoTime empty];
	static NSDateFormatter *_formatter;
	if(!_formatter) {
		_formatter = [[NSDateFormatter alloc] init];
		_formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		_formatter.timeStyle = NSDateFormatterNoStyle;
		_formatter.dateFormat = @"yyyy-MM-dd";
	}
	NSDate *date = [_formatter dateFromString:sDate];
	if(!date)
		return [VLDateNoTime empty];
	int days = ([date timeIntervalSince1970] + (kVLDateTicksUntil1970/kVLDateTicksPerSecond)) / 86400;
	return [[[VLDateNoTime alloc] initWithDays:days] autorelease];
}

@end


