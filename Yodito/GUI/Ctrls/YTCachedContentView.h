
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTCachedContentView : YTBaseView {
@private
	Class _contentViewClass;
	YTBaseView *_contentView;
}

@property(nonatomic, readonly) YTBaseView *contentView;

- (void)setContentViewClass:(Class)contentViewClass;
- (void)checkContentViewCreated;

@end
