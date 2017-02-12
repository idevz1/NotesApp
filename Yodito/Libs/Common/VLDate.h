
#import <Foundation/Foundation.h>

@class VLTime;

#define kVLDateTicksPerMillisecond ((int64_t)10000)
#define kVLDateTicksPerSecond ((int64_t)10000000)
#define kVLDateTicksPerMinute ((int64_t)(kVLDateTicksPerSecond * 60))
#define kVLDateTicksUntil1970 ((int64_t)(kVLDateTicksPerMinute * 1035593280))

#define kVLDateTicksPerHour ((int64_t)(kVLDateTicksPerMinute * 60))
#define kVLDateTicksPerDay ((int64_t)(kVLDateTicksPerHour * 24))
#define kVLDateHoursPerDay 24
#define kVLDateSecondsPerDay 86400
#define kVLDateMinutesPerHour 60
#define kVLDateSecondsPerMinute 60
#define kVLDateSecondsPerHour 3600
#define kVLDateMillisecondsPerSecond 1000

@interface VLDate : NSObject <NSCopying, NSCoding>
{
@private
	int64_t _ticks;
}

@property(nonatomic,readonly) int64_t ticks;
@property(nonatomic,readonly) int year;
@property(nonatomic,readonly) int month;
@property(nonatomic,readonly) int day;
@property(nonatomic,readonly) int hours;
@property(nonatomic,readonly) int minutes;
@property(nonatomic,readonly) int seconds;
@property(nonatomic,readonly) int milliSeconds;
@property(nonatomic,readonly) BOOL isEmpty;

- (id)initWithTicks:(int64_t)ticks;
- (id)initWithNSDate:(NSDate*)other;
- (id)initWithYear:(int)year month:(int)mon day:(int)day;
- (id)initWithYear:(int)year month:(int)mon day:(int)day
			 hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec;
- (id)initWithYear:(int)year month:(int)mon day:(int)day
			 hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec timeZone:(NSTimeZone *)tz;
- (id)initWithYear:(int)year month:(int)mon day:(int)day timeZone:(NSTimeZone *)tz;

- (int)getDatePart:(int)part;
- (NSString *)toString;
- (NSString *)toStringWithTimezone:(NSTimeZone*)timezone;
- (NSDate*)toNSDate;
- (NSString*)toStringEnglishDate;
+ (VLDate*)now;
+ (VLDate*)date;
+ (VLDate*)fromNSDate:(NSDate*)other;
+ (VLDate*)fromString:(NSString*)str;
+ (BOOL)isLeapYear:(int)year;
- (int64_t)ticksSinceDate:(VLDate*)other;
- (NSComparisonResult)compare:(VLDate*)other;
- (BOOL)isEqual:(id)object;
- (id)copyWithZone:(NSZone *)zone;
+ (VLDate*)empty;
+ (BOOL)isEmpty:(VLDate*)date;
- (VLDate *)dateByAppendingTimeInterval:(NSTimeInterval)timeInterval;
- (VLDate*)dateByAppendingDays:(int)days;
- (VLDate*)dateByAppendingMonths:(int)months;
+ (NSString*)daytimeStrFromTimeInterval:(NSTimeInterval)time;
+ (int64_t)ticksFromYear:(int)year month:(int)mon day:(int)day;
+ (int64_t)ticksFromYear:(int)year month:(int)mon day:(int)day
				   hours:(int)hour minutes:(int)mint seconds:(int)sec milliseconds:(int)msec;
- (NSTimeInterval)timeIntervalSinceDate:(VLDate *)anotherDate;
- (int)gregorianYearWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianMonthWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianDayWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianWeekdayWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianHourWithTimezone:(NSTimeZone*)timezone;
- (int)gregorianMinuteWithTimezone:(NSTimeZone*)timezone;
- (int)yearWithTimezone:(NSTimeZone*)timezone;
- (int)monthWithTimezone:(NSTimeZone*)timezone;
- (int)dayWithTimezone:(NSTimeZone*)timezone;
- (int)weekdayWithTimezone:(NSTimeZone*)timezone;
- (int)hourWithTimezone:(NSTimeZone*)timezone;
- (int)minuteWithTimezone:(NSTimeZone*)timezone;
- (VLDate *)dateByRoundingToMinutes;
- (VLDate *)dateByRoundingToMinutesFloor;
- (VLDate *)dateBySettingTime:(VLTime *)time timezone:(NSTimeZone*)timezone;
- (VLDate *)dateByResettingTimeWimezone:(NSTimeZone*)timezone;
- (int)diffDaysFrom:(VLDate *)other timezone:(NSTimeZone *)timezone;

@end

