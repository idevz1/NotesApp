
#import "VLUnitsConverter.h"

@implementation VLUnitsConverter

+ (float)milesPerHourFromMetersPerSecond:(float)metersPerSecond
{
	float result = metersPerSecond * 3600.0 / kVLUnitsMetersPerMile;
	return result;
}

+ (float)metersPerSecondFromMilesPerHour:(float)milesPerHour
{
	float result = milesPerHour * kVLUnitsMetersPerMile / 3600.0;
	return result;
}

+ (float)milesFromMeters:(float)meters
{
	float result = meters / kVLUnitsMetersPerMile;
	return result;
}

+ (float)metersFromMiles:(float)miles
{
	float result = miles * kVLUnitsMetersPerMile;
	return result;
}

@end

