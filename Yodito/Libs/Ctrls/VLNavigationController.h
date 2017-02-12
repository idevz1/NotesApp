
#import <Foundation/Foundation.h>
#import "VLMessaging.h"

@interface VLNavigationController : UINavigationController
{
@private
	BOOL _initialized;
	VLMessenger *_msgrUpdateView;
	UIViewController *_lastTopVC;
}

- (void)initialize;

- (void)updateViewAsync;
- (void)updateViewNow;

- (void)onUpdateView;

- (void)releaseViews;

@end
