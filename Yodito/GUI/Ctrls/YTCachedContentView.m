
#import "YTCachedContentView.h"

@implementation YTCachedContentView

@synthesize contentView = _contentView;

- (void)initialize {
	[super initialize];
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning addObserver:self selector:@selector(onMemoryWarning:)];
}

- (void)setContentViewClass:(Class)contentViewClass {
	_contentViewClass = contentViewClass;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if(_contentView)
		_contentView.frame = self.bounds;
}

- (void)checkContentViewCreated {
	if(_contentView)
		return;
	_contentView = [[_contentViewClass alloc] init];
	[self addSubview:_contentView];
	[self layoutSubviews];
	[_contentView assignEntitiesFrom:self];
}

- (void)releaseContentView {
	if(!_contentView)
		return;
	CGRect rcWnd = [UIApplication sharedApplication].keyWindow.bounds;
	CGRect rcView = [_contentView convertRect:_contentView.bounds toView:[UIApplication sharedApplication].keyWindow];
	if(CGRectIntersectsRect(rcWnd, rcView))
		return;
	[_contentView removeFromSuperview];
	[_contentView release];
	_contentView = nil;
}

- (void)onMemoryWarning:(id)sender {
	[self releaseContentView];
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning removeObserver:self];
	[_contentView release];
	[super dealloc];
}

@end

