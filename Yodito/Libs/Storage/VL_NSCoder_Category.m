
#import "VL_NSCoder_Category.h"
#import "../Common/Classes.h"

@implementation NSCoder(VL_NSCoder_Category)

- (NSString*)decodeStringWithKey:(NSString*)key defaultValue:(NSString*)defaultValue
{
	if(![self containsValueForKey:key])
		return defaultValue;
	id obj = [self decodeObjectForKey:key];
	NSString *str = ObjectCast(obj, NSString);
	if(str)
		return str;
	return defaultValue;
}

- (void)encodeDate:(NSDate*)date forKey:(NSString*)key
{
	if(date)
		[self encodeDouble:[date timeIntervalSinceReferenceDate] forKey:key];
}
- (NSDate*)decodeDateWithKey:(NSString*)key defaultValue:(NSDate*)defaultValue
{
	if(![self containsValueForKey:key])
		return defaultValue;
	NSTimeInterval secnds = [self decodeDoubleForKey:key];
	NSDate *result = [NSDate dateWithTimeIntervalSinceReferenceDate:secnds];
	return result;
}
- (NSDate*)decodeDateWithDefaultRefDateWithKey:(NSString*)key
{
	return [self decodeDateWithKey:key defaultValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
}

@end
