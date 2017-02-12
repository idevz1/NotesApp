
#import "YTNoteCellTextView.h"

@implementation YTNoteCellTextView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	_textOrig = [@"" retain];
	_textCapital = [@"" retain];
	_textContent = [@"" retain];
	
	_labelCapital = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelCapital.backgroundColor = [UIColor clearColor];
	_labelCapital.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelCapital.numberOfLines = 1;
	_labelCapital.textColor = kYTNoteCapitalTitleColor;
	[self addSubview:_labelCapital];
	
	_labelContent = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelContent.backgroundColor = [UIColor clearColor];
	_labelContent.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelContent.numberOfLines = 0;
	_labelContent.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByWordWrapping;
	_labelContent.textColor = kYTNoteTitleColor;
	[self addSubview:_labelContent];
}

- (void)setText:(NSString *)text {
	if(!text)
		text = @"";
	if(![_textOrig isEqual:text]) {
		[_textOrig release];
		_textOrig = [text retain];
		// Find first word:
		NSString *firstLine = [YTUiCommon extractFirstNoteTextLine:_textOrig];
		if(![NSString isEmpty:firstLine]) {
			[_textCapital release];
			_textCapital = [firstLine retain];
			[_textContent release];
			_textContent = [[_textOrig substringFromIndex:firstLine.length + 1] retain];
		} else {
			[_textCapital release];
			_textCapital = [@"" retain];
			[_textContent release];
			_textContent = [_textOrig retain];
		}
		_labelCapital.text = _textCapital;
		_labelContent.text = _textContent;
		[self setNeedsLayout];
	}
}

- (void)setFontCapital:(UIFont *)fontCapital fontContext:(UIFont *)fontContext {
	if(_fontCapital != fontCapital || _fontContext != fontContext) {
		[_fontCapital release];
		_fontCapital = [fontCapital retain];
		[_fontContext release];
		_fontContext = [fontContext retain];
		_labelCapital.font = fontCapital;
		_labelContent.font = fontContext;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcCapital = rcBnds;
	CGRect rcContent = rcBnds;
	if(![NSString isEmpty:_textCapital]) {
		rcCapital.size.height = [@"A" vlSizeWithFont:_labelCapital.font].height;
		rcContent.origin.y = CGRectGetMaxY(rcCapital);
		rcContent.size.height = [_labelContent sizeThatFits:rcContent.size].height;
		float maxHeight = CGRectGetMaxY(rcBnds) - rcContent.origin.y;
		rcContent.size.height = MIN(rcContent.size.height, maxHeight);
	} else {
		rcCapital.size.height = 0;
	}
	_labelCapital.frame = [UIScreen roundRect:rcCapital];
	_labelContent.frame = [UIScreen roundRect:rcContent];
}

- (void)dealloc {
	[_textOrig release];
	[_textCapital release];
	[_textContent release];
	[_labelCapital release];
	[_labelContent release];
	[_fontCapital release];
	[_fontContext release];
	[super dealloc];
}

@end

