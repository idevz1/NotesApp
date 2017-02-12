
#import "VL_NSUserDefaults_Category.h"
#import "../Common/Classes.h"

@implementation NSUserDefaults(VL_NSUserDefaults_Category)

- (void)VL_setObject:(id)value forKey:(NSString*)key
{
	id obj = [self objectForKey:key];
	if(obj)
	{
		if(value)
		{
			BOOL isEqual = NO;
			if([obj class] == [value class])
			{
				if([obj respondsToSelector:@selector(isEqual:)])
					isEqual = [obj isEqual:value];
			}
			if(!isEqual)
			{
				[self setObject:value forKey:key];
				[self synchronize];
			}
		}
		else
		{
			[self removeObjectForKey:key];
			[self synchronize];
		}
	}
	else
	{
		if(value)
		{
			[self setObject:value forKey:key];
			[self synchronize];
		}
	}
}

- (void)VL_removeObjectForKey:(NSString*)key
{
	if([self objectForKey:key])
	{
		[self removeObjectForKey:key];
		[self synchronize];
	}
}

- (int)VL_intValueForKey:(NSString*)key
		  possibleValues:(NSArray*)possibleValues
			defaultValue:(int)defaultValue
{
	int result = defaultValue;
	NSNumber *numSaved = ObjectCast([self objectForKey:key], NSNumber);
	if(numSaved)
		result = [numSaved intValue];
	for(NSNumber *num in possibleValues)
	{
		if([num intValue] == result)
		{
			if(!numSaved)
			{
				[self setObject:num forKey:key];
				[self synchronize];
			}
			return result;
		}
	}
	result = defaultValue;
	if(!numSaved || [numSaved intValue] != result)
	{
		[self setObject:[NSNumber numberWithInt:result] forKey:key];
		[self synchronize];
	}
	return result;
}

- (void)VL_setIntValue:(int)intValue
				forKey:(NSString*)key
		possibleValues:(NSArray*)possibleValues
		  defaultValue:(int)defaultValue
{
	BOOL found = NO;
	for(NSNumber *num in possibleValues)
		if([num intValue] == intValue)
			found = YES;
	if(!found)
		intValue = defaultValue;
	if([self VL_intValueForKey:key possibleValues:possibleValues defaultValue:defaultValue] != intValue)
	{
		[self setObject:[NSNumber numberWithInt:intValue] forKey:key];
		[self synchronize];
	}
}

- (BOOL)VL_boolValueForKey:(NSString*)key
			  defaultValue:(BOOL)defaultValue
{
	BOOL result = defaultValue;
	NSNumber *numSaved = ObjectCast([self objectForKey:key], NSNumber);
	if(numSaved)
		result = [numSaved boolValue];
	if(!numSaved || [numSaved boolValue] != result)
	{
		[self setObject:[NSNumber numberWithBool:result] forKey:key];
		[self synchronize];
	}
	return result;
}

- (void)VL_setBoolValue:(BOOL)boolValue
				 forKey:(NSString*)key
{
	NSNumber *numSaved = ObjectCast([self objectForKey:key], NSNumber);
	if(!numSaved || [numSaved boolValue] != boolValue)
	{
		[self setObject:[NSNumber numberWithBool:boolValue] forKey:key];
		[self synchronize];
	}
}

- (NSString*)VL_stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue
{
	id obj = [self objectForKey:key];
	NSString *str = ObjectCast(obj, NSString);
	return str ? str : defaultValue;
}

@end


