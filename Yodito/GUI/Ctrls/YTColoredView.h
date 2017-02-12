
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTColoredView : YTBaseView {
@private
	UIColor *_color;
}

@property(nonatomic, assign) UIColor *color;

@end
