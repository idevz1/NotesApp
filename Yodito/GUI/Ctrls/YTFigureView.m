
#import "YTFigureView.h"

#define kDefaultLineColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0]
#define kDefaultFillColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0]

@implementation YTFigureView

@synthesize type = _type;
@synthesize lineColor = _lineColor;
@synthesize fillColor = _fillColor;
@synthesize lineWidth = _lineWidth;
@synthesize cornerRadius = _cornerRadius;
@synthesize padding = _padding;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	_lineColor = [kDefaultLineColor retain];
	_fillColor = [kDefaultFillColor retain];
	_lineWidth = 1.0;
}

- (void)setType:(EYTFigureViewType)type {
	if(_type != type) {
		_type = type;
		[self setNeedsDisplay];
	}
}

- (void)setLineColor:(UIColor *)lineColor {
	if(!lineColor)
		lineColor = kDefaultLineColor;
	[_lineColor release];
	_lineColor = [lineColor retain];
	[self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
	if(!fillColor)
		fillColor = kDefaultFillColor;
	[_fillColor release];
	_fillColor = [fillColor retain];
	[self setNeedsDisplay];
}

- (void)setLineWidth:(float)lineWidth {
	if(_lineWidth != lineWidth) {
		_lineWidth = lineWidth;
		[self setNeedsDisplay];
	}
}

- (void)setCornerRadius:(float)cornerRadius {
	if(_cornerRadius != cornerRadius) {
		_cornerRadius = cornerRadius;
		[self setNeedsDisplay];
	}
}

- (void)setPadding:(UIEdgeInsets)padding {
	if(!UIEdgeInsetsEqualToEdgeInsets(_padding, padding)) {
		_padding = padding;
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	if(_type == EYTFigureViewTypeRoundedRect) {
		CGRect rect = UIEdgeInsetsInsetRect(rcBnds, _padding);
		rect = CGRectInset(rect, _lineWidth/2, _lineWidth/2);
		[VLGraphicsUtils context:ctx drawRoundedRect:rect
				withCornerRadius:_cornerRadius lineWidth:_lineWidth
					   lineColor:_lineColor fillColor:_fillColor];
	} else if(_type == EYTFigureViewTypeRoundedFilledRect) {
		CGRect rect = UIEdgeInsetsInsetRect(rcBnds, _padding);
		rect = CGRectInset(rect, _lineWidth/2, _lineWidth/2);
		[VLGraphicsUtils context:ctx drawRoundedRect:rect
				withCornerRadius:_cornerRadius lineWidth:_lineWidth
					   lineColor:_lineColor fillColor:_fillColor];
	}
}

- (void)dealloc {
	[_lineColor release];
	[_fillColor release];
	[super dealloc];
}

@end

