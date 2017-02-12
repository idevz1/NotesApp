
#import "YTEmptyNotesView.h"

@implementation YTEmptyNotesView

@synthesize topIndent = _topIndent;

- (void)initialize {
	[super initialize];
	
	_ivBack = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivBack.image = [UIImage imageNamed:@"emptynotes_bg.png"];
	_ivBack.contentMode = UIViewContentModeScaleToFill;
	[self addSubview:_ivBack];
	
	_ivIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivIcon.image = [UIImage imageNamed:@"emptynotes_smile.png"];
	_ivIcon.contentMode = UIViewContentModeScaleAspectFit;
	_ivIcon.backgroundColor = [UIColor clearColor];
	[self addSubview:_ivIcon];
	
	_ivTexts = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivTexts.image = [UIImage imageNamed:@"emptynotes_texts1.png"];
	_ivTexts.contentMode = UIViewContentModeScaleAspectFit;
	_ivTexts.backgroundColor = [UIColor clearColor];
	[self addSubview:_ivTexts];
}

- (void)setTopIndent:(float)topIndent animated:(BOOL)animated {
	if(_topIndent != topIndent) {
		if(animated) {
			[self layoutSubviews];
			[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
				_topIndent = topIndent;
				[self layoutSubviews];
			}];
		} else {
			_topIndent = topIndent;
			[self setNeedsLayout];
		}
	}
}

- (void)setTopIndent:(float)topIndent {
	[self setTopIndent:topIndent animated:NO];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	_ivBack.frame = rcBnds;
	CGRect rcCtrls = rcBnds;
	int topIndent = 8 + _topIndent;
	rcCtrls.origin.y += topIndent;
	rcCtrls.size.height -= topIndent;
	if(IsPortrait) {
		CGRect rcIconArea = rcCtrls;
		rcIconArea.size.height = rcCtrls.size.width * 0.3;
		CGRect rcIcon = rcIconArea;
		rcIcon.size.height *= 0.98;
		rcIcon.size.width = rcIcon.size.height * _ivIcon.image.size.width / _ivIcon.image.size.height;
		rcIcon.origin.x = CGRectGetMidX(rcIconArea) - rcIcon.size.width/2;
		rcIcon.origin.y = CGRectGetMidY(rcIconArea) - rcIcon.size.height/2;
		_ivIcon.frame = rcIcon;
		
		CGRect rcTexts = rcCtrls;
		rcTexts.origin.y = CGRectGetMaxY(rcIconArea);
		rcTexts.size.width *= 0.95;
		rcTexts.origin.x = CGRectGetMidX(rcCtrls) - rcTexts.size.width/2;
		rcTexts.size.height = rcTexts.size.width * _ivTexts.image.size.height / _ivTexts.image.size.width;
		rcTexts.origin.y -= 10;
		rcTexts.origin.x += 0;//10;
		_ivTexts.frame = rcTexts;
	} else {
		CGRect rcIconArea = rcCtrls;
		rcIconArea.size.width = rcCtrls.size.height * 0.7;
		CGRect rcIcon = rcIconArea;
		rcIcon.size.width *= 0.8;
		rcIcon.size.height = rcIcon.size.width * _ivIcon.image.size.height / _ivIcon.image.size.width;
		rcIcon.origin.x = CGRectGetMidX(rcIconArea) - rcIcon.size.width/2;
		rcIcon.origin.y = CGRectGetMidY(rcIconArea) - rcIcon.size.height/2;
		_ivIcon.frame = rcIcon;
		
		CGRect rcTexts = rcCtrls;
		rcTexts.origin.x = CGRectGetMaxX(rcIconArea);
		rcTexts.size.width = rcTexts.size.height * _ivTexts.image.size.width / _ivTexts.image.size.height;
		if(CGRectGetMaxX(rcTexts) > CGRectGetMaxX(rcCtrls)) {
			rcTexts.size.width = CGRectGetMaxX(rcCtrls) - rcTexts.origin.x;
			rcTexts.size.height = rcTexts.size.width * _ivTexts.image.size.height / _ivTexts.image.size.width;
		}
		rcTexts.origin.y = CGRectGetMidY(rcCtrls) - rcTexts.size.height/2;
		_ivTexts.frame = rcTexts;
	}
}

- (void)dealloc {
	[_ivBack release];
	[_ivIcon release];
	[_ivTexts release];
	[super dealloc];
}

@end

