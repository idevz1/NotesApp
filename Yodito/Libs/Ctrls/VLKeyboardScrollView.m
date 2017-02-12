
#import "VLKeyboardScrollView.h"
#import "VLCtrlsUtils.h"

@implementation VLKeyboardScrollView_ContainerView

@synthesize delegate = _delegate;

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(_delegate && [_delegate respondsToSelector:@selector(VLKeyboardScrollView_ContainerView_layoutSubviews:)])
		[_delegate VLKeyboardScrollView_ContainerView_layoutSubviews:self];
}

@end


@interface VLKeyboardScrollView_ContentView : VLBaseView
{
@private
	UIView *_viewToFill;
}

@property(nonatomic, assign, setter = setViewToFill:) UIView *viewToFill;

@end

@implementation VLKeyboardScrollView_ContentView

@synthesize viewToFill = _viewToFill;

- (void)setViewToFill:(UIView *)viewToFill
{
	if(_viewToFill != viewToFill)
	{
		if(_viewToFill)
		{
			[_viewToFill removeFromSuperview];
			[_viewToFill release];
			_viewToFill = nil;
		}
		_viewToFill = viewToFill;
		if(_viewToFill)
		{
			[_viewToFill retain];
			[self addSubview:_viewToFill];
			[self setNeedsLayout];
		}
	}
}

- (void)layoutSubviews
{
	if(_viewToFill)
	{
		_viewToFill.frame = self.bounds;
		return;
	}
	[super layoutSubviews];
}

- (void)dealloc
{
	[_viewToFill release];
    [super dealloc];
}

@end



@interface VLKeyboardScrollView_ZoomingView : VLBaseView
{
@private
	VLKeyboardScrollView_ContentView *_scrollContentView;
}

@property(nonatomic,readonly) VLKeyboardScrollView_ContentView *scrollContentView;

@end

@implementation VLKeyboardScrollView_ZoomingView

@synthesize scrollContentView = _scrollContentView;

- (void)initialize
{
	[super initialize];

	_scrollContentView = [[VLKeyboardScrollView_ContentView alloc] initWithFrame:CGRectZero];
	[self addSubview:_scrollContentView];
}

- (void)dealloc
{
	[_scrollContentView release];
    [super dealloc];
}

@end


@interface VLKeyboardScrollView()
@end

@implementation VLKeyboardScrollView

@dynamic contentView;
@dynamic viewToFill;
@synthesize scrollableContentHeight = _scrollableContentHeight;
@synthesize hideKeyboardOnBeginDragging = _hideKeyboardOnBeginDragging;
@synthesize scrollEnabled = _scrollEnabled;

- (void)initialize
{
	[super initialize];
	_scrollEnabled = YES;
}

- (void)initializeScrollingFromNib:(BOOL)fromNib
{
	if(_scrollView)
		return;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameBeginUserInfoKey:) name:UIKeyboardFrameBeginUserInfoKey object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameEndUserInfoKey:) name:UIKeyboardFrameEndUserInfoKey object:nil];
	
	CGRect rcBnds = self.bounds;
	_scrollView = [[UIScrollView alloc] initWithFrame:rcBnds];
	_scrollView.delaysContentTouches = NO;
	_scrollView.delegate = self;
	_scrollView.scrollEnabled = _scrollEnabled;
	[self addSubview:_scrollView];
	
	_scrollZoomingView = [[VLKeyboardScrollView_ZoomingView alloc] initWithFrame:CGRectZero];
	[_scrollView addSubview:_scrollZoomingView];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.05;
	[_timer setObserver:self selector:@selector(onTimer:)];
	
	[self setNeedsLayout];
	
	if(fromNib)
		[self performSelector:@selector(adjustInterfaceViews) withObject:nil afterDelay:0.0001];
	else
		[self performSelector:@selector(adjustInterfaceViews)];
}
- (void)initializeScrolling
{
	[self initializeScrollingFromNib:YES];
}

