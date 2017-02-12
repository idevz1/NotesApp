
#import <Foundation/Foundation.h>
#import "VLMessaging.h"

@interface VLTabBarController : UITabBarController
{
@private
	BOOL _initialized;
	VLMessenger *_msgrUpdateView;
}

- (void)initialize;

- (void)updateViewAsync;
- (void)updateViewNow;

- (void)onUpdateView;

- (void)releaseViews;

@end
