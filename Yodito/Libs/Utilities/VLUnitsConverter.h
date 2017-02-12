
#import <Foundation/Foundation.h>

#define kVLUnitsMetersPerMile 1609.344 // international
//#define kVLUnitsMetersPerMile 1609.347219 // US survey
//#define kVLUnitsMetersPerMile 1852.0 // nautical

@interface VLUnitsConverter : NSObject

+ (float)milesPerHourFromMetersPerSecond:(float)metersPerSecond;
+ (float)metersPerSecondFromMilesPerHour:(float)milesPerHour;
+ (float)milesFromMeters:(float)meters;
+ (float)metersFromMiles:(float)miles;

@end
