
#import <Foundation/Foundation.h>

@class VLDate;

@interface VLDateNoTime : NSObject {
@private
	int _days;
}

@property(nonatomic, readonly) int days;
@property(nonatomic, readonly) int year;
@property(nonatomic, readonly) int month;
@property(nonatomic, readonly) int day;

- (id)initWithDays:(int)days;
- (id)initWithYear:(int)year month:(int)month day:(int)day;
- (id)initWithNSDate:(NSDate *)date timezone:(NSTimeZone *)tz;
- (id)initWithNSDate:(NSDate *)date;
- (id)initWithDate:(VLDate *)date timezone:(NSTimeZone *)tz;
- (NSComparisonResult)compare:(VLDateNoTime *)other;
- (BOOL)isEqual:(id)object;
- (id)copyWithZone:(NSZone *)zone;
+ (VLDateNoTime *)empty;
+ (BOOL)isEmpty:(VLDateNoTime *)date;
- (NSString *)toString;
+ (VLDateNoTime *)fromString:(NSString *)sDate;

@end

