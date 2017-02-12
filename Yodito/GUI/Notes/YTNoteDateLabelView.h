
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTNoteDateLabelView : YTBaseView {
@private
	VLLabel *_label;
}

- (CGSize)sizeThatFits:(CGSize)size;

@end

