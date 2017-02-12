
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTNoteCellTextView : YTBaseView {
@private
	NSString *_textOrig;
	NSString *_textCapital;
	NSString *_textContent;
	VLLabel *_labelCapital;
	VLLabel *_labelContent;
	UIFont *_fontCapital;
	UIFont *_fontContext;
}

- (void)setText:(NSString *)text;
- (void)setFontCapital:(UIFont *)fontCapital fontContext:(UIFont *)fontContext;

@end

