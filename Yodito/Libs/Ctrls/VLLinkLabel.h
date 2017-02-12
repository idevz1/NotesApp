
#import <UIKit/UIKit.h>
#import "VLBaseView.h"
#import "VLLabel.h"

@interface VLLinkLabel : VLBaseView
{
	VLLabel *_label;
	NSString *_urlLink;
	UIColor *_colorTouched;
	UIColor *_colorUntouched;
	VLMessenger *_msgrTapped;
	BOOL _touched;
}

@property(nonatomic, readonly) VLLabel *label;
@property(nonatomic, copy) NSString *urlLink;
@property(nonatomic, readonly) VLMessenger *msgrTapped;
@property(nonatomic, assign) UIColor *colorTouched;
@property(nonatomic, assign) UIColor *colorUntouched;

@end
