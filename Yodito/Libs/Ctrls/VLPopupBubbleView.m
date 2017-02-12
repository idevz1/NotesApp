
#import "VLPopupBubbleView.h"
#import "../Common/Classes.h"
#import "VL_UIControls_Categories.h"

#define kLeftEdgeRel 0.15
#define kTopEdgeRel 0.1
#define kRightEdgeRel 0.15
#define kBottomEdgeRel 0.45
#define kMinScale 2.5
#define kDefaultFont [UIFont boldSystemFontOfSize:16]

@interface VLPopupBubbleView()

- (void)setArrowPosRel:(float)arrowPosRel;

@end

@implementation VLPopupBubbleView

@dynamic title;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	_arrowPosRel = 0.5;
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_lbTitle.textAlignment = NSTextAlignmentCenter;
	_lbTitle.numberOfLines = 1;
	_lbTitle.lineBreakMode = NSLineBreakByTruncatingTail;
	_lbTitle.textColor = [UIColor whiteColor];
	_lbTitle.font = kDefaultFont;
	[self addSubview:_lbTitle];
}

- (NSString*)title {
	return _lbTitle.text;
}
- (void)setTitle:(NSString *)title {
	if(!title)
		title = @"";
	if(![self.title isEqual:title]) {
		_lbTitle.text = title;
	}
}

- (void)drawImage:(UIImage*)image inRect:(CGRect)rect xMax:(float)xMax yMax:(float)yMax {
	if(xMax >= CGRectGetMaxX(rect) && yMax >= CGRectGetMaxY(rect)) {
		[image drawInRect:rect];
		return;
	}
	CGRect rcClip = rect;
	if(xMax < CGRectGetMaxX(rect))
		rcClip.size.width = xMax - rcClip.origin.x;
	if(yMax < CGRectGetMaxY(rect))
		rcClip.size.height = yMax - rcClip.origin.y;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextClipToRect(ctx, rcClip);
	[image drawInRect:rect];
	CGContextRestoreGState(ctx);
}

