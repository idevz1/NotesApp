
#import "VLAccelerometer.h"
/*
#define kDefaultUpdateInterval 0.25

@implementation VLAccelerometer

@synthesize lastAcceleration = _lastAcceleration;

+ (VLAccelerometer*)shared
{
	static VLAccelerometer *_shared;
	if(!_shared)
		_shared = [[VLAccelerometer alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_motionManager = [[CMMotionManager alloc] init];
	}
	return self;
}

- (BOOL)isAvailable
{
	return [_motionManager isAccelerometerAvailable];
}

- (BOOL)isActive
{
	return [_motionManager isAccelerometerActive];
}

- (void)startUpdates
{
	if(!_accelerometer)
	{
		_accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
		_accelerometer.delegate = self;
		_accelerometer.updateInterval = kDefaultUpdateInterval;
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	[_lastAcceleration release];
	_lastAcceleration = [acceleration retain];
}

- (UIInterfaceOrientation)deviceOrientation
{
	UIAcceleration *accel = self.lastAcceleration;
	if(accel)
	{
		UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
		float ratio = 0.40;
		if(accel.y < -ratio)
			orient = UIInterfaceOrientationPortrait;
		else if(accel.y > ratio)
			orient = UIInterfaceOrientationPortraitUpsideDown;
		else if(accel.x < -ratio)
			orient = UIInterfaceOrientationLandscapeRight;
		else if(accel.x > ratio)
			orient = UIInterfaceOrientationLandscapeLeft;
		return orient;
	}
	return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)dealloc
{
	[_accelerometer release];
	[_lastAcceleration release];
	[_motionManager release];
	[super dealloc];
}

@end
*/
