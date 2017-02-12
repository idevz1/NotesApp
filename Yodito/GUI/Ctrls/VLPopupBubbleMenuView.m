
#import "VLPopupBubbleMenuView.h"

@interface VLPopupBubbleMenuView()

- (void)drawPopupView;

@end


@interface VLPopupBubbleMenuView_PopupView : VLBaseView {
@private
}

@end

@implementation VLPopupBubbleMenuView_PopupView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	VLPopupBubbleMenuView *parent = (VLPopupBubbleMenuView *)[VLCtrlsUtils getParentViewOfClass:[VLPopupBubbleMenuView class] ofView:self];
	[parent drawPopupView];
}

- (void)dealloc {
	[super dealloc];
}

@end

#define kDefaultTextFont [UIFont boldSystemFontOfSize:12]
#define kDefaultBackColor [UIColor blackColor]
#define kDefaultTextColor [UIColor whiteColor]
#define kDefaultPadding UIEdgeInsetsMake(4, 4, 4, 4)

@implementation VLPopupBubbleMenuView

@synthesize delegate = _delegate;
@synthesize items = _items;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	_items = [[NSMutableArray alloc] init];
	_popupView = [[VLPopupBubbleMenuView_PopupView alloc] initWithFrame:CGRectZero];
	[self addSubview:_popupView];
	_textFont = [kDefaultTextFont retain];
	_backColor = [kDefaultBackColor retain];
	_textColor = [kDefaultTextColor retain];
	_cornerRadius = 6.0;
	_arrowSize = 7.0;
	_padding = kDefaultPadding;
	_itemSpaceX = 6.0;
	_separatorWidth = 1.0;
	_separatorColor = [[UIColor whiteColor] retain];
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation addObserver:self selector:@selector(setNeedsLayout)];
}

- (void)setTextFont:(UIFont *)textFont textColor:(UIColor *)textColor backColor:(UIColor *)backColor
	   cornerRadius:(float)cornerRadius padding:(UIEdgeInsets)padding itemSpaceX:(float)itemSpaceX arrowSize:(float)arrowSize {
	if(!textFont)
		textFont = [kDefaultTextFont retain];
	if(!backColor)
		backColor = [kDefaultBackColor retain];
	if(!textColor)
		textColor = [kDefaultTextColor retain];
	[_textFont release];
	_textFont = [textFont retain];
	[_textColor release];
	_textColor = [textColor retain];
	[_backColor release];
	_backColor = [backColor retain];
	_cornerRadius = cornerRadius;
	_padding = padding;
	_itemSpaceX = itemSpaceX;
	_arrowSize = arrowSize;
	[self setNeedsLayout];
	[_popupView setNeedsDisplay];
}

- (VLPopupBubbleMenuViewItem *)addItemWithTitle:(NSString *)title objectTag:(NSObject *)objectTag {
	VLPopupBubbleMenuViewItem *item = [[[VLPopupBubbleMenuViewItem alloc] init] autorelease];
	item.title = title;
	item.objectTag = objectTag;
	[_items addObject:item];
	[self setNeedsLayout];
	[_popupView setNeedsDisplay];
	return item;
}

- (void)removeItemAtIndex:(int)index {
	[_items removeObjectAtIndex:index];
	[self setNeedsLayout];
	[_popupView setNeedsDisplay];
}

- (void)showInParentView:(UIView *)parentView fromView:(UIView *)fromView {
	_popupView.alpha = 0.0;
	[parentView addSubview:self];
	_fromViewRef = fromView;
	[self updateFrame];
	[self setNeedsLayout];
	[UIView animateWithDuration:kDefaultAnimationDuration/2 animations:^{
		_popupView.alpha = 1.0;
	}];
}

- (void)hide {
	[[self retain] autorelease];
	if(self.superview) {
		[UIView animateWithDuration:kDefaultAnimationDuration/2 animations:^{
			_popupView.alpha = 0.0;
		} completion:^(BOOL finished) {
			if(finished) {
				[self removeFromSuperview];
			}
		}];
	}
}

- (NSArray *)arrItemTextWidth {
	NSMutableArray *result = [NSMutableArray array];
	for(VLPopupBubbleMenuViewItem *item in _items) {
		float width = [item.title vlSizeWithFont:_textFont].width;
		[result addObject:[NSNumber numberWithFloat:width]];
	}
	return result;
}

