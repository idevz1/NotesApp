
#import <CoreLocation/CoreLocation.h>

@class VLMessenger;
@class VLDelegate;

@interface VLLocationManager : CLLocationManager <CLLocationManagerDelegate>
{
	VLMessenger *_msgrLocationChanged;
	VLDelegate *_dlgtLocationChanged;
	CLLocation *_emulatedLocation;
	BOOL _updatingLocationStarted;
	BOOL _updateLocationResultAcquired;
}

+ (VLLocationManager*)shared;

@property(nonatomic, readonly) VLMessenger *msgrLocationChanged;
@property(nonatomic, readonly) VLDelegate *dlgtLocationChanged;
@property(nonatomic, readonly) BOOL isLocation;
@property(nonatomic, readonly) BOOL updatingLocationStarted;

- (void)initialize;
- (void)startUpdatingLocationWithResultBlock:(void (^)())resultBlock;
- (CLLocation*)getLocation;
- (void)refresh;

+ (CLLocationDistance)distanceFromLocation:(CLLocationCoordinate2D)loc1
								toLocation:(CLLocationCoordinate2D)loc2;

@end



@interface VLLocationManagerArgs : NSObject {
@private
	CLLocation *_locationNew;
	CLLocation *_locationOld;
}

@property(nonatomic, retain) CLLocation *locationNew;
@property(nonatomic, retain) CLLocation *locationOld;

@end


