
#import "VLLocationManager.h"
#import "../Logic/Classes.h"


@interface VLLocationManager() 

- (void)didLocationChange;

@end


@implementation VLLocationManager

@synthesize msgrLocationChanged = _msgrLocationChanged;
@synthesize dlgtLocationChanged = _dlgtLocationChanged;
@dynamic isLocation;
@synthesize updatingLocationStarted = _updatingLocationStarted;

+ (VLLocationManager*)shared
{
	static VLLocationManager *_shared;
	if(!_shared)
		_shared = [[VLLocationManager alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_msgrLocationChanged = [[VLMessenger alloc] init];
		_msgrLocationChanged.owner = self;
		_dlgtLocationChanged = [[VLDelegate alloc] init];
		_dlgtLocationChanged.owner = self;
		self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		self.distanceFilter = 10;
		[self setDelegate:self];
		[self didLocationChange];
	}
	return self;
}

- (void)initialize
{
	
}

- (void)startUpdatingLocationWithResultBlock:(void (^)())resultBlock
{
	if(_updatingLocationStarted) {
		resultBlock();
		return;
	}
	_updateLocationResultAcquired = NO;
	[self startUpdatingLocation];
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL
	{
		return !(_updatingLocationStarted && !_updateLocationResultAcquired);
	}
	ignoringTouches:YES completeBlock:^
	{
		resultBlock();
	}];
}

- (void)startUpdatingLocation
{
	if(_updatingLocationStarted)
		return;
	_updatingLocationStarted = YES;
	[super startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
	if(!_updatingLocationStarted)
		return;
	_updatingLocationStarted = NO;
	[super stopUpdatingLocation];
}

- (CLLocation*)getLocation
{
	CLLocation* res = nil;
	res = [super location];
	if(res)
		return res;
	return res;
}

- (BOOL)isLocation
{
	return ([self getLocation] != nil);
}

- (void)didLocationChange
{
	[_msgrLocationChanged postMessage];
}

- (void)refresh
{
	[self didLocationChange];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	_updateLocationResultAcquired = YES;
	[self didLocationChange];
	VLLocationManagerArgs *args = [[[VLLocationManagerArgs alloc] init] autorelease];
	args.locationOld = oldLocation;
	args.locationNew = newLocation;
	[_dlgtLocationChanged sendMessage:self withArgs:args];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	_updateLocationResultAcquired = YES;
	[self didLocationChange];
}

#define toRadian(deg) ((deg) * M_PI / 180)

+ (CLLocationDistance)distanceFromLocation:(CLLocationCoordinate2D)loc1
								toLocation:(CLLocationCoordinate2D)loc2
{
	double latitudeA = loc1.latitude;
	double longitudeA = loc1.longitude;
	double latitudeB = loc2.latitude;
	double longitudeB = loc2.longitude;
	
	double R = 6371.0 * 1000.0;
    double dLat = toRadian(latitudeB - latitudeA);
    double dLon = toRadian(longitudeB - longitudeA);
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(toRadian(latitudeA)) * cos(toRadian(latitudeB)) *
	sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(MIN(1, sqrt(a)));
    double d = R * c;
    return d;
}

- (void)dealloc
{
	[self stopUpdatingLocation];
	[_msgrLocationChanged release];
	[_dlgtLocationChanged release];
	[_emulatedLocation release];
	[super dealloc];
}

@end



@implementation VLLocationManagerArgs

@synthesize locationNew = _locationNew;
@synthesize locationOld = _locationOld;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)dealloc {
	[_locationNew release];
	[_locationOld release];
	[super dealloc];
}

@end



