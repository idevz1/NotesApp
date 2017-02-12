
#import <Foundation/Foundation.h>

@class VLDate;

@interface VLTime : NSObject <NSCopying> {
@private
	int64_t _ticks;
}

@property(nonatomic, readonly) int64_t ticks;
@property(nonatomic, readonly) int hours;
@property(nonatomic, readonly) int minutes;
@property(nonatomic, readonly) int seconds;

- (id)initWithTicks:(int64_t)ticks;
- (id)initWithDate:(VLDate *)date timezone:(NSTimeZone *)tz;
- (id)initWithHours:(int)nHours minutes:(int)nMinutes seconds:(int)nSeconds;
- (NSComparisonResult)compare:(VLTime *)other;
- (BOOL)isEqual:(id)object;
- (id)copyWithZone:(NSZone *)zone;
+ (VLTime *)empty;
+ (BOOL)isEmpty:(VLTime *)time;
- (NSString *)toString;
+ (VLTime *)fromString:(NSString *)sTime;

@end

