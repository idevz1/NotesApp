
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Resources/Classes.h"

@interface YTNoteResourceRowView : YTBaseView {
@private
	VLLabel *_lbTitle;
	YTResourceView *_resourceView;
}

@property(nonatomic, readonly) YTResourceView *resourceView;

- (CGSize)sizeThatFits:(CGSize)size;
- (BOOL)isImageLoaded;
- (CGSize)sizeOfLoadedImage;
- (BOOL)isImageShown;

@end

