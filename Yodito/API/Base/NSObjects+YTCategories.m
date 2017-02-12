
#import "NSObjects+YTCategories.h"
#import "../../Libs/Classes.h"

#define kYTDefaultDateFormat1 @"yyyy-MM-dd HH:mm:ss"
#define kYTDefaultDateFormat2 @"yyyy-MM-dd"

@implementation VLDate (YTCategory)

- (NSString *)yoditoToString {
	if([VLDate isEmpty:self])
		return @"0000-00-00 00:00:00";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	dateFormatter.dateFormat = kYTDefaultDateFormat1;
	NSString *res = [dateFormatter stringFromDate:[self toNSDate]];
	[dateFormatter release];
	return res;
}

+ (VLDate *)yoditoDateWithString:(NSString *)str format:(NSString *)format {
	if([str rangeOfString:@"0000-00-00"].length)
		return [VLDate empty];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	dateFormatter.dateFormat = format;
	NSDate *res = [dateFormatter dateFromString:str];
	[dateFormatter release];
	return [VLDate fromNSDate:res];
}

+ (VLDate *)yoditoDateWithString:(NSString *)str {
	if(   [str isEqual:@"0000-00-00 00:00:00"]
	   || [str isEqual:@"0000-00-00"]
	   )
		return [VLDate empty];
	VLDate *res = [VLDate yoditoDateWithString:str format:kYTDefaultDateFormat1];
	if(!res)
		res = [VLDate yoditoDateWithString:str format:kYTDefaultDateFormat2];
	if(res.ticks <= 0)
		res = [VLDate empty];
	return res;
}

@end



@implementation VLDateNoTime (YTCategory)

- (NSString *)yoditoToString {
	if([VLDateNoTime isEmpty:self])
		return @"0000-00-00";
	return [self toString];
}

+ (VLDateNoTime *)yoditoFromString:(NSString *)str {
	NSRange range = [str rangeOfString:@":"];
	if(range.length) {
		range = [str rangeOfString:@" "];
		if(range.length) {
			str = [str substringToIndex:range.location];
		}
	}
	if(!str || [str isEqual:@"0000-00-00"])
		return [VLDateNoTime empty];
	VLDateNoTime *res = [VLDateNoTime fromString:str];
	if(!res)
		return [VLDateNoTime empty];
	return res;
}

@end



@implementation NSDictionary(YTCategory)

- (BOOL)yoditoBoolValueForKey:(id)key defaultVal:(BOOL)defaultVal {
	BOOL res = [self boolValueForKey:key defaultVal:defaultVal];
	return res;
}

- (VLDate *)yoditoDateValueForKey:(id)key defaultVal:(VLDate *)defaultVal {
	id val = [self objectForKey:key];
	NSString *sVal = ObjectCast(val, NSString);
	if(sVal) {
		VLDate *date = [VLDate yoditoDateWithString:sVal];
		if(date)
			return date;
	}
	/*VLDate *date = [self dateValueForKey:key defaultVal:nil];
	if(date)
		return date;*/
	return nil;
}

@end



@implementation VLGuid(YTCategory)

- (NSString *)yoditoToString {
	return [[self toString] uppercaseString];
}

@end



@implementation NSString(YTCategory)

- (NSString *)yoditoCutServerUrl {
	NSRange range = [self rangeOfString:@"?operation="];
	if(range.length) {
		NSString *res = [self stringByReplacingCharactersInRange:NSMakeRange(0, range.location+11) withString:@"..."];
		return res;
	}
	range = [self rangeOfString:@"php"];
	if(range.length) {
		NSString *res = [self stringByReplacingCharactersInRange:NSMakeRange(0, range.location+3) withString:@"..."];
		return res;
	}
	return self;
}

@end



