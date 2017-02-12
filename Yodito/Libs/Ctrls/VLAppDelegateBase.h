
#import <Foundation/Foundation.h>

@class VLDelegate;
@class VLMessenger;

@interface VLAppDelegateBase : UIResponder <UIApplicationDelegate>
{
@private
	UIViewController *_rootViewController;
	VLDelegate *_ntfrWillAnimateRotationToInterfaceOrientation;
	VLMessenger *_msgrApplicationDidBecomeActive;
	VLDelegate *_ntfrDidReceiveMemoryWarning;
	NSUInteger _networkActivityIndicatorLevel;
	VLMessenger *_msgrCurrentLocaleDidChange;
}

@property(nonatomic, retain) UIViewController *rootViewController;
@property(nonatomic, readonly) VLDelegate *ntfrWillAnimateRotationToInterfaceOrientation;
@property(nonatomic, readonly) VLMessenger *msgrApplicationDidBecomeActive;
@property(nonatomic, readonly) VLDelegate *ntfrDidReceiveMemoryWarning;
@property(nonatomic, readonly) VLMessenger *msgrCurrentLocaleDidChange;

+ (VLAppDelegateBase*)sharedAppDelegateBase;

- (UIViewController*)topModalViewController;
- (void)dismissModalViewController:(UIViewController*)vc animated:(BOOL)animated;

+ (NSString*)applicationInstanceIdentifier;

- (void)raiseWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

- (void)startAnimateNetworkActivityIndicator;
- (void)stopAnimateNetworkActivityIndicator;

@end