- (CGSize)getSizeForPopup {
	CGSize size = CGSizeZero;
	size.width += _padding.left + _padding.right;
	size.height += _padding.top + _padding.bottom;
	size.width += _items.count * (_itemSpaceX * 2);
	if(_items.count)
		size.width += _separatorWidth * (_items.count - 1);
	size.height += _arrowSize;
	size.height += [@"A" vlSizeWithFont:_textFont].height;
	NSArray *arrItemTextWidth = [self arrItemTextWidth];
	for(NSNumber *num in arrItemTextWidth)
		size.width += num.floatValue;
	return size;
}

- (NSArray *)rectsForItems {
	NSMutableArray *result = [NSMutableArray array];
	CGRect rcBnds = _popupView.bounds;
	float curLeft = rcBnds.origin.x;
	float top = rcBnds.origin.y + _arrowSize;
	float bottom = CGRectGetMaxY(rcBnds);
	for(int i = 0; i < _items.count; i++) {
		VLPopupBubbleMenuViewItem *item = [_items objectAtIndex:i];
		CGRect rect = CGRectZero;
		rect.origin.y = top;
		rect.size.height = bottom - top;
		rect.origin.x = curLeft;
		if(i == 0)
			rect.size.width += _padding.left;
		else
			rect.size.width += _separatorWidth/2;
		rect.size.width += _itemSpaceX + [item.title vlSizeWithFont:_textFont].width + _itemSpaceX;
		if(i == _items.count - 1)
			rect.size.width += _padding.right;
		else
			rect.size.width += _separatorWidth/2;
		[result addObject:[NSValue valueWithCGRect:rect]];
		curLeft = CGRectGetMaxX(rect);
	}
	return result;
}

- (int)itemIndexByPoint:(CGPoint)pt {
	NSArray *rects = [self rectsForItems];
	for(int i = 0; i < rects.count; i++) {
		CGRect rect = [[rects objectAtIndex:i] CGRectValue];
		if(CGRectContainsPoint(rect, pt))
			return i;
	}
	return -1;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if(!_fromViewRef)
		return;
	[self updateFrame];
	CGRect rcBnds = self.bounds;
	CGRect rcRef = [_fromViewRef convertRect:_fromViewRef.bounds toView:self];
	CGPoint ptRef = CGPointMake(CGRectGetMidX(rcRef), CGRectGetMaxY(rcRef));
	CGRect rcPopup = CGRectZero;
	rcPopup.size = [self getSizeForPopup];
	float minEdge = 10.0;
	float freeWidth = rcBnds.size.width - minEdge * 2;
	_visibleItemsCount = (int)_items.count;
	if(rcPopup.size.width > freeWidth) {
		NSArray *arrItemTextWidth = [self arrItemTextWidth];
		while(rcPopup.size.width > freeWidth && _visibleItemsCount > 1) {
			NSNumber *num = [arrItemTextWidth objectAtIndex:_visibleItemsCount - 1];
			rcPopup.size.width -= _separatorWidth + _itemSpaceX + num.floatValue + _itemSpaceX;
			_visibleItemsCount--;
		}
	}
	rcPopup.origin.x = minEdge;
	float minX = rcPopup.origin.x + _padding.left + _arrowSize*2;
	if(ptRef.x < minX)
		ptRef.x = minX;
	float maxX = CGRectGetMaxX(rcPopup) - _padding.right - _arrowSize*2;
	if(ptRef.x > maxX) {
		float dx = ptRef.x - maxX;
		rcPopup.origin.x += dx;
	}
	rcPopup.origin.y = ptRef.y;
	_popupView.frame = rcPopup;
	if(!CGRectEqualToRect(_lastPopupRect, rcPopup) || !CGPointEqualToPoint(_lastPopupPoint, ptRef)) {
		_lastPopupRect = rcPopup;
		_lastPopupPoint = ptRef;
		[_popupView setNeedsDisplay];
	}
}

- (void)updateFrame {
	UIView *superview = self.superview;
	if(!superview)
		return;
	if(!CGRectEqualToRect(self.frame, superview.bounds)) {
		self.frame = superview.bounds;
		[self setNeedsLayout];
	}
}

