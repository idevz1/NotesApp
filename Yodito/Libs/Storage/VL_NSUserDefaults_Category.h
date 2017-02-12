
#import <Foundation/Foundation.h>

@interface NSUserDefaults(VL_NSUserDefaults_Category)

- (void)VL_setObject:(id)value forKey:(NSString*)key;
- (void)VL_removeObjectForKey:(NSString*)key;

- (int)VL_intValueForKey:(NSString*)key
		  possibleValues:(NSArray*)possibleValues
			defaultValue:(int)defaultValue;
- (void)VL_setIntValue:(int)intValue
				forKey:(NSString*)key
		possibleValues:(NSArray*)possibleValues
		  defaultValue:(int)defaultValue;

- (BOOL)VL_boolValueForKey:(NSString*)key
			  defaultValue:(BOOL)defaultValue;
- (void)VL_setBoolValue:(BOOL)boolValue
				 forKey:(NSString*)key;

- (NSString*)VL_stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue;

@end
