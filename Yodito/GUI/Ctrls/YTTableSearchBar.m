
#import "YTTableSearchBar.h"

@interface YTTableSearchBar_UITextField : UITextField {
@private
}

@end

@implementation YTTableSearchBar_UITextField

- (CGRect)textRectForBounds:(CGRect)bounds {
	CGRect rect = [super textRectForBounds:bounds];
	float dx = 32;
	rect.origin.x += dx;
	rect.size.width -= dx;
	return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	CGRect rect = [super editingRectForBounds:bounds];
	float dx = 32;
	rect.origin.x += dx;
	rect.size.width -= dx;
	return rect;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	/*CGRect rcBnds = self.bounds;
	CGRect rcBack = CGRectInset(rcBnds, 0, 4);
	float minSide = MIN(rcBack.size.width, rcBack.size.height);
	float radius = minSide/2;
	UIColor *color = [UIColor lightGrayColor];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[VLGraphicsUtils context:ctx
			 drawRoundedRect:rcBack
			withCornerRadius:radius
				   lineWidth:0
				   lineColor:[UIColor clearColor]
				   fillColor:color];*/
}

- (void)drawPlaceholderInRect:(CGRect)rect {
	NSString *text = self.placeholder;
	if(![NSString isEmpty:text]) {
		UIColor *color = [UIColor lightGrayColor];
		UIFont *font = self.font;
		CGSize size = [text vlSizeWithFont:font];
		while(size.width > rect.size.width && font.pointSize >= 2) {
			font = [UIFont fontWithName:font.fontName size:font.pointSize - 1.0];
			size = [text vlSizeWithFont:font];
		}
		CGRect rcText = rect;
		rcText.size.height = size.height;
		rcText.origin.y = CGRectGetMidY(rect) - rcText.size.height/2.0;
		[text vlDrawInRect:rcText withFont:font color:color];
		/*NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
		CGFloat fontSize = [VLGraphicsUtils fontSizeForText:text withFont:font constrainedToSizeMultiline:rect.size lineBreakMode:lineBreakMode];
		UIFont *newFont = [UIFont fontWithName:font.fontName size:fontSize];
		CGRect rcText = rect;
		//if(self.baselineAdjustment == UIBaselineAdjustmentAlignCenters)
		//{
			rcText.size = [text vlSizeWithFont:newFont constrainedToSize:rect.size lineBreakMode:NSLineBreakByWordWrapping];
			rcText.origin.y = rect.origin.y + rect.size.height/2 - rect.size.height/2;
		//}
		//if(self.textAlignment == NSTextAlignmentCenter)
		//{
		//	rcText.origin.x = rcView.origin.x + rcView.size.width/2 - rcText.size.width/2;
		//}
		[color set];
		[text vlDrawInRect:rcText withFont:newFont lineBreakMode:lineBreakMode alignment:NSTextAlignmentLeft color:color];*/
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

@end


@implementation YTTableSearchBar

@synthesize delegate = _delegate;
@synthesize searchText = _searchText;
@synthesize textField = _textField;
@dynamic placeholder;
@synthesize alwaysShowPlaceholder = _alwaysShowPlaceholder;

- (void)initialize {
	[super initialize];
	_searchText = [@"" retain];
	self.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
	
	_textField = [[YTTableSearchBar_UITextField alloc] initWithFrame:CGRectZero];
	_textField.delegate = self;
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.alpha = 0;
	_textField.userInteractionEnabled = NO;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.returnKeyType = UIReturnKeySearch;
	_textField.clearButtonMode = UITextFieldViewModeAlways;
	[self addSubview:_textField];
	
	_btnCancel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnCancel setTitleColor:kYTLabelsBlueTextColor forState:UIControlStateNormal];
	[_btnCancel setTitle:NSLocalizedString(@"Cancel {Button}", nil) forState:UIControlStateNormal];
	_btnCancel.alpha = 0;
	[_btnCancel addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnCancel];
	
	_imageMagnifier = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageMagnifier.backgroundColor = [UIColor clearColor];
	_imageMagnifier.image = [UIImage imageNamed:@"magnifier_white.png" scale:2];
	[self addSubview:_imageMagnifier];
	
	_activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	_activityView.hidden = YES;
	_activityView.backgroundColor = [UIColor clearColor];
	_activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self addSubview:_activityView];
}

- (NSString *)placeholder {
	return _textField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
	_textField.placeholder = placeholder;
}

- (void)setAlwaysShowPlaceholder:(BOOL)alwaysShowPlaceholder {
	if(_alwaysShowPlaceholder != alwaysShowPlaceholder) {
		_alwaysShowPlaceholder = alwaysShowPlaceholder;
		_textField.alpha = _btnCancel.alpha = (_isEditing || _alwaysShowPlaceholder) ? 1 : 0;
		[self setNeedsLayout];
	}
}

