
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTNoteLocationLabelView : YTBaseView {
@private
	VLLabel *_label;
	VLLinkLabel *_labelLink;
}

- (CGSize)sizeThatFits:(CGSize)size;

@end
