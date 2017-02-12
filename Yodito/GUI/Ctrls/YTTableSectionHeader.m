
#import "YTTableSectionHeader.h"

@implementation YTTableSectionHeader

@synthesize labelTitle = _labelTitle;

- (void)initialize {
	[super initialize];
	
	_imageBack = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageBack.contentMode = UIViewContentModeScaleToFill;
	[self addSubview:_imageBack];
	UIImage *image = [UIImage imageNamed:@"table_section_header_ios7.png"];
	_imageBack.image = image;
	
	_labelTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelTitle.backgroundColor = [UIColor clearColor];
	_labelTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:_labelTitle];
	_labelTitle.font = [[YTFontsManager shared] fontWithSize:20 fixed:YES];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_imageBack.frame = rcBnds;
	
	UIEdgeInsets insets = UIEdgeInsetsMake(2, 12, 2, 8);
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, insets);
	_labelTitle.frame = rcCtrls;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 0;
	UIImage *image = _imageBack.image;
	if(image) {
		CGSize szImage = image.size;
		size.height = size.width * szImage.height / szImage.width;
	}
	return size;
}

- (void)dealloc {
	[_imageBack release];
	[_labelTitle release];
	[super dealloc];
}

@end

