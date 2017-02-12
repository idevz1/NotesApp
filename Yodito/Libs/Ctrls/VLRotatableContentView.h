
#import <UIKit/UIKit.h>
#import "VLBaseView.h"

@interface VLRotatableContentView : VLBaseView
{
	UIView *_contentView;
	float _rotation;
}

@property(nonatomic, assign) float rotation;

- (id)initWithFrame:(CGRect)frame contentView:(UIView*)contentView;

@end



