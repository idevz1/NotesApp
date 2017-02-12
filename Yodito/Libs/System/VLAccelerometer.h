
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

// Commented because Deprecated
/*
@interface VLAccelerometer : NSObject <UIAccelerometerDelegate>
{
@private
	CMMotionManager *_motionManager;
	UIAccelerometer *_accelerometer;
	UIAcceleration *_lastAcceleration;
}

@property(nonatomic, readonly) UIAcceleration *lastAcceleration;

+ (VLAccelerometer*)shared;

- (BOOL)isAvailable;
- (BOOL)isActive;
- (void)startUpdates;
- (UIInterfaceOrientation)deviceOrientation;

@end
*/