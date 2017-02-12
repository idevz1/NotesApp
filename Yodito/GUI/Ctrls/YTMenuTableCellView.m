
#import "YTMenuTableCellView.h"

@implementation YTMenuTableCellView

@synthesize contentInsets = _contentInsets;
@dynamic title;
@dynamic icon;
@synthesize labelTitle = _labelTitle;
@dynamic titleRight;
@synthesize labelTitleRight = _labelTitleRight;
@synthesize enableIconTouches = _enableIconTouches;
@synthesize separatorBottomHidden = _separatorBottomHidden;
@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	_contentInsets = UIEdgeInsetsMake(2, 1, 2, 4);
	
	_imageIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageIcon.backgroundColor = [UIColor clearColor];
	_imageIcon.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleToFill;
	[self addSubview:_imageIcon];
	
	_labelTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelTitleRight = [[VLLabel alloc] initWithFrame:CGRectZero];
	NSArray *labels = [NSArray arrayWithObjects:_labelTitle, _labelTitleRight, nil];
	for(VLLabel *label in labels) {
		label.backgroundColor = [UIColor clearColor];
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:label];
	}
	
	_separatorBottom = [[UIView alloc] initWithFrame:CGRectZero];
	_separatorBottom.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
	[self addSubview:_separatorBottom];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
	if(!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
		_contentInsets = contentInsets;
		[self setNeedsLayout];
	}
}

- (NSString *)title {
	return _labelTitle.text;
}

- (void)setTitle:(NSString *)title {
	_labelTitle.text = title;
}

- (UIImage *)icon {
	return _imageIcon.image;
}

- (void)setIcon:(UIImage *)icon {
	_imageIcon.image = icon;
}

- (NSString *)titleRight {
	return _labelTitleRight.text;
}

- (void)setTitleRight:(NSString *)titleRight {
	if(!titleRight)
		titleRight = @"";
	if(![self.titleRight isEqual:titleRight]) {
		_labelTitleRight.text = titleRight;
		[self setNeedsLayout];
	}
}

- (BOOL)separatorBottomHidden {
	return _separatorBottom.hidden;
}

- (void)setSeparatorBottomHidden:(BOOL)separatorBottomHidden {
	_separatorBottom.hidden = separatorBottomHidden;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	UIEdgeInsets insets = _contentInsets;
	float dist = 6.0;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, insets);
	
	CGRect rcIcon = rcCtrls;
	rcIcon.size.width = rcIcon.size.height;
	_imageIcon.frame = [UIScreen roundRect:rcIcon];
	
	NSString *titleR = self.titleRight;
	CGRect rcTitleR = rcCtrls;
	rcTitleR.size.width = 0;
	if(![NSString isEmpty:titleR]) {
		rcTitleR.size.width = [titleR vlSizeWithFont:_labelTitleRight.font].width;
	}
	rcTitleR.origin.x = CGRectGetMaxX(rcCtrls) - rcTitleR.size.width;
	_labelTitleRight.frame = [UIScreen roundRect:rcTitleR];
	
	CGRect rcTitle = rcCtrls;
	rcTitle.origin.x = CGRectGetMaxX(rcIcon) + dist;
	if(rcTitleR.size.width > 0)
		rcTitle.size.width = rcTitleR.origin.x - dist - rcTitle.origin.x;
	else
		rcTitle.size.width = CGRectGetMaxX(rcCtrls) - rcTitle.origin.x;
	_labelTitle.frame = [UIScreen roundRect:rcTitle];
	
	CGRect rcSepBot = rcBnds;
	rcSepBot.size.height = 0.5;
	rcSepBot.origin.y = CGRectGetMaxY(rcCtrls) - rcSepBot.size.height;
	rcSepBot.origin.x = rcTitle.origin.x;
	rcSepBot.size.width = CGRectGetMaxX(rcCtrls) - rcSepBot.origin.x;
	_separatorBottom.frame = [UIScreen roundRect:rcSepBot];;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_iconTouchBegan = false;
	if(_enableIconTouches) {
		CGPoint pt = [[touches anyObject] locationInView:self];
		if(CGRectContainsPoint(_imageIcon.frame, pt)) {
			_iconTouchBegan = true;
			return;
		}
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(_enableIconTouches) {
		CGPoint pt = [[touches anyObject] locationInView:self];
		if(CGRectContainsPoint(_imageIcon.frame, pt) && _iconTouchBegan) {
			if(_delegate && [_delegate respondsToSelector:@selector(menuTableCellView:iconTapped:)])
				[_delegate menuTableCellView:self iconTapped:nil];
			return;
		}
	}
	[super touchesEnded:touches withEvent:event];
}

- (void)dealloc {
	[_imageIcon release];
	[_labelTitle release];
	[_labelTitleRight release];
	[_separatorBottom release];
	[super dealloc];
}

@end

