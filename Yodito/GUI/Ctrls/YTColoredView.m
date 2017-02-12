
#import "YTColoredView.h"

#define kDefaultColor [UIColor blackColor]

@implementation YTColoredView

@synthesize color = _color;

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	_color = [kDefaultColor retain];
}

- (void)setColor:(UIColor *)color
{
	if(!color)
		color = kDefaultColor;
	[_color release];
	_color = [color retain];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[_color setFill];
	CGContextFillRect(ctx, rcBnds);
}

- (void)dealloc
{
	[_color release];
	[super dealloc];
}

@end
