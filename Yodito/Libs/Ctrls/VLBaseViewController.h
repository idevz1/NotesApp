
#import <Foundation/Foundation.h>
#import "VLMessaging.h"

@interface VLBaseViewController : UIViewController
{
@private
	BOOL _initialized;
	Class _viewClass;
	VLMessenger *_msgrUpdateView;
}

- (id)initWithViewClass:(Class)viewClass;

- (void)initialize;

- (void)updateViewAsync;
- (void)updateViewNow;

- (void)onUpdateView;

- (void)onBecomeTopAgainInNavigation;
- (void)onPopFromNavigation;

- (void)releaseViews;

@end
