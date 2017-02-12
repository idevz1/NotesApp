
#import "VL_Collections_Categories.h"
#import "VLCommon.h"
#import "VL_NSObjects_Categories.h"

@implementation NSArray(VL_NSArray_Categories)

- (NSString *)stringValueAtIndex:(NSUInteger)index defaultVal:(NSString *)defaultVal {
	id val = [self objectAtIndex:index];
	NSString *sVal = ObjectCast(val, NSString);
	if(sVal)
		return sVal;
	NSNumber *num = ObjectCast(val, NSNumber);
	if(num)
		return [num stringValue];
	return defaultVal;
}

- (int)intValueAtIndex:(NSUInteger)index defaultVal:(int)defaultVal {
	id val = [self objectAtIndex:index];
	NSNumber *num = ObjectCast(val, NSNumber);
	if(num)
		return [num intValue];
	NSString *sNum = ObjectCast(val, NSString);
	if(sNum)
		return [sNum intValue];
	return defaultVal;
}

- (int64_t)int64ValueAtIndex:(NSUInteger)index defaultVal:(int64_t)defaultVal {
	id val = [self objectAtIndex:index];
	NSNumber *num = ObjectCast(val, NSNumber);
	if(num)
		return [num longLongValue];
	NSString *sNum = ObjectCast(val, NSString);
	if(sNum)
		return [sNum longLongValue];
	return defaultVal;
}

@end




@implementation NSMutableArray(VL_NSMutableArray_Categories)

- (void)reverse
{
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j)
	{
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
        i++;
        j--;
    }
}

- (void)moveObjectFromIndex:(int)fromIndex toIndex:(int)toIndex
{
	if(fromIndex == toIndex)
		return;
	id obj = [self objectAtIndex:fromIndex];
	[obj retain];
	[self removeObjectAtIndex:fromIndex];
	[self insertObject:obj atIndex:toIndex];
	[obj release];
}

- (void)moveObject:(id)obj toIndex:(int)index
{
	NSUInteger lastIndex = [self indexOfObject:obj];
	if(lastIndex == NSNotFound || lastIndex == index)
		return;
	[obj retain];
	[self removeObjectAtIndex:lastIndex];
	[self insertObject:obj atIndex:index];
	[obj release];
}

- (void)replaceObject:(id)obj1 withObject:(id)obj2
{
	NSUInteger index = [self indexOfObject:obj1];
	if(index == NSNotFound)
		return;
	[self replaceObjectAtIndex:index withObject:obj2];
}

@end



@implementation NSDictionary(VL_NSDictionary_Categories)

- (id)objectForKeyExt:(id)key
{
	id obj = [self objectForKey:key];
	if(obj)
		return obj;
	NSNumber *numKey = ObjectCast(key, NSNumber);
	if(numKey)
	{
		NSString *sKey = [numKey stringValue];
		obj = [self objectForKey:sKey];
		if(obj)
			return obj;
	}
	return nil;
}

- (int)intValueForKey:(id)key defaultVal:(int)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num intValue];
		NSString *sNum = ObjectCast(val, NSString);
		if(sNum) {
			if(sNum.length == 1) {
				if([sNum characterAtIndex:0] == 1)
					return 1;
				if([sNum characterAtIndex:0] == 0)
					return 0;
			}
			return [sNum intValue];
		}
	}
	return defaultVal;
}

- (int64_t)int64ValueForKey:(id)key defaultVal:(int64_t)defaultVal {
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num longLongValue];
		NSString *sNum = ObjectCast(val, NSString);
		if(sNum) {
			if(sNum.length == 1) {
				if([sNum characterAtIndex:0] == 1)
					return 1;
				if([sNum characterAtIndex:0] == 0)
					return 0;
			}
			return [sNum longLongValue];
		}
	}
	return defaultVal;
}

- (float)floatValueForKey:(id)key defaultVal:(float)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num floatValue];
		NSString *sNum = ObjectCast(val, NSString);
		if(sNum)
			return [sNum floatValue];
	}
	return defaultVal;
}

- (double)doubleValueForKey:(id)key defaultVal:(double)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num doubleValue];
		NSString *sNum = ObjectCast(val, NSString);
		if(sNum)
			return [sNum doubleValue];
	}
	return defaultVal;
}

- (BOOL)boolValueForKey:(id)key defaultVal:(BOOL)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSString *sNum = ObjectCast(val, NSString);
		if(sNum) {
			if(sNum.length == 1) {
				if([sNum characterAtIndex:0] == 1)
					return YES;
				if([sNum characterAtIndex:0] == 0)
					return NO;
			}
			return [sNum boolValue];
		}
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num boolValue];
	}
	return defaultVal;
}

- (NSString*)stringValueForKey:(id)key defaultVal:(NSString*)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSString *sVal = ObjectCast(val, NSString);
		if(sVal)
			return sVal;
		NSNumber *num = ObjectCast(val, NSNumber);
		if(num)
			return [num stringValue];
	}
	return defaultVal;
}

- (NSDate*)dateValueForKey:(id)key defaultVal:(NSDate*)defaultVal
{
	id val = [self objectForKeyExt:key];
	if(val)
	{
		NSDate *dtVal = ObjectCast(val, NSDate);
		if(dtVal)
			return dtVal;
		NSString *sVal = ObjectCast(val, NSString);
		if(sVal)
		{
			NSDate *dt = [NSDate makeWithString:sVal];
			if(dt)
				return dt;
		}
	}
	return defaultVal;
}

- (NSDictionary*)dictionaryValueForKey:(id)key defaultIsEmpty:(BOOL)defaultIsEmpty
{
	id val = [self objectForKeyExt:key];
	NSDictionary *valDict = ObjectCast(val, NSDictionary);
	if(!valDict && defaultIsEmpty)
		return [NSDictionary dictionary];
	return valDict;
}

- (NSArray*)arrayValueForKey:(id)key defaultIsEmpty:(BOOL)defaultIsEmpty
{
	id val = [self objectForKeyExt:key];
	NSArray *valArr = ObjectCast(val, NSArray);
	if(!valArr)
	{
		// Check if tere is single value NSDictionary
		NSDictionary *valDict0 = ObjectCast(val, NSDictionary);
		if(valDict0)
			valArr = [NSArray arrayWithObject:valDict0];
	}
	if(!valArr && defaultIsEmpty)
		return [NSArray array];
	return valArr;
}

@end



@implementation NSMutableDictionary(VL_NSMutableDictionary_Categories)

- (void)changeKey:(id)keyCur toKey:(id)keyNew
{
	id obj = [self objectForKey:keyCur];
	if(!obj)
		return;
	[obj retain];
	[self removeObjectForKey:keyCur];
	[self setObject:obj forKey:keyNew];
	[obj release];
}

@end



