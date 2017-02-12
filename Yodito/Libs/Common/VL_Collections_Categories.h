
#import <Foundation/Foundation.h>

@interface NSArray(VL_NSArray_Categories)

- (NSString *)stringValueAtIndex:(NSUInteger)index defaultVal:(NSString *)defaultVal;
- (int)intValueAtIndex:(NSUInteger)index defaultVal:(int)defaultVal;
- (int64_t)int64ValueAtIndex:(NSUInteger)index defaultVal:(int64_t)defaultVal;

@end



@interface NSMutableArray(VL_NSMutableArray_Categories)

- (void)reverse;
- (void)moveObjectFromIndex:(int)fromIndex toIndex:(int)toIndex;
- (void)moveObject:(id)obj toIndex:(int)index;
- (void)replaceObject:(id)obj1 withObject:(id)obj2;

@end



@interface NSDictionary(VL_NSDictionary_Categories)

- (int)intValueForKey:(id)key defaultVal:(int)defaultVal;
- (int64_t)int64ValueForKey:(id)key defaultVal:(int64_t)defaultVal;
- (float)floatValueForKey:(id)key defaultVal:(float)defaultVal;
- (double)doubleValueForKey:(id)key defaultVal:(double)defaultVal;
- (BOOL)boolValueForKey:(id)key defaultVal:(BOOL)defaultVal;
- (NSString*)stringValueForKey:(id)key defaultVal:(NSString*)defaultVal;
- (NSDate*)dateValueForKey:(id)key defaultVal:(NSDate*)defaultVal;
- (NSDictionary*)dictionaryValueForKey:(id)key defaultIsEmpty:(BOOL)defaultIsEmpty;
- (NSArray*)arrayValueForKey:(id)key defaultIsEmpty:(BOOL)defaultIsEmpty;

@end



@interface NSMutableDictionary(VL_NSMutableDictionary_Categories)

- (void)changeKey:(id)keyCur toKey:(id)keyNew;

@end

