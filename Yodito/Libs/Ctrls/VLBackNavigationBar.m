
#import "VLBackNavigationBar.h"

@implementation VLBackNavigationBar

@dynamic title;

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super init];
	if(self)
	{
		_target = target;
		_action = action;
		_navItem1 = [[UINavigationItem alloc] init];
		_navItem2 = [[UINavigationItem alloc] init];
		[self pushNavigationItem:_navItem1 animated:NO];
		[self pushNavigationItem:_navItem2 animated:NO];
		self.delegate = self;
	}
	return self;
}

- (NSString*)title
{
	return _navItem2 ? _navItem2.title : @"";
}

- (void)setTitle:(NSString*)title
{
	if(_navItem2)
		_navItem2.title = title;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	if(_target && _action)
		[_target performSelector:_action];
	return NO;
}

- (void)dealloc
{
	[_navItem1 release];
	[_navItem2 release];
	[super dealloc];
}

@end


