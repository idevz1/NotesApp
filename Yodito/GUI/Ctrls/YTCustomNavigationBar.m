
#import "YTCustomNavigationBar.h"

@interface YTCustomNavigationBar_TapBlockView : VLBaseView {
@private
}

@end

@implementation YTCustomNavigationBar_TapBlockView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
}

@end


#define kBtnHeight 30.0
#define kTitleFromArrowOffsetX 12.0
#define kBtnAddTouchWidth 44.0

@implementation YTCustomNavigationBar

@synthesize contentView = _contentViewCNB;
@synthesize titleLabel = _titleLabel;
@synthesize btnBack = _btnBack;
@synthesize btnLeft = _btnLeft;
@synthesize btnRight = _btnRight;
@synthesize bottomTapBlockAreaRatio = _bottomTapBlockAreaRatio;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTHeaderBackColor;
	
	_contentViewCNB = [[UIView alloc] initWithFrame:CGRectZero];
	_contentViewCNB.backgroundColor = [UIColor clearColor];
	[self addSubview:_contentViewCNB];
	
	_ivBotShadow = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivBotShadow.backgroundColor = [UIColor clearColor];
	_ivBotShadow.contentMode = UIViewContentModeScaleToFill;
	[self addSubview:_ivBotShadow];
	
	_titleLabel = [[VLLabel alloc] initWithFrame:CGRectZero];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

	UIFont *font = [[YTFontsManager shared] fontHeaderTitle];
	_titleLabel.font = font;
	_titleLabel.numberOfLines = 1;
	_titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	_titleLabel.textColor = kYTHeaderTitleColor;
	[_contentViewCNB addSubview:_titleLabel];
	
	_btnBack = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_btnBack.hidden = YES;
	_btnBack.titleLabel.adjustsFontSizeToFitWidth = YES;
	[_contentViewCNB addSubview:_btnBack];
	
	_btnLeft = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_btnLeft.hidden = YES;
	[_contentViewCNB addSubview:_btnLeft];
	
	_btnRight = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_btnRight.hidden = YES;
	[_contentViewCNB addSubview:_btnRight];
	
	NSMutableArray *buttons = [NSMutableArray array];
	[buttons addObject:_btnBack];
	[buttons addObject:_btnLeft];
	[buttons addObject:_btnRight];
	for(UIButton *btn in buttons) {
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btn.titleLabel setFont:[[YTFontsManager shared] fontWithSize:13 fixed:YES]];
	}
	
	_tapBlockView = [[YTCustomNavigationBar_TapBlockView alloc] initWithFrame:CGRectZero];
	[_contentViewCNB addSubview:_tapBlockView];
	
	_ivBotShadow.image = nil;
	_titleLabel.textColor = kYTHeaderTitleColor;
	_titleLabel.shadowColor = [UIColor clearColor];
	_titleLabel.shadowOffset = CGSizeMake(0, 0);
	UIImage *image = [UIImage imageNamed:@"navbar_btn_back_arrow_ios7.png" scale:2];
	[_btnBack setImage:image forState:UIControlStateNormal];
	[_btnBack setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, kBtnAddTouchWidth)];
	[_btnBack setTitleColor:kYTHeaderButtonTitleColor forState:UIControlStateNormal];
	UIFont *labelFont = [[YTFontsManager shared] lightFontWithSize:19 fixed:YES];
	_btnBack.titleLabel.font = labelFont;
	
	[_btnLeft setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, kBtnAddTouchWidth)];
	[_btnLeft setTitleColor:kYTHeaderButtonTitleColor forState:UIControlStateNormal];
	_btnLeft.titleLabel.font = labelFont;
	
	[_btnRight setImageEdgeInsets:UIEdgeInsetsMake(4, kBtnAddTouchWidth, 4, 4)];
	[_btnRight setTitleColor:kYTHeaderButtonTitleColor forState:UIControlStateNormal];
	_btnRight.titleLabel.font = labelFont;
	//_btnRight.titleLabel.textAlignment = NSTextAlignmentRight;
}

