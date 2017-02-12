
#import "VLDbCommon.h"

#define kDefaultDateFormat @"yyyy-MM-dd HH:mm:ss"

@implementation VLDbCommon

+ (NSString *)stringFromDate:(VLDate *)date {
	if([VLDate isEmpty:date])
		return @"0000-00-00 00:00:00";
	static NSDateFormatter *_dateFormatter;
	if(!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		_dateFormatter.dateFormat = kDefaultDateFormat;
	}
	NSString *res = [_dateFormatter stringFromDate:[date toNSDate]];
	return res;
}

+ (VLDate *)dateFromString:(NSString *)sDate {
	if(   [sDate isEqual:@"0000-00-00 00:00:00"]
	   || [sDate isEqual:@"0000-00-00"]
	   )
		return [VLDate empty];
	static NSDateFormatter *_dateFormatter;
	if(!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		_dateFormatter.dateFormat = kDefaultDateFormat;
	}
	NSDate *res = [_dateFormatter dateFromString:sDate];
	return [VLDate fromNSDate:res];
}

+ (NSString *)stringFromDateNoTime:(VLDateNoTime *)date {
	if([VLDateNoTime isEmpty:date])
		return @"0000-00-00";
	return [date toString];
}

+ (VLDateNoTime *)dateNoTimeFromString:(NSString *)sDate {
	if(   [sDate isEqual:@"0000-00-00"]
	   || [sDate isEqual:@"0000-00-00 00:00:00"]
	   )
		return [VLDateNoTime empty];
	return [VLDateNoTime fromString:sDate];
}

+ (NSString *)stringFromTime:(VLTime *)time {
	return [time toString];
}

+ (VLTime *)timeFromString:(NSString *)sTime {
	return [VLTime fromString:sTime];
}

@end