- (void)adjustInterfaceViews
{
	NSMutableArray *views = [NSMutableArray array];
	for(UIView *view in self.subviews)
	{
		if(!ObjectCast(view, VLKeyboardScrollView_ContainerView))
			continue;
		[views addObject:view];
	}
	if(views.count == 1)
	{
		UIView *view = [views objectAtIndex:0];
		[view removeFromSuperview];
		_scrollZoomingView.scrollContentView.viewToFill = view;
		if(_backColorForViewToFill)
			view.backgroundColor = _backColorForViewToFill;
		[self setNeedsLayout];
		
		NSMutableArray *subViews = [NSMutableArray array];
		float maxBottom = 0;
		for(UIView *subView in view.subviews)
		{
			[subViews addObject:subView];
			float bottom = CGRectGetMaxY(subView.frame);
			if(bottom > maxBottom)
				maxBottom = bottom;
		}
		if(maxBottom > 0)
			self.scrollableContentHeight = maxBottom;
	}
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
	if(_scrollEnabled != scrollEnabled)
	{
		_scrollEnabled = scrollEnabled;
		if(_scrollView)
			_scrollView.scrollEnabled = scrollEnabled;
	}
}

- (VLBaseView*)contentView
{
	return _scrollZoomingView.scrollContentView;
}
- (void)setContentViewBackColor:(UIColor*)color
{
	self.backgroundColor = _scrollZoomingView.backgroundColor =
		_scrollZoomingView.scrollContentView.backgroundColor = color;
	[_backColorForViewToFill release];
	_backColorForViewToFill = [color retain];
	if(_scrollZoomingView.scrollContentView.viewToFill)
		_scrollZoomingView.scrollContentView.viewToFill.backgroundColor = _backColorForViewToFill;
}

- (UIView*)viewToFill
{
	return _scrollZoomingView.scrollContentView.viewToFill;
}
- (void)setViewToFill:(UIView *)viewToFill
{
	_scrollZoomingView.scrollContentView.viewToFill = viewToFill;
}

- (CGRect)sharedRectWithKeyboard
{
	CGRect rcBnds = [self convertRect:self.bounds toView:nil];
	CGRect rcKeyboard = _frameOfKeyboard;
	if(!_keyboardShown || !CGRectIntersectsRect(rcBnds, rcKeyboard))
		return CGRectMake(rcBnds.origin.x, CGRectGetMaxY(rcBnds), rcBnds.size.width, 0);
	CGRect rcShared = CGRectIntersection(rcBnds, rcKeyboard);
	rcShared = [self convertRect:rcShared fromView:nil];
	return rcShared;
}

