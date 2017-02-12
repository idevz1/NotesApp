
#import "VLTime.h"
#import "VLCommon.h"
#import "VLDate.h"

@implementation VLTime

@synthesize ticks = _ticks;
@synthesize hours = _hours;
@synthesize minutes = _minutes;
@synthesize seconds = _seconds;

- (id)initWithTicks:(int64_t)ticks {
	self = [super init];
	if(self) {
		_ticks = ticks;
	}
	return self;
}

- (id)initWithDate:(VLDate *)date timezone:(NSTimeZone *)tz {
	self = [super init];
	if(self) {
		long offsetSeconds = [tz secondsFromGMTForDate:[date toNSDate]];
		_ticks = (date.ticks + offsetSeconds * kVLDateTicksPerSecond) % kVLDateTicksPerDay;
	}
	return self;
}

- (id)initWithHours:(int)nHours minutes:(int)nMinutes seconds:(int)nSeconds {
	self = [super init];
	if(self) {
		_ticks = nHours*kVLDateTicksPerHour + nMinutes*kVLDateTicksPerMinute + nSeconds*kVLDateTicksPerSecond;
	}
	return self;
}

- (int)hours {
	return (_ticks / kVLDateTicksPerHour) % 24;
}

- (int)minutes {
	return (_ticks / kVLDateTicksPerMinute) % 60;
}

- (int)seconds {
	return (_ticks / kVLDateTicksPerSecond) % 60;
}

- (NSComparisonResult)compare:(VLTime *)other {
	if(self.ticks > other.ticks)
		return 1;
	else if(self.ticks < other.ticks)
		return -1;
	return 0;
}

- (BOOL)isEqual:(id)object {
	VLTime *other = ObjectCast(object, VLTime);
	if(!other)
		return NO;
	return [self compare:other] == 0;
}

- (id)copyWithZone:(NSZone *)zone {
	VLTime *other = [[VLTime allocWithZone:zone] initWithTicks:self.ticks];
	return other;
}

+ (VLTime *)empty {
	return [[[VLTime alloc] initWithTicks:0] autorelease];
}

+ (BOOL)isEmpty:(VLTime *)time {
	return !time || (time.ticks == 0);
}

- (NSString *)toString {
	return [NSString stringWithFormat:@"%02d:%02d:%02d", self.hours, self.minutes, self.seconds];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %x %02d:%02d:%02d", NSStringFromClass([self class]), (unsigned int)self,
			self.hours, self.minutes, self.seconds];
}

+ (VLTime *)fromString:(NSString *)sTime {
	if(!sTime || !sTime.length)
		return [VLTime empty];
	static NSDateFormatter *_formatter;
	if(!_formatter) {
		_formatter = [[NSDateFormatter alloc] init];
		_formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		_formatter.dateStyle = NSDateFormatterNoStyle;
		_formatter.dateFormat = @"HH:mm:ss";
	}
	NSDate *date = [_formatter dateFromString:sTime];
	if(!date)
		return [VLTime empty];
	int64_t ticks = [date timeIntervalSinceReferenceDate] * kVLDateTicksPerSecond;
	ticks = ticks % kVLDateTicksPerDay;
	if(ticks < 0)
		ticks = ticks + kVLDateTicksPerDay;
	return [[[VLTime alloc] initWithTicks:ticks] autorelease];
}

@end

