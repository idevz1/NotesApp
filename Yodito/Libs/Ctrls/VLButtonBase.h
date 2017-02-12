
#import <UIKit/UIKit.h>
#import "VLBaseView.h"
#import "VL_UIControls_Categories.h"

@interface VLButtonBase : VLBaseDrawableView
{
@private
	BOOL _touched;
	BOOL _pressed;
	BOOL _touchedEnded;
	VLMessenger *_msgrTapped;
	NSString *_title;
	UITextAlignment _textAlign;
	UIImage *_image;
	UIFont *_font;
	UIColor *_textColor;
	UIColor *_shadowColor;
	CGSize _shadowOffset;
	float _contentInsetRelLeft;
	float _contentInsetRelTop;
	float _contentInsetRelRight;
	float _contentInsetRelBottom;
}

@property(nonatomic, readonly) BOOL touched;
@property(nonatomic, assign) BOOL pressed;
@property(nonatomic, readonly) VLMessenger *msgrTapped;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, assign) UITextAlignment textAlign;
@property(nonatomic, assign) UIImage *image;
@property(nonatomic, assign) UIFont *font;
@property(nonatomic, assign) UIColor *textColor;
@property(nonatomic, assign) UIColor *shadowColor;
@property(nonatomic, assign) CGSize shadowOffset;
@property(nonatomic, assign) float contentInsetRelLeft;
@property(nonatomic, assign) float contentInsetRelTop;
@property(nonatomic, assign) float contentInsetRelRight;
@property(nonatomic, assign) float contentInsetRelBottom;

- (CGRect)rectContent;
- (void)drawTitle:(NSString*)title inArea:(CGRect)rcArea align:(UITextAlignment)align;

@end



@interface VLButtonDrawerBase : NSObject <VLBaseDrawableView_drawDelegate>
{
@private
}

- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect;
- (void)drawTitle:(NSString*)title
		   inRect:(CGRect)rect
		 withFont:(UIFont*)font
		withColor:(UIColor*)color
		textAlign:(UITextAlignment)textAlign;

@end


@interface VLButtonDrawerStandard : VLButtonDrawerBase
{
@private
}

+ (VLButtonDrawerStandard*)sharedVLButtonDrawerStandard;

@end


@interface VLButtonDrawerImage : VLButtonDrawerBase
{
@private
	UIImage *_image;
	UIImage *_imageTouched;
	UIImage *_imageDisabled;
	UIColor *_colorText;
	UIColor *_colorTextTouched;
}

- (id)initWithImage:(UIImage*)image
	  timageTouched:(UIImage*)imageTouched
	  imageDisabled:(UIImage*)imageDisabled
		  colorText:(UIColor*)colorText
		  colorTextTouched:(UIColor*)colorTextTouched;
- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect onlyBack:(BOOL)onlyBack;

@end

