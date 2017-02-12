
#import "YTNoteContentSeparator.h"

//#define kColorTop [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]
//#define kColorBottom [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]
#define kColorTop [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]
#define kColorBottom [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]
#define kColorSingleLine [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]

@implementation YTNoteContentSeparator

@synthesize style = _style;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (CGSize)sizeThatFits:(CGSize)size {
	if(_style == EYTNoteContentSeparatorStyleOneLine)
		size.height = 1;
	else
		size.height = 2;
	return size;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	if(_style == EYTNoteContentSeparatorStyleOneLine) {
		[kColorSingleLine setFill];
		CGContextFillRect(ctx, rcBnds);
	} else {
		float midY = CGRectGetMidY(rcBnds);
		midY = round(midY);
		CGRect rcTop = rcBnds;
		rcTop.size.height = 1;
		rcTop.origin.y = midY - 1;
		CGRect rcBot = rcBnds;
		rcBot.size.height = 1;
		rcBot.origin.y = midY;
		[kColorTop setFill];
		CGContextFillRect(ctx, rcTop);
		[kColorBottom setFill];
		CGContextFillRect(ctx, rcBot);
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

