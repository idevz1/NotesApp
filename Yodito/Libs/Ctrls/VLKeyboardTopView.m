
#import "VLKeyboardTopView.h"
#import "VLCtrlsUtils.h"

#define kAlpha 0.75

@implementation VLKeyboardTopView

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	_toolbar.backgroundColor = [UIColor clearColor];
	_toolbar.barStyle = UIBarStyleBlack;
	_toolbar.alpha = kAlpha;
	[self addSubview:_toolbar];
	
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	_bbiDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(bbiDoneTap:)];
	[items addObject:_bbiDone];
	_toolbar.items = items;
	
	self.frame = CGRectMake(0, 0, 320, 32);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_toolbar.frame = rcBnds;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size = [_toolbar sizeThatFits:size];
	return size;
}

- (void)bbiDoneTap:(id)sender
{
	[VLCtrlsUtils findAndResignFirstResponder:[UIApplication sharedApplication].keyWindow];
}

- (void)dealloc
{
	[_toolbar release];
	[_bbiDone release];
	[super dealloc];
}

@end