- (void)setBottomTapBlockAreaRatio:(float)bottomTapBlockAreaRatio {
	if(_bottomTapBlockAreaRatio != bottomTapBlockAreaRatio) {
		_bottomTapBlockAreaRatio = bottomTapBlockAreaRatio;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	_contentViewCNB.frame = rcBnds;
    
	CGRect rcBotShad = rcBnds;
	rcBotShad.size.height = _ivBotShadow.image ? (_ivBotShadow.image.size.height / 2) : 0;
	rcBotShad.origin.y = CGRectGetMaxY(rcBnds);
	_ivBotShadow.frame = [UIScreen roundRect:rcBotShad];
	
	CGRect rcInner = rcBnds;
	rcInner.size.height = kBtnHeight;
	rcInner.origin.y = 5+CGRectGetMidY(rcBnds) - rcInner.size.height / 2;
	float dx = rcInner.origin.y - rcBnds.origin.y;
	rcInner.origin.x += dx;
	rcInner.size.width -= dx * 2;
	rcInner.size.width -= 3;
	
	UIButton *btnLeft = nil;
	UIButton *btnRight = nil;
	NSMutableArray *leftButtons = [NSMutableArray array];
	[leftButtons addObject:_btnBack];
	[leftButtons addObject:_btnLeft];
	for(UIButton *btn in leftButtons) {
		CGRect rcBtn = rcInner;
		NSString *title = [btn titleForState:UIControlStateNormal];
		UIFont *font = btn.titleLabel.font;
		UIImage *image = [btn backgroundImageForState:UIControlStateNormal];
		if(!image)
			image = [btn imageForState:UIControlStateNormal];
		if(image) {
			rcBtn.size.width = rcBtn.size.height * image.size.width / image.size.height;
			rcBtn.size.width += [title vlSizeWithFont:font].width;
		} else {
			rcBtn.size.width = [title vlSizeWithFont:font].width;
		}
		rcBtn.origin.x -= btn.imageEdgeInsets.left;
		rcBtn.size.width += btn.imageEdgeInsets.left;
		if([NSString isEmpty:title]) {
			rcBtn.size.width += btn.imageEdgeInsets.right;
		} else {
			rcBtn.size.width += kTitleFromArrowOffsetX;
		}
		rcBtn.origin.y -= btn.imageEdgeInsets.top;
		rcBtn.size.height += btn.imageEdgeInsets.top + btn.imageEdgeInsets.bottom;
		btn.frame = [UIScreen roundRect:rcBtn];
		if(!btn.hidden)
			btnLeft = btn;
	}
	NSMutableArray *rightButtons = [NSMutableArray array];
	[rightButtons addObject:_btnRight];
	for(UIButton *btn in rightButtons) {
		CGRect rcBtn = rcInner;
		UIImage *image = [btn backgroundImageForState:UIControlStateNormal];
		NSString *title = [btn titleForState:UIControlStateNormal];
		if(!image)
			image = [btn imageForState:UIControlStateNormal];
		if(image) {
			rcBtn.size.width = rcBtn.size.height * image.size.width / image.size.height;
		} else {
			UIFont *font = btn.titleLabel.font;
			rcBtn.size.width = [title vlSizeWithFont:font].width;
		}
		rcBtn.origin.x = CGRectGetMaxX(rcInner) - rcBtn.size.width;
		rcBtn.origin.x -= btn.imageEdgeInsets.left;
		rcBtn.size.width += btn.imageEdgeInsets.left + btn.imageEdgeInsets.right;
		rcBtn.origin.y -= btn.imageEdgeInsets.top;
		rcBtn.size.height += btn.imageEdgeInsets.top + btn.imageEdgeInsets.bottom;
		
		UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
		if(![NSString isEmpty:title]) {
			float titleWidth = [title vlSizeWithFont:btn.titleLabel.font].width;
			titleEdgeInsets.left = rcBtn.size.width - titleWidth - 8*2;
		}
		btn.titleEdgeInsets = titleEdgeInsets;
		
		btn.frame = [UIScreen roundRect:rcBtn];
		if(!btn.hidden)
			btnRight = btn;
	}
	
	CGRect rcTitle = rcInner;
	float dxL = 0;
	float dxR = 0;
	float btnLeftR = 0;
	if(btnLeft) {
		//dxL = (CGRectGetMaxX(btnLeft.frame) - btnLeft.imageEdgeInsets.right + 2) - rcTitle.origin.x;
		btnLeftR = CGRectGetMaxX(btnLeft.frame);
		NSString *str = [btnLeft titleForState:UIControlStateNormal];
		if([NSString isEmpty:str])
			btnLeftR -= btnLeft.imageEdgeInsets.right;
		btnLeftR += 2;
		dxL = btnLeftR - rcTitle.origin.x;
	}
	float btnRightL = 0;
	if(btnRight) {
		btnRightL = btnRight.frame.origin.x;
		NSString *str = [btnRight titleForState:UIControlStateNormal];
		if([NSString isEmpty:str])
			btnRightL += btnRight.imageEdgeInsets.left;
		else {
			CGSize szText = [str vlSizeWithFont:btnRight.titleLabel.font];
			UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;// btnRight.titleEdgeInsets;
			float cx = CGRectGetMidX(btnRight.frame) + titleEdgeInsets.left - titleEdgeInsets.right;
			btnRightL = cx - szText.width/2;
		}
		btnRightL -= 2;
		dxR = CGRectGetMaxX(rcTitle) - btnRightL;
	}
	if(dxL > 0 && dxR < dxL)
		dxR = dxL;
	if(dxR > 0 && dxL < dxR)
		dxL = dxR;
	rcTitle.origin.x += dxL;
	rcTitle.size.width -= dxL;
	rcTitle.size.width -= dxR;
	NSString *sTitle = _titleLabel.text;
	CGSize szTitleText = [sTitle vlSizeWithFont:_titleLabel.font];
	if(szTitleText.width > rcTitle.size.width) {
		if(!btnRight) {
			float dx = ceil(MIN(szTitleText.width - rcTitle.size.width, CGRectGetMaxX(rcBnds) - 2 - CGRectGetMaxX(rcTitle)));
			rcTitle.size.width += dx;
		} else if(btnLeft && btnRight) {
			if(rcTitle.origin.x + szTitleText.width > btnRightL) {
				rcTitle.size.width = szTitleText.width;
				float dx = CGRectGetMaxX(rcTitle) - btnRightL;
				if(dx > 0)
					rcTitle.origin.x -= dx;
				if(rcTitle.origin.x < btnLeftR) {
					float dx = btnLeftR - rcTitle.origin.x;
					rcTitle.origin.x += dx;
					rcTitle.size.width -= dx;
				}
			}
		}
	}
	CGRect rcTitleAdj = rcTitle;
	rcTitleAdj.size.height = [@"0W" vlSizeWithFont:_titleLabel.font].height + ABS(_titleLabel.shadowOffset.height);
	//rcTitleAdj.size.height = _titleLabel.font.pointSize + ABS(_titleLabel.shadowOffset.height);
	rcTitleAdj.origin.y = CGRectGetMidY(rcTitle) - rcTitleAdj.size.height/2;
	_titleLabel.frame = [UIScreen roundRect:rcTitleAdj];
	
	if(_imageViewTitle) {
		CGRect rcIvTtl = rcBnds;
		_imageViewTitle.frame = rcIvTtl;
	}
	
	CGRect rcTapBlock = rcBnds;
	rcTapBlock.size.height = rcBnds.size.height * _bottomTapBlockAreaRatio;
	rcTapBlock.origin.y = CGRectGetMaxY(rcBnds) - rcTapBlock.size.height;
	_tapBlockView.frame = [UIScreen roundRect:rcTapBlock];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (IsUiIPad)
        size.height=64;
    else
	size.height = 44;
	return size;
}

- (void)setTitleImage:(UIImage *)image {
	if(!image) {
		if(_imageViewTitle) {
			[_imageViewTitle removeFromSuperview];
			[_imageViewTitle release];
			_imageViewTitle = nil;
		}
		return;
	}
	if(!_imageViewTitle) {
		_imageViewTitle = [[UIImageView alloc] initWithFrame:CGRectZero];
		_imageViewTitle.backgroundColor = [UIColor clearColor];
		_imageViewTitle.contentMode = UIViewContentModeCenter;
		[_titleLabel.superview insertSubview:_imageViewTitle aboveSubview:_titleLabel];
		[self setNeedsLayout];
	}
	_imageViewTitle.image = image;
}

- (void)dealloc {
	[_contentViewCNB release];
	[_ivBotShadow release];
	[_titleLabel release];
	[_imageViewTitle release];
	[_btnBack release];
	[_btnLeft release];
	[_btnRight release];
	[_tapBlockView release];
	[super dealloc];
}

@end