- (void)setArrowPosRel:(float)arrowPosRel {
	arrowPosRel = MAX(MIN(arrowPosRel, 1.0), 0.0);
	if(_arrowPosRel != arrowPosRel) {
		_arrowPosRel = arrowPosRel;
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	UIImage *imageL = [UIImage imageNamed:@"VLPopupBubbleView_left.png"];
	UIImage *imageR = [UIImage imageNamed:@"VLPopupBubbleView_right.png"];
	UIImage *imageM = [UIImage imageNamed:@"VLPopupBubbleView_middle.png"];
	UIImage *imageMA = [UIImage imageNamed:@"VLPopupBubbleView_middle_arrow.png"];
	if(!imageL || !imageR || !imageM || !imageMA)
		return;
	
	CGRect rcL = rcBnds;
	rcL.size.width = round(rcL.size.height * imageL.size.width / imageL.size.height);
	[imageL drawInRect:rcL];
	
	CGRect rcR = rcBnds;
	rcR.size.width = round(rcR.size.height * imageR.size.width / imageR.size.height);
	rcR.origin.x = CGRectGetMaxX(rcBnds) - rcR.size.width;
	[imageR drawInRect:rcR];
	
	CGRect rcMA = rcBnds;
	rcMA.size.width = round(rcMA.size.height * imageMA.size.width / imageMA.size.height);
	rcMA.origin.x = round(rcBnds.origin.x + rcBnds.size.width * _arrowPosRel - rcMA.size.width/2);
	[imageMA drawInRect:rcMA];
	
	CGSize szM = rcBnds.size;
	szM.width = round(szM.height * imageM.size.width / imageM.size.height);
	for(float x = CGRectGetMaxX(rcL); ; x += szM.width) {
		float xMax = rcMA.origin.x;
		if(x >= xMax)
			break;
		CGRect rcM = rcBnds;
		rcM.size = szM;
		rcM.origin.x = x;
		[self drawImage:imageM
				 inRect:rcM
				   xMax:xMax yMax:CGRectGetMaxY(rcBnds)];
	}
	for(float x = CGRectGetMaxX(rcMA); ; x += szM.width) {
		float xMax = CGRectGetMaxX(rcBnds) - rcR.size.width;
		if(x >= xMax)
			break;
		CGRect rcM = rcBnds;
		rcM.size = szM;
		rcM.origin.x = x;
		[self drawImage:imageM
				 inRect:rcM
				   xMax:xMax yMax:CGRectGetMaxY(rcBnds)];
	}
}

- (float)minArrowPosRelForSize:(CGSize)size {
	if(size.width < 1 || size.height < 1)
		return 0;
	UIImage *imageL = [UIImage imageNamed:@"VLPopupBubbleView_left.png"];
	UIImage *imageMA = [UIImage imageNamed:@"VLPopupBubbleView_middle_arrow.png"];
	if(!imageL || !imageMA)
		return 0.0;
	CGSize szL = size;
	szL.width = round(szL.height * imageL.size.width / imageL.size.height);
	CGSize szMA = size;
	szMA.width = round(szMA.height * imageMA.size.width / imageMA.size.height);
	float res = (szL.width + szMA.width/2) / size.width;
	return res;
}
- (float)maxArrowPosRelForSize:(CGSize)size {
	if(size.width < 1 || size.height < 1)
		return 0;
	UIImage *imageR = [UIImage imageNamed:@"VLPopupBubbleView_right.png"];
	UIImage *imageMA = [UIImage imageNamed:@"VLPopupBubbleView_middle_arrow.png"];
	if(!imageR || !imageMA)
		return 0.0;
	CGSize szR = size;
	szR.width = round(szR.height * imageR.size.width / imageR.size.height);
	CGSize szMA = size;
	szMA.width = round(szMA.height * imageMA.size.width / imageMA.size.height);
	float res = (size.width - szR.width - szMA.width/2) / size.width;
	return res;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	float side = MIN(rcBnds.size.width, rcBnds.size.height);
	float dTop = round(side * kTopEdgeRel);
	float dLeft = round(side * kLeftEdgeRel);
	float dRight = round(side * kRightEdgeRel);
	float dBottom = round(side * kBottomEdgeRel);
	CGRect rcLabel = UIEdgeInsetsInsetRect(rcBnds, UIEdgeInsetsMake(dTop, dLeft, dBottom, dRight));
	_lbTitle.frame = [UIScreen roundRect:rcLabel];
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize szText = [_lbTitle sizeOfText];
	float height = ceil(szText.height / (1 - (kTopEdgeRel + kBottomEdgeRel)));
	float width = ceil(height * kLeftEdgeRel + szText.width + height * kRightEdgeRel);
	if(width < height * kMinScale)
		width = height * kMinScale;
	size.width = round(width);
	size.height = round(height);
	return size;
}

- (void) pulse {
	// pulse animation thanks to:  http://delackner.com/blog/2009/12/mimicking-uialertviews-animated-transition/
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
	[UIView animateWithDuration: 0.2
					 animations: ^{
						 self.transform = CGAffineTransformMakeScale(1.1, 1.1);
					 }
					 completion: ^(BOOL finished){
						 [UIView animateWithDuration:1.0/15.0
										  animations: ^{
											  self.transform = CGAffineTransformMakeScale(0.9, 0.9);
										  }
										  completion: ^(BOOL finished){
											  [UIView animateWithDuration:1.0/7.5
															   animations: ^{
																   self.transform = CGAffineTransformIdentity;
															   }];
										  }];
					 }];
	
}

- (CGRect)rectThatFitsWithSuperview:(UIView*)superview point:(CGPoint)point {
	CGSize size = CGSizeMake(10000, 10000);
	size = [self sizeThatFits:size];
	//float minArrowPosRel = [self minArrowPosRelForSize:size];
	//float maxArrowPosRel = [self maxArrowPosRelForSize:size];
	//float arrowPosRel = 0.5;
	CGRect rect = CGRectZero;
	rect.size = size;
	rect.origin.x = point.x - size.width / 2;
	rect.origin.y = point.y - size.height;
	//CGRect rectOnWnd = [superview convertRect:rect toView:superview];
	return rect;
}

- (void)showInView:(UIView*)superview point:(CGPoint)point animated:(BOOL)animated {
	CGRect rect = [self rectThatFitsWithSuperview:superview point:point];
	self.frame = rect;
	if(superview != self.superview)
		[superview addSubview:self];
	self.hidden = NO;
	if(animated) {
		[self pulse];
	} else {
	}
}

- (void)hideFromSuperviewAnimated:(BOOL)animated {
	if(self.superview) {
		[[self retain] autorelease];
		if(animated) {
			[self removeFromSuperview];
		} else {
			[self removeFromSuperview];
		}
	}
}

- (void)dealloc {
	[_lbTitle release];
	[super dealloc];
}

@end

