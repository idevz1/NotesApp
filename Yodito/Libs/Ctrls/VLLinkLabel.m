
#import "VLLinkLabel.h"
#import "VLCtrlsResources.h"
#import "../Drawing/Classes.h"
#import "../Common/Classes.h"

@implementation VLLinkLabel

@synthesize label = _label;
@synthesize urlLink = _urlLink;
@synthesize msgrTapped = _msgrTapped;
@synthesize colorTouched = _colorTouched;
@synthesize colorUntouched = _colorUntouched;

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	_colorUntouched = [[UIColor blueColor] retain];
	_colorTouched = [[UIColor ColorsBlue].LightBlue.color retain];
	
	_urlLink = [[NSString alloc] init];
	
	_label = [[VLLabel alloc] initWithFrame:CGRectZero];
	_label.backgroundColor = [UIColor clearColor];
	_label.textAlignment = NSTextAlignmentCenter;
	_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_label.font = [VLCtrlsResources fontLabelMedium];
	_label.textColor = _colorUntouched;
	_label.numberOfLines = 0;
	_label.adjustsFontSizeToFitWidth = YES;
	_label.contentMode = UIViewContentModeRedraw;
	_label.isUnderlined = YES;
	[self addSubview:_label];
	
	_msgrTapped = [[VLMessenger alloc] init];
	_msgrTapped.owner = self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_label.frame = self.bounds;
}

- (void)setLabelTouched:(BOOL)touched
{
	_touched = touched;
	_label.textColor = _touched ? _colorTouched : _colorUntouched;
}

- (void)setColorTouched:(UIColor *)colorTouched
{
	[_colorTouched release];
	_colorTouched = [colorTouched retain];
	[self setLabelTouched:_touched];
}

- (void)setColorUntouched:(UIColor *)colorUntouched
{
	[_colorUntouched release];
	_colorUntouched = [colorUntouched retain];
	[self setLabelTouched:_touched];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self setLabelTouched:YES];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self setLabelTouched:(CGRectContainsPoint(self.bounds, pt))];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[self setLabelTouched:NO];
	//if(![NSString isEmpty:_urlLink])
	{
		CGPoint pt = [[touches anyObject] locationInView:self];
		if(CGRectContainsPoint(self.bounds, pt))
		{
			[_msgrTapped postMessage];
			if(![NSString isEmpty:_urlLink])
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlLink]];
		}
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self setLabelTouched:NO];
}

- (void)dealloc
{
	[_label release];
	[_urlLink release];
	[_colorTouched release];
	[_colorUntouched release];
	[_msgrTapped release];
	[super dealloc];
}

@end

