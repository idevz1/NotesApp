
#import <UIKit/UIKit.h>
#import "VLMessaging.h"

@interface VLBaseControl : UIControl
{
@private
	BOOL _initialized;
	VLMessenger *_msgrUpdateView;
}

- (void)initialize;

- (void)updateViewAsync;
- (void)updateViewNow;

- (void)onUpdateView;

@end
