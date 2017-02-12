
#import "VLTableSectionHeader.h"

#define kDefaultFont [UIFont boldSystemFontOfSize:16]
#define kDefaultTextColor [UIColor colorWithRed:124/255.0 green:124/255.0 blue:124/255.0 alpha:1.0]//[UIColor colorWithRed:66/255.0 green:77/255.0 blue:100/255.0 alpha:1.0]
#define kShowTextShadow NO
#define kDefaultTextShadowColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define kDefaultLeftInset 24.0
#define kDefaultRightInset 12.0

@implementation VLTableSectionHeader

@synthesize label = _label;
@dynamic text;
@synthesize insets = _insets;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_label = [[VLLabel alloc] initWithFrame:CGRectZero];
	_label.backgroundColor = [UIColor clearColor];
	_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_label.font = kDefaultFont;
	_label.textColor = kDefaultTextColor;
	if(kShowTextShadow) {
		_label.shadowColor = kDefaultTextShadowColor;
		_label.shadowOffset = CGSizeMake(0, 1);
	}
	[self addSubview:_label];
	
	_insets.left = kDefaultLeftInset;
	_insets.right = kDefaultRightInset;
}

- (NSString *)text {
	return _label.text;
}

- (void)setText:(NSString *)text {
	if(!text)
		text = @"";
	if(![self.text isEqual:text]) {
		_label.text = text;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcLabel = rcBnds;
	rcLabel.origin.x += _insets.left;
	rcLabel.size.width -= _insets.left + _insets.right;
	rcLabel.origin.y += _insets.top;
	_label.frame = rcLabel;
}

- (CGSize)sizeThatFits:(CGSize)size {
	float widthForLabel = size.width;
	widthForLabel -= _insets.left + _insets.right;
	CGSize szText = CGSizeZero;
	NSString *text = _label.text;
	if([NSString isEmpty:text])
		text = @"W";
	if(_label.numberOfLines == 0) {
		szText = [text vlSizeWithFont:_label.font
				  constrainedToSize:CGSizeMake(widthForLabel, INT_MAX/2)
					  lineBreakMode:_label.lineBreakMode];
	} else {
		szText = [text vlSizeWithFont:_label.font];
	}
	size.height = szText.height;
	size.height += _insets.top + _insets.bottom;
	return size;
}

- (void)dealloc {
	[_label release];
	[super dealloc];
}

@end

