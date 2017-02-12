
#import "VLLabel.h"
#import "../Common/Classes.h"
#import "../Drawing/Classes.h"

@implementation VLLabel

@synthesize isUnderlined = _isUnderlined;
@synthesize adjustsFontSizeToFitWidthMultiLine = _adjustsFontSizeToFitWidthMultiLine;

- (void)drawLinesWithAdjustedFont
{
	NSString *text = self.text;
	if([NSString isEmpty:text])
		return;
	CGRect rcView = self.bounds;
	CGSize szView = rcView.size;
	if(szView.width < 2 || szView.height < 2)
		return;
	UIFont *font = self.font;
	
	CGFloat fontSize = [VLGraphicsUtils fontSizeForText:text withFont:font constrainedToSizeMultiline:szView lineBreakMode:self.lineBreakMode];
	UIFont *newFont = [UIFont fontWithName:font.fontName size:fontSize];
	CGRect rcText = rcView;
	if(self.baselineAdjustment == UIBaselineAdjustmentAlignCenters)
	{
		rcText.size = [text vlSizeWithFont:newFont constrainedToSize:rcView.size lineBreakMode:NSLineBreakByWordWrapping];
		rcText.origin.y = rcView.origin.y + rcView.size.height/2 - rcText.size.height/2;
	}
	if(self.textAlignment == NSTextAlignmentCenter)
	{
		rcText.origin.x = rcView.origin.x + rcView.size.width/2 - rcText.size.width/2;
	}
	UIColor *textColor = self.textColor;
	[textColor set];
	[text vlDrawInRect:rcText withFont:newFont lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment color:textColor];
}

- (void)drawRect:(CGRect)rect
{
	if(_adjustsFontSizeToFitWidthMultiLine && self.numberOfLines == 0)
	{
		[self drawLinesWithAdjustedFont];
		return;
	}
	[super drawRect:rect];
	if(_isUnderlined && ![NSString isEmpty:self.text])
	{
		CGRect rcView = self.bounds;
		if(rcView.size.width < 2 || rcView.size.height < 2)
			return;
		NSString *text = self.text;
		UIFont *font = self.font;
		CGSize szText = [text vlSizeWithFont:font];
		CGRect rcText = rcView;
		rcText.size = szText;
		rcText.origin.x = rcView.origin.x + rcView.size.width/2 - rcText.size.width/2;
		rcText.origin.y = rcView.origin.y + rcView.size.height/2 - rcText.size.height/2;
		int dy = 2;
		int dx = 2;
		UIColor *textColor = self.textColor;
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextBeginPath (context);
		CGContextSetStrokeColorWithColor(context, textColor.CGColor);
		CGContextSetLineWidth(context, 2);
		CGContextMoveToPoint(context, rcText.origin.x - dx, rcText.origin.y + rcText.size.height + dy);
		CGContextAddLineToPoint(context, rcText.origin.x + rcText.size.width + dx, rcText.origin.y + rcText.size.height + dy);
		CGContextStrokePath(context);
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end





