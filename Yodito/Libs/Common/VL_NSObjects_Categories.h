
#import <Foundation/Foundation.h>


@interface NSError(VL_NSError_Category)

+ (NSError *)makeWithText:(NSString *)text code:(int)code;
+ (NSError *)makeWithText:(NSString *)text;
+ (NSError *)makeCancelWithText:(NSString *)text;
+ (NSError *)makeCancel;
- (BOOL)isCancel;

@end


@interface NSDate(VL_NSDate_Category)

- (NSString*)timeToLocalizedStringLocal;
- (NSString*)dateToLocalizedStringShortLocal;
- (NSString*)toString;
+ (NSDate*)makeWithString:(NSString*)str;
- (NSString*)toStringRFC2822WithTimezone:(NSTimeZone*)timezone;
- (NSString*)toStringRFC2822;
+ (NSDate*)makeWithStringRFC2822:(NSString*)str;
+ (NSDate*)empty;
+ (BOOL)isEmpty:(NSDate*)date;
- (BOOL)isSameDayAs:(NSDate*)date timezone:(NSTimeZone*)timezone;

// WARNING! May work slow:
- (int)diffDaysFrom:(NSDate*)other timezone:(NSTimeZone*)timezone;
- (int)diffMonthsFrom:(NSDate*)other timezone:(NSTimeZone*)timezone;
//---------------------------

- (int)gregorianYearWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianMonthWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianDayWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianWeekdayWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianHourWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianMinuteWithTimezone:(NSTimeZone*)timezone;
+ (NSDate*)gregorianDateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second timezone:(NSTimeZone*)timezone;
+ (NSDate*)gregorianDateWithYear:(int)year month:(int)month day:(int)day timezone:(NSTimeZone*)timezone;
- (int64_t)secondsFromMidnightWithTimezone:(NSTimeZone *)timezone;
- (NSDate *)dateByAppendingDays:(int)days;
- (NSDate *)dateByAppendingMonths:(int)months;

@end


