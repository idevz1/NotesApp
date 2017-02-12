
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTEmptyNotesView : YTBaseView {
@private
	float _topIndent;
	UIImageView *_ivBack;
	UIImageView *_ivIcon;
	UIImageView *_ivTexts;
}

@property(nonatomic,assign) float topIndent;

- (void)setTopIndent:(float)topIndent animated:(BOOL)animated;

@end