- (float)maxBottomOfChildrenViews
{
	if(!_scrollView)
		return 0;
	VLBaseView *contentView = [self contentView];
	float maxBottom = 0;
	for(UIView *view in contentView.subviews)
	{
		CGRect rect = [view convertRect:view.bounds toView:self];
		if(CGRectGetMaxY(rect) > maxBottom)
			maxBottom = CGRectGetMaxY(rect);
	}
	return maxBottom;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcScroll = rcBnds;
	if(_scrollView)
	{
		if(!CGRectEqualToRect(_scrollView.frame, rcScroll))
			_scrollView.frame = rcScroll;
		CGRect rcContent = rcScroll;
		rcContent.origin = CGPointZero;
		CGRect rcZooming = rcScroll;
		rcZooming.origin = CGPointZero;
		if(_keyboardShown)
		{
			CGPoint contentOffset = _scrollView.contentOffset;
			float maxYToShow = [self maxBottomOfChildrenViews] + contentOffset.y;
			CGRect rcKeyboard = [self sharedRectWithKeyboard];
			float dh = maxYToShow - rcKeyboard.origin.y;
			if(dh > 0)
				rcZooming.size.height += dh;
		}
		
		float dhAdd = MAX(0, _scrollableContentHeight - rcScroll.size.height);
		rcZooming.size.height += dhAdd;
		rcContent.size.height += dhAdd;
		
		if(!CGRectEqualToRect(_scrollZoomingView.frame, rcZooming))
			_scrollZoomingView.frame = rcZooming;
		_scrollZoomingView.scrollContentView.frame = rcContent;
		if(!CGSizeEqualToSize(_scrollView.contentSize, rcZooming.size))
		{
			if(rcZooming.size.height < _scrollView.contentSize.height)
			{
				[UIView beginAnimations:nil context:_scrollView];
				_scrollView.contentSize = rcZooming.size;
				[UIView commitAnimations];
			}
			else
			{
				_scrollView.contentSize = rcZooming.size;
			}
		}
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _scrollZoomingView;
}

- (UIView *)findFirstResponder {
	UIView *firstResponder = [VLCtrlsUtils findFirstResponder:self];
	if(!firstResponder) {
		VLKeyboardScrollView_ContainerView *container = (VLKeyboardScrollView_ContainerView *)[VLCtrlsUtils getSubViewOfClass:[VLKeyboardScrollView_ContainerView class] parentView:self];
		if(container && container.delegate && [container.delegate respondsToSelector:@selector(VLKeyboardScrollView_ContainerView_getFirstResponder:)])
			firstResponder = [container.delegate VLKeyboardScrollView_ContainerView_getFirstResponder:container];
	}
	return firstResponder;
}

- (void)correctScrollableControls:(BOOL)force
{
	if(!_scrollEnabled)
		return;
	if(_keyboardShown != _isScrolled || force)
	{
		if(_keyboardShown)
		{
			UIView* firstResponder = [self findFirstResponder];
			if(firstResponder)
			{
				_isScrolled = YES;
				[self setNeedsLayout];
				CGRect rcKeyboard = [self sharedRectWithKeyboard];
				CGRect rcResponder = firstResponder.bounds;
				rcResponder = [firstResponder convertRect:rcResponder toView:self];
				CGPoint lastOffset = _scrollView.contentOffset;
				float dh = CGRectGetMaxY(rcResponder) - rcKeyboard.origin.y;
				if(dh > 0)
				{
					CGPoint offset = CGPointMake(0, dh + lastOffset.y);
					[UIView beginAnimations:nil context:_scrollView];
					[UIView setAnimationDelay:0.05];
					[UIView setAnimationDuration:0.3];
					_scrollView.contentOffset = offset;
					[UIView commitAnimations];
				}
			}
		}
		else
		{
			_isScrolled = NO;
			[self layoutSubviews];
		}
	}
}

- (void)onTimer:(id)sender
{
	if(!_scrollEnabled)
		return;
	// Check if first responder was changed
	if(!_keyboardShown)
	{
		[_lastFirstResponder release];
		_lastFirstResponder = nil;
		[_timer stop];
		return;
	}
	UIView* firstResponder = [self findFirstResponder];
	if(firstResponder)
	{
		if(_lastFirstResponder && _lastFirstResponder != firstResponder)
			[self correctScrollableControls:YES];
		[_lastFirstResponder release];
		_lastFirstResponder = [firstResponder retain];
	}
}

- (void)procesKeyboardEvent:(id)obj
{
	if(!_scrollEnabled)
		return;
	if(!obj || ![obj isKindOfClass:[NSNotification class]])
		return;
	NSNotification *notify = (NSNotification*)obj;
	CGRect keybBounds;
	id idVal = [notify.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
	if(!idVal || ![idVal isKindOfClass:[NSValue class]])
		return;
	NSValue *val = (NSValue*)idVal;
	[val getValue: &keybBounds];
	_frameOfKeyboard = keybBounds;
}

- (void)keyboardWillShow:(id)obj
{
	if(!_scrollEnabled)
		return;
	_keyboardShown = YES;
	[self procesKeyboardEvent:obj];
	[self correctScrollableControls:NO];
}

- (void)keyboardDidShow:(id)obj
{
	if(!_scrollEnabled)
		return;
	[self procesKeyboardEvent:obj];
	[_timer start];
}

- (void)keyboardWillHide:(id)obj
{
	if(!_scrollEnabled)
		return;
	_keyboardShown = NO;
	[self procesKeyboardEvent:obj];
	[self correctScrollableControls:NO];
}

- (void)keyboardDidHide:(id)obj
{
	if(!_scrollEnabled)
		return;
	[self procesKeyboardEvent:obj];
}

- (void)keyboardFrameBeginUserInfoKey:(id)obj
{
	if(!_scrollEnabled)
		return;
	[self procesKeyboardEvent:obj];
}

- (void)keyboardFrameEndUserInfoKey:(id)obj
{
	if(!_scrollEnabled)
		return;
	[self procesKeyboardEvent:obj];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if(!_scrollEnabled)
		return;
	if(_hideKeyboardOnBeginDragging)
		[VLCtrlsUtils findAndResignFirstResponder:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
}

- (void)scrollToBottom
{
	[self layoutSubviews];
	UIView *firstResponder = [self findFirstResponder];
	if(firstResponder)
	{
		CGPoint offset = CGPointZero;
		offset.y = _scrollView.contentSize.height - _scrollView.frame.size.height;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kDefaultAnimationDuration];
		[UIView setAnimationBeginsFromCurrentState:YES];
		_scrollView.contentOffset = offset;
		[UIView commitAnimations];
	}
}

- (void)dealloc
{
	if(_scrollView)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardFrameBeginUserInfoKey object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardFrameEndUserInfoKey object:nil];
	}
	[_scrollView release];
	[_scrollZoomingView release];
	[_timer release];
	[_lastFirstResponder release];
	[_backColorForViewToFill release];
	[super dealloc];
}

@end
