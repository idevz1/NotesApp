
#import "YTSplashView.h"

#define kBackColor [UIColor colorWithRed:94/255.0 green:125/255.0 blue:154/255.0 alpha:1.0]
#define kTopBottomStripColor [UIColor colorWithRed:35/255.0 green:40/255.0 blue:44/255.0 alpha:1.0]
#define kTopStripHeight ((kIosVersionFloat >= 7.0) ? 72.0 : 52)
#define kBottomStripHeight 52.0

@implementation YTSplashView

- (void)initialize {
	[super initialize];
	self.backgroundColor = kBackColor;
	
	_topStrip = [[UIView alloc] initWithFrame:CGRectZero];
	[self addSubview:_topStrip];
	_bottomStrip = [[UIView alloc] initWithFrame:CGRectZero];
	[self addSubview:_bottomStrip];
	_topStrip.backgroundColor = _bottomStrip.backgroundColor = kTopBottomStripColor;
	
	_imageSnippet = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageSnippet.backgroundColor = [UIColor clearColor];
	_imageSnippet.image = [UIImage imageNamed:@"splash_strip_arrow.png" scale:2];
	[self addSubview:_imageSnippet];
	
	_imagePageCtrl = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imagePageCtrl.backgroundColor = [UIColor clearColor];
	_imagePageCtrl.image = [UIImage imageNamed:@"splash_page_ctrl.png" scale:2];
	[self addSubview:_imagePageCtrl];
	
	_labelText1 = [[VLLabel alloc] initWithFrame:CGRectZero];
	[self addSubview:_labelText1];
	_labelText1.backgroundColor = [UIColor clearColor];
	_labelText1.textAlignment = NSTextAlignmentCenter;
	_labelText1.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelText1.textColor = [UIColor whiteColor];
	_labelText1.text = @"Your life history";
	
	_imageArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageArrow.backgroundColor = [UIColor clearColor];
	_imageArrow.image = [UIImage imageNamed:@"splash_arrow_right.png" scale:2];
	[self addSubview:_imageArrow];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_labelText1.font = [[YTFontsManager shared] lightFontWithSize:27 fixed:YES];
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcTopStrip = rcBnds;
	rcTopStrip.size.height = kTopStripHeight;
	_topStrip.frame = rcTopStrip;
	CGRect rcBotStrip = rcBnds;
	rcBotStrip.size.height = kBottomStripHeight;
	rcBotStrip.origin.y = CGRectGetMaxY(rcBnds) - rcBotStrip.size.height;
	_bottomStrip.frame = rcBotStrip;
	
	CGRect rcSnip = rcBnds;
	rcSnip.size = _imageSnippet.image.size;
	rcSnip.origin.y = rcBnds.origin.y + rcBnds.size.height * 0.35 - rcSnip.size.height/2;
	_imageSnippet.frame = [UIScreen roundRect:rcSnip];
	
	CGRect rcPgCt = rcBnds;
	rcPgCt.size = _imagePageCtrl.image.size;
	rcPgCt.origin.y = CGRectGetMaxY(rcBnds) - rcPgCt.size.height;
	rcPgCt.origin.x = CGRectGetMidX(rcBnds) - rcPgCt.size.width/2;
	_imagePageCtrl.frame = [UIScreen roundRect:rcPgCt];
	
	float baseY = rcBnds.origin.y + rcBnds.size.height * 0.75;
	CGRect rcText1 = rcBnds;
	rcText1.size.height = [_labelText1 sizeOfText].height;
	rcText1.origin.y = baseY - rcText1.size.height - rcText1.size.height * 0.33;
	_labelText1.frame = [UIScreen roundRect:rcText1];
	
	CGRect rcArrow = rcBnds;
	rcArrow.size = _imageArrow.image.size;
	rcArrow.origin.y = baseY + rcArrow.size.height * 0.21;
	rcArrow.origin.x = CGRectGetMidX(rcBnds) - rcArrow.size.width/2;
	_imageArrow.frame = [UIScreen roundRect:rcArrow];
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_topStrip release];
	[_bottomStrip release];
	[_imageSnippet release];
	[_imagePageCtrl release];
	[_labelText1 release];
	[_imageArrow release];
	[super dealloc];
}

@end

