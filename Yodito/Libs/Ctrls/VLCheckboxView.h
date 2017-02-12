
#import <Foundation/Foundation.h>
#import "VLBaseView.h"

@interface VLCheckboxView : VLBaseView
{
@private
	BOOL _checked;
	VLMessenger *_msgrCheckedChanged;
}

@property(nonatomic,assign,setter = setChecked:) BOOL checked;
@property(nonatomic,readonly) VLMessenger *msgrCheckedChanged;

- (UIImage*)imageUnchecked;
- (UIImage*)imageChecked;

@end
