
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTTableSectionHeader : YTBaseView {
@private
	UIImageView *_imageBack;
	VLLabel *_labelTitle;
}

@property(nonatomic, readonly) VLLabel *labelTitle;

@end

