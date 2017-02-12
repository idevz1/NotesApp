
#import "YTNoteEditItemsView.h"

#define kBtnTouchedAlpha 0.6

@interface YTNoteEditItemsView_Button()

@end

@implementation YTNoteEditItemsView_Button

@synthesize type = _type;
@dynamic icon;
@dynamic iconGrayed;
@synthesize delegate = _delegate;
@synthesize grayed = _grayed;
@dynamic badgeText;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	
	_buttonIcon = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_buttonIcon addTarget:self action:@selector(onBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
	[_buttonIcon addTarget:self action:@selector(onBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[_buttonIcon addTarget:self action:@selector(onBtnTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[_buttonIcon addTarget:self action:@selector(onBtnTouchCancel:) forControlEvents:UIControlEventTouchCancel];
	[self addSubview:_buttonIcon];
	
	_labelBadge = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelBadge.backgroundColor = [UIColor clearColor];
	_labelBadge.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelBadge.textAlignment = NSTextAlignmentRight;
	_labelBadge.textColor = [UIColor grayColor];
	_labelBadge.font = [[YTFontsManager shared] fontWithSize:12 fixed:YES];
	[self addSubview:_labelBadge];
}

- (UIImage *)icon {
	return _icon;
}

- (void)setIcon:(UIImage *)icon {
	if(_icon != icon) {
		if(_icon)
			[_icon release];
		_icon = icon;
		if(_icon)
			[_icon retain];
		if(!_grayed)
			[_buttonIcon setImage:_icon forState:UIControlStateNormal];
	}
}

- (UIImage *)iconGrayed {
	return _iconGrayed;
}

- (void)setIconGrayed:(UIImage *)iconGrayed {
	if(_iconGrayed != iconGrayed) {
		if(_iconGrayed)
			[_iconGrayed release];
		_iconGrayed = iconGrayed;
		if(_iconGrayed)
			[_iconGrayed retain];
		if(_grayed)
			[_buttonIcon setImage:_iconGrayed forState:UIControlStateNormal];
	}
}

- (void)setGrayed:(BOOL)grayed {
	if(_grayed != grayed) {
		_grayed = grayed;
		if(_grayed)
			[_buttonIcon setImage:_iconGrayed forState:UIControlStateNormal];
		else
			[_buttonIcon setImage:_icon forState:UIControlStateNormal];
	}
}

- (NSString *)badgeText {
	return _labelBadge.text;
}

- (void)setBadgeText:(NSString *)badgeText {
	if(!badgeText)
		badgeText = @"";
	if(![_labelBadge.text isEqual:badgeText]) {
		_labelBadge.text = badgeText;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_buttonIcon.frame = rcBnds;
	CGRect rcBadge = rcBnds;
	CGSize szText = [_labelBadge.text vlSizeWithFont:_labelBadge.font];
	rcBadge.size.height = szText.height;
	rcBadge.origin.y += 7.0;
	rcBadge.size.width = 40.0 + szText.width;
	rcBadge.origin.x = CGRectGetMidX(rcBnds) - rcBadge.size.width/2;
	_labelBadge.frame = [UIScreen roundRect:rcBadge];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 44;
	size.width = round(size.height * 1.6);
	return size;
}

- (void)setTouched:(BOOL)touched inside:(BOOL)inside {
	if(_touched != touched) {
		_touched = touched;
		self.alpha = _touched ? kBtnTouchedAlpha : 1.0;
		if(!_touched && inside) {
			if(_delegate && [_delegate respondsToSelector:@selector(noteEditItemsView_Button:tappedWithType:)])
				[_delegate noteEditItemsView_Button:self tappedWithType:self.type];
		}
	}
}

- (void)onBtnTouchDown:(id)sender {
	[self setTouched:YES inside:NO];
}

- (void)onBtnTouchUpInside:(id)sender {
	[self setTouched:NO inside:YES];
}

- (void)onBtnTouchUpOutside:(id)sender {
	[self setTouched:NO inside:NO];
}

- (void)onBtnTouchCancel:(id)sender {
	[self setTouched:NO inside:NO];
}

- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable {
	self.grayed = !enable;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:self];
	if(CGRectContainsPoint(self.bounds, pt)) {
		if(self.delegate && [self.delegate respondsToSelector:@selector(noteEditItemsView_Button:tappedWithType:)])
			[self.delegate noteEditItemsView_Button:self tappedWithType:EYTNoteEditButtonTypeNone];
	}
}

- (void)dealloc {
	[_buttonIcon release];
	[_icon release];
	[_iconGrayed release];
	[_labelBadge release];
	[super dealloc];
}

@end







@implementation YTNoteEditItemsView

@synthesize delegate = _delegate;
@synthesize buttonTag = _buttonTag;
@synthesize buttonLocation = _buttonLocation;
@synthesize buttonCamera = _buttonCamera;
@synthesize buttonStar = _buttonStar;
@synthesize buttonBook = _buttonBook;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	_allButtons = [[NSMutableArray alloc] init];
	_visibleButtons = [[NSMutableArray alloc] init];
	
	_buttonTag = [[YTNoteEditItemsView_Button alloc] initWithFrame:CGRectZero];
	_buttonTag.type = EYTNoteEditButtonTypeTag;
	_buttonTag.icon = [UIImage imageNamed:@"noteedit_tag.png" scale:2];
	_buttonTag.iconGrayed = [UIImage imageNamed:@"noteedit_tag_gray.png" scale:2];
	[_allButtons addObject:_buttonTag];
	
	_buttonLocation = [[YTNoteEditItemsView_Button alloc] initWithFrame:CGRectZero];
	_buttonLocation.type = EYTNoteEditButtonTypeLocation;
	_buttonLocation.icon = [UIImage imageNamed:@"noteedit_pin.png" scale:2];
	_buttonLocation.iconGrayed = [UIImage imageNamed:@"noteedit_pin_gray.png" scale:2];
	[_allButtons addObject:_buttonLocation];
	
	_buttonCamera = [[YTNoteEditItemsView_Button alloc] initWithFrame:CGRectZero];
	_buttonCamera.type = EYTNoteEditButtonTypeCamera;
	_buttonCamera.icon = [UIImage imageNamed:@"noteedit_camera.png" scale:2];
	_buttonCamera.iconGrayed = [UIImage imageNamed:@"noteedit_camera_gray.png" scale:2];
	[_allButtons addObject:_buttonCamera];
	
	_buttonStar = [[YTNoteEditItemsView_Button alloc] initWithFrame:CGRectZero];
	_buttonStar.type = EYTNoteEditButtonTypeStarred;
	_buttonStar.icon = [UIImage imageNamed:@"noteedit_star.png" scale:2];
	_buttonStar.iconGrayed = [UIImage imageNamed:@"noteedit_star_gray.png" scale:2];
	[_allButtons addObject:_buttonStar];
	
	_buttonBook = [[YTNoteEditItemsView_Button alloc] initWithFrame:CGRectZero];
	_buttonBook.type = EYTNoteEditButtonTypeBook;
	_buttonBook.icon = [UIImage imageNamed:@"noteedit_book.png" scale:2];
	_buttonBook.iconGrayed = [UIImage imageNamed:@"noteedit_book_gray.png" scale:2];
	[_allButtons addObject:_buttonBook];
	
	for(YTNoteEditItemsView_Button *button in _allButtons) {
		button.delegate = self;
	}
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (YTNoteEditItemsView_Button *)buttonWithType:(EYTNoteEditButtonType)type {
	for(YTNoteEditItemsView_Button *button in _allButtons) {
		if(button.type == type)
			return button;
	}
	return nil;
}

- (void)showButtonWithType:(EYTNoteEditButtonType)type show:(BOOL)show {
	YTNoteEditItemsView_Button *button = [self buttonWithType:type];
	if(button) {
		BOOL shown = [_visibleButtons containsObject:button];
		if(shown != show) {
			if(show) {
				if(button.superview != button)
					[self addSubview:button];
				[_visibleButtons addObject:button];
			} else {
				if(button.superview)
					[button removeFromSuperview];
				[_visibleButtons removeObject:button];
			}
			[self setNeedsLayout];
		}
	}
}

- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable {
	YTNoteEditItemsView_Button *button = [self buttonWithType:type];
	if(button) {
		[button enableButtonWithType:type enable:enable];
	}
}

- (UIEdgeInsets)edges {
	UIEdgeInsets edges = UIEdgeInsetsMake(2, 2, 2, 2);
	return edges;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	UIEdgeInsets edges = [self edges];
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, edges);
	float allButnsWidth = 0;
	for(int i = 0; i < _visibleButtons.count; i++) {
		YTNoteEditItemsView_Button *butn = [_visibleButtons objectAtIndex:i];
		allButnsWidth += [butn sizeThatFits:rcCtrls.size].width;
	}
	float distX = 6.0;
	float widthForButns = rcCtrls.size.width - distX * (_visibleButtons.count - 1);
	float curLeft = rcCtrls.origin.x;
	for(int i = 0; i < _visibleButtons.count; i++) {
		YTNoteEditItemsView_Button *butn = [_visibleButtons objectAtIndex:i];
		CGRect rcButn = rcCtrls;
		rcButn.origin.x = curLeft;
		rcButn.size = [butn sizeThatFits:rcButn.size];
		float butnWidth = widthForButns * (rcButn.size.width / allButnsWidth);
		rcButn.size.width = butnWidth;
		rcButn.origin.y = CGRectGetMaxY(rcCtrls) - rcButn.size.height;
		butn.frame = [UIScreen roundRect:rcButn];
		curLeft = CGRectGetMaxX(rcButn) + distX;
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 0;
	UIEdgeInsets edges = [self edges];
	size.height += edges.top;
	float maxHeight = 0;
	for(YTNoteEditItemsView_Button *btn in _visibleButtons) {
		CGSize sz = [btn sizeThatFits:CGSizeZero];
		if(sz.height > maxHeight)
			maxHeight = sz.height;
	}
	size.height += maxHeight;
	size.height += edges.bottom;
	return size;
}

- (void)noteEditItemsView_Button:(YTNoteEditItemsView_Button *)button tappedWithType:(EYTNoteEditButtonType)buttonType {
	if(_delegate && [_delegate respondsToSelector:@selector(noteEditItemsView:buttonTapped:withType:)])
		[_delegate noteEditItemsView:self buttonTapped:button withType:buttonType];
}

- (void)dealloc {
	[_allButtons release];
	[_visibleButtons release];
	[_buttonBook release];
	[_buttonLocation release];
	[_buttonCamera release];
	[_buttonTag tag];
	[_buttonStar release];
	[super dealloc];
}

@end

