
#import "YTSlidingContentView.h"

@implementation YTSlidingContentView

@synthesize notesContentView = _notesContentView;

- (void)initialize {
	[super initialize];
	_notesContentView = [[YTNotesContentView alloc] initWithFrame:CGRectZero isMainNotesContentView:YES];
	_notesContentView.navigatingViewDelegate = self;
	[self addSubview:_notesContentView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_notesContentView.frame = rcBnds;
}

- (void)navigatingView:(YTBaseView *)navigatingView handleGoBack:(id)param {
	if(self.navigatingViewDelegate && [self.navigatingViewDelegate respondsToSelector:@selector(navigatingView:handleGoBack:)])
		[self.navigatingViewDelegate navigatingView:navigatingView handleGoBack:nil];
}

- (void)dealloc {
	[_notesContentView release];
	[super dealloc];
}

@end