+ (float)optimalHeight {
	return 44;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = [[self class] optimalHeight];
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	
	CGRect rcMagn = rcBnds;
	rcMagn.size = _imageMagnifier.image.size;
	rcMagn.origin.x = CGRectGetMidX(rcBnds) - rcMagn.size.width/2;
	rcMagn.origin.y = CGRectGetMidY(rcBnds) - rcMagn.size.height/2;
	
	CGRect rcText = rcBnds;
	
	CGRect rcBtn = rcBnds;
	rcBtn.size.width = rcBtn.size.height * 2;
	NSString *textBtn = [_btnCancel titleForState:UIControlStateNormal];
	UIFont *fontBtn = _btnCancel.titleLabel.font;
	float textBtnWidth = [textBtn vlSizeWithFont:fontBtn].width + 8;
	textBtnWidth = MIN(textBtnWidth, rcBnds.size.width * 0.4);
	if(textBtnWidth > rcBtn.size.width)
		rcBtn.size.width = textBtnWidth;
	rcBtn.origin.x = CGRectGetMaxX(rcBnds);
	
	if(_isEditing) {
		rcBtn.origin.x = CGRectGetMaxX(rcBnds) - rcBtn.size.width;
		rcText.size.width = rcBtn.origin.x - rcText.origin.x;
		rcMagn.origin.x = rcText.origin.x;
	} else {
		if(_alwaysShowPlaceholder)
			rcMagn.origin.x = rcText.origin.x;
	}
	
	rcText = CGRectInset(rcText, 2, 2);
	
	if(_activityView) {
		CGRect rcAct = rcText;
		rcAct.size.width = rcAct.size.height;
		_activityView.frame = [UIScreen roundRect:rcAct];
	}
	
	_textField.frame = [UIScreen roundRect:rcText];
	_btnCancel.frame = [UIScreen roundRect:rcBtn];
	_imageMagnifier.frame = [UIScreen roundRect:rcMagn];
}

- (void)setEditing:(BOOL)isEditing {
	if(_isEditing != isEditing) {
		_textField.text = @"";
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_isEditing = isEditing;
			_textField.userInteractionEnabled = _isEditing;
			_textField.alpha = _btnCancel.alpha = (_isEditing || _alwaysShowPlaceholder) ? 1 : 0;
			[self layoutSubviews];
			if(_isEditing) {
				if(_delegate && [_delegate respondsToSelector:@selector(tableSearchBar:searchStarted:)])
					[_delegate tableSearchBar:self searchStarted:nil];
			} else {
				[self setSearchText:@""];
				if(_delegate && [_delegate respondsToSelector:@selector(tableSearchBar:searchEnded:)])
					[_delegate tableSearchBar:self searchEnded:nil];
			}
		} completion:^(BOOL finished) {
			if(finished) {
				if(_isEditing) {
					[_textField becomeFirstResponder];
				}
			}
		}];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	if(!_isEditing) {
		[self setEditing:YES];
	}
}

- (void)onBtnCancelTap:(id)sender {
	[self setEditing:NO];
	if(_delegate && [_delegate respondsToSelector:@selector(tableSearchBar:cancelButtonTapped:)])
		[_delegate tableSearchBar:self cancelButtonTapped:nil];
}

- (void)setSearchText:(NSString *)searchText {
	if(!searchText)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		[_searchText release];
		_searchText = [searchText copy];
		if(_isEditing && _delegate && [_delegate respondsToSelector:@selector(tableSearchBar:searchTextChanged:)])
			[_delegate tableSearchBar:self searchTextChanged:_searchText];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if(_isEditing) {
		if(_isEditing) {
			NSString *searchText = [_textField.text stringByReplacingCharactersInRange:range withString:string];
			searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[self setSearchText:searchText];
		}
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(_isEditing) {
		NSString *searchText = [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[self setSearchText:searchText];
		if(_delegate && [_delegate respondsToSelector:@selector(tableSearchBar:searchButtonTapped:)])
			[_delegate tableSearchBar:self searchButtonTapped:nil];
	}
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	if(_isEditing) {
		[self setSearchText:@""];
	} else {
		[self setSearchText:@""];
		[self setEditing:YES];
	}
	return YES;
}

- (void)showActivity:(BOOL)show {
	if(show != !_activityView.hidden) {
		if(show) {
			_activityView.hidden = NO;
			[_activityView startAnimating];
		} else {
			[_activityView stopAnimating];
			_activityView.hidden = YES;
		}
	}
}

- (void)cancelSearching {
	[self setSearchText:@""];
	_textField.text = @"";
	[self setEditing:NO];
	[self showActivity:NO];
}

- (void)dealloc {
	[_searchText release];
	[_imageMagnifier release];
	[_textField release];
	[_btnCancel release];
	[_activityView release];
	[super dealloc];
}

@end