- (void)drawPopupView {
	CGRect rcBnds = _popupView.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float xRef = [self convertPoint:_lastPopupPoint toView:_popupView].x;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, rcBnds.origin.x + _cornerRadius, rcBnds.origin.y + _arrowSize);
	CGPathAddLineToPoint(path, nil, xRef - _arrowSize, rcBnds.origin.y + _arrowSize);
	CGPathAddLineToPoint(path, nil, xRef, rcBnds.origin.y);
	CGPathAddLineToPoint(path, nil, xRef + _arrowSize, rcBnds.origin.y + _arrowSize);
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(rcBnds) - _cornerRadius, rcBnds.origin.y + _arrowSize);
	CGPathAddArc(path, nil, CGRectGetMaxX(rcBnds) - _cornerRadius, rcBnds.origin.y + _arrowSize + _cornerRadius, _cornerRadius, -M_PI/2, 0, 0);
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(rcBnds), CGRectGetMaxY(rcBnds) - _cornerRadius);
	CGPathAddArc(path, nil, CGRectGetMaxX(rcBnds) - _cornerRadius, CGRectGetMaxY(rcBnds) - _cornerRadius, _cornerRadius, 0, M_PI/2, 0);
	CGPathAddLineToPoint(path, nil, rcBnds.origin.x + _cornerRadius, CGRectGetMaxY(rcBnds));
	CGPathAddArc(path, nil, rcBnds.origin.x + _cornerRadius, CGRectGetMaxY(rcBnds) - _cornerRadius, _cornerRadius, M_PI/2, M_PI, 0);
	CGPathAddLineToPoint(path, nil, rcBnds.origin.x, rcBnds.origin.y + _arrowSize + _cornerRadius);
	CGPathAddArc(path, nil, rcBnds.origin.x + _cornerRadius, rcBnds.origin.y + _arrowSize + _cornerRadius, _cornerRadius, M_PI, M_PI*1.5, 0);
	[_backColor setFill];
	CGContextAddPath(ctx, path);
	CGContextFillPath(ctx);
	CGContextFillRect(ctx, CGRectMake(xRef - _arrowSize, rcBnds.origin.y + _arrowSize,
		_arrowSize * 2, _arrowSize/2));
	if(_popupPath)
		CGPathRelease(_popupPath);
	_popupPath = (CGMutablePathRef)CGPathRetain(path);
	CGPathRelease(path);
	float curLeft = rcBnds.origin.x + _padding.left + _itemSpaceX;
	float curTop = rcBnds.origin.y + _arrowSize + _padding.top;
	for(int i = 0; i < _visibleItemsCount; i++) {
		VLPopupBubbleMenuViewItem *item = [_items objectAtIndex:i];
		NSString *text = item.title;
		CGSize szText = [text vlSizeWithFont:_textFont];
		[text vlDrawAtPoint:CGPointMake(curLeft, curTop) withFont:_textFont color:_textColor];
		curLeft += szText.width + _itemSpaceX;
		if(i < _visibleItemsCount - 1) {
			float sepX = curLeft;
			float sepTop = rcBnds.origin.y + _arrowSize;
			float setBot = CGRectGetMaxY(rcBnds);
			CGContextMoveToPoint(ctx, sepX, sepTop);
			CGContextAddLineToPoint(ctx, sepX, setBot);
			[_separatorColor setStroke];
			CGContextStrokePath(ctx);
			curLeft += _separatorWidth;
			curLeft += _itemSpaceX;
		}
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(_popupPath) {
		CGPoint pt = [self convertPoint:point toView:_popupView];
		if(CGPathContainsPoint(_popupPath, nil, pt, NO))
			return self;
	}
	if(_delegate && [_delegate respondsToSelector:@selector(popupBubbleMenuView:touchedOutside:)])
		[_delegate popupBubbleMenuView:self touchedOutside:nil];
	return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:_popupView];
	_itemIndexBeganTouched = [self itemIndexByPoint:pt];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:_popupView];
	int itemIndex = [self itemIndexByPoint:pt];
	if(itemIndex >= 0 && itemIndex < _items.count && itemIndex == _itemIndexBeganTouched) {
		VLPopupBubbleMenuViewItem *item = [_items objectAtIndex:itemIndex];
		if(_delegate && [_delegate respondsToSelector:@selector(popupBubbleMenuView:itemTapped:)])
			[_delegate popupBubbleMenuView:self itemTapped:item];
	}
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation removeObserver:self];
	[_items release];
	[_popupView release];
	[_textFont release];
	[_backColor release];
	[_textColor release];
	[_separatorColor release];
	if(_popupPath)
		CGPathRelease(_popupPath);
	[super dealloc];
}

@end


@implementation VLPopupBubbleMenuViewItem

@synthesize title = _title;
@synthesize objectTag = _objectTag;

- (id)init {
	self = [super init];
	if(self) {
		_title = [@"" retain];
	}
	return self;
}

- (void)dealloc {
	[_title release];
	[_objectTag release];
	[super dealloc];
}

@end

