
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTSyncButton : YTBaseView
{
@private
	UIImageView *_imageView;
	VLRotatableContentView *_rotationView;
	BOOL _isPressed;
	BOOL _isRotating;
	VLTimer *_timerRotating;
	float _lastAngle;
	NSTimeInterval _lastAngleUptime;
}

@property(nonatomic, assign) BOOL isRotating;

@end
