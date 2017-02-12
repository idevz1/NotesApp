
#import "VLPopupTipsManager.h"
#import "../Logic/Classes.h"
#import "../Common/Classes.h"


@interface VLPopupTipInfo : NSObject <NSCoding> {
@private
	NSString *_identifier;
	NSString *_title;
	NSString *_text;
	BOOL _shown;
	NSString *_viewKey;
	UIView *_viewPointer;
	int _orderIndex;
}

@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, assign) BOOL shown;
@property(nonatomic, retain) NSString *viewKey;
@property(nonatomic, assign) UIView *viewPointer;
@property(nonatomic, assign) int orderIndex;

@end



@implementation VLPopupTipInfo

@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize text = _text;
@synthesize shown = _shown;
@synthesize viewKey = _viewKey;
@synthesize viewPointer = _viewPointer;
@synthesize orderIndex = _orderIndex;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		if(aDecoder) {
			_identifier = [aDecoder decodeObjectForKey:@"_identifier"];
			if(!_identifier)
				_identifier = @"";
			[_identifier retain];
			_title = [aDecoder decodeObjectForKey:@"_title"];
			if(!_title)
				_title = @"";
			[_title retain];
			_text = [aDecoder decodeObjectForKey:@"_text"];
			if(!_text)
				_text = @"";
			[_text retain];
			_shown = [aDecoder decodeBoolForKey:@"_shown"];
			_orderIndex = [aDecoder decodeIntForKey:@"_orderIndex"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_identifier forKey:@"_identifier"];
	[aCoder encodeObject:_title forKey:@"_title"];
	[aCoder encodeObject:_text forKey:@"_text"];
	[aCoder encodeBool:_shown forKey:@"_shown"];
	[aCoder encodeInt:_orderIndex forKey:@"_orderIndex"];
}

- (void)dealloc {
	[_identifier release];
	[_title release];
	[_text release];
	[_viewKey release];
	[super dealloc];
}

@end




@interface VLPopupTipView_BaseView : UIView {
@private
	VLPopupTipInfo *_tipInfo;
}

@property(nonatomic, assign) VLPopupTipInfo *tipInfo;

- (void)onTipInfoChanged;

@end



@interface VLPopupTipView_ShadeView : VLPopupTipView_BaseView {
@private
	CGRect _rectHole;
}

@property(nonatomic, assign) CGRect rectHole;

@end


typedef enum
{
	EVLPopupTipViewArrowDirectionNone,
	EVLPopupTipViewArrowDirectionTop,
	EVLPopupTipViewArrowDirectionBottom
}
EVLPopupTipViewArrowDirection;



@interface VLPopupTipView_InfoView : VLPopupTipView_BaseView {
@private
	EVLPopupTipViewArrowDirection _arrowDirection;
	float _arrowOffset;
	UILabel *_labelTitle;
	UILabel *_labelInfo;
	UIButton *_buttonSkip;
	UIButton *_buttonOkay;
}

@property(nonatomic, assign) EVLPopupTipViewArrowDirection arrowDirection;
@property(nonatomic, assign) float arrowOffset;
@property(nonatomic, readonly) UIButton *buttonSkip;
@property(nonatomic, readonly) UIButton *buttonOkay;

@end



@interface VLPopupTipView_TagView : VLPopupTipView_BaseView {
@private
}

@end



@interface VLPopupTipView : VLPopupTipView_BaseView {
@private
	VLPopupTipView_ShadeView *_shadeView;
	VLPopupTipView_InfoView *_infoView;
	VLPopupTipView_InfoView *_fakeInfoView;
}

@property(nonatomic, readonly) VLPopupTipView_InfoView *infoView;

- (void)updateFrame;

@end



@interface VLPopupTipsManager()

- (void)hideTipView:(VLPopupTipView *)tipView;
- (void)hideTipViewWithInfo:(VLPopupTipInfo *)tipInfo;

@end



@implementation VLPopupTipView_BaseView

@synthesize tipInfo = _tipInfo;

- (void)setTipInfo:(VLPopupTipInfo *)tipInfo {
	if(_tipInfo != tipInfo) {
		if(_tipInfo)
			[_tipInfo release];
		_tipInfo = tipInfo;
		if(_tipInfo) {
			[_tipInfo retain];
			[self onTipInfoChanged];
		}
	}
}

- (void)onTipInfoChanged {
	
}

- (void)dealloc {
	[_tipInfo release];
	[super dealloc];
}

@end



@implementation VLPopupTipView_ShadeView

@synthesize rectHole = _rectHole;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setRectHole:(CGRect)rectHole {
	if(!CGRectEqualToRect(_rectHole, rectHole)) {
		_rectHole = rectHole;
	}
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIColor *colorBack = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
	if(_rectHole.size.width > 0 && _rectHole.size.height > 0 && CGRectIntersectsRect(_rectHole, rcBnds)) {
		CGPathRef pathBnds = CGPathCreateWithRect(rcBnds, nil);
		CGPathRef pathHole = CGPathCreateWithRect(_rectHole, nil);
		
		CGContextAddPath(ctx, pathBnds);
		CGContextAddPath(ctx, pathHole);
		CGContextSetFillColorWithColor(ctx, colorBack.CGColor);
		CGContextEOFillPath(ctx);
		
		CGPathRelease(pathHole);
		CGPathRelease(pathBnds);
	} else {
		[colorBack setFill];
		CGContextFillRect(ctx, rcBnds);
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[super dealloc];
}

@end



@implementation VLPopupTipView_InfoView

@synthesize arrowDirection = _arrowDirection;
@synthesize arrowOffset = _arrowOffset;
@synthesize buttonSkip = _buttonSkip;
@synthesize buttonOkay = _buttonOkay;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor clearColor];
		
		_labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		_labelInfo = [[UILabel alloc] initWithFrame:CGRectZero];
		NSArray *labels = [NSArray arrayWithObjects:_labelTitle, _labelInfo, nil];
		for(UILabel *label in labels) {
			label.backgroundColor = [UIColor clearColor];
			label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			label.numberOfLines = 0;
			label.lineBreakMode = NSLineBreakByWordWrapping;
			[self addSubview:label];
		}
		_labelTitle.textColor = [UIColor colorWithRed:248/255.0 green:100/255.0 blue:0/255.0 alpha:1.0];
		_labelTitle.font = [UIFont systemFontOfSize:18];
		_labelInfo.font = [UIFont systemFontOfSize:17];
		
		_buttonSkip = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_buttonOkay = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		NSArray *buttons = [NSArray arrayWithObjects:_buttonSkip, _buttonOkay, nil];
		for(UIButton *button in buttons) {
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[self addSubview:button];
		}
		[_buttonSkip setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		
		[_buttonSkip setTitle:@"Skip all tutorials" forState:UIControlStateNormal];
		[_buttonOkay setTitle:@"Okay!" forState:UIControlStateNormal];
	}
	return self;
}

- (void)setArrowDirection:(EVLPopupTipViewArrowDirection)arrowDirection {
	if(_arrowDirection != arrowDirection) {
		_arrowDirection = arrowDirection;
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

- (void)setArrowOffset:(float)arrowOffset {
	if(_arrowOffset != arrowOffset) {
		_arrowOffset = arrowOffset;
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

- (void)onTipInfoChanged {
	VLPopupTipInfo *tipInfo = self.tipInfo;
	if(tipInfo) {
		_labelTitle.text = tipInfo.title;
		_labelInfo.text = tipInfo.text;
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

- (UIEdgeInsets)contentInsets {
	float inset = 8.0;
	UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, 1.0, inset);
	return insets;
}

- (float)distX {
	return 8.0;
}

- (float)distY {
	return 8.0;
}

- (float)buttonHeight {
	return 38.0;
}

- (float)arrowHeight {
	return 10.0;
}

- (float)titleSeparatorSize {
	return 2.0;
}

- (float)buttonsSeparatorSize {
	return 1.0;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	UIEdgeInsets insets = [self contentInsets];
	float distY = [self distY];
	float arrowHeight = [self arrowHeight];
	float titleSepSize = [self titleSeparatorSize];
	float buttonsSepSize = [self buttonsSeparatorSize];
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, insets);
	if(_arrowDirection == EVLPopupTipViewArrowDirectionTop) {
		rcCtrls.origin.y += arrowHeight;
		rcCtrls.size.height -= arrowHeight;
	} else if(_arrowDirection == EVLPopupTipViewArrowDirectionBottom) {
		rcCtrls.size.height -= arrowHeight;
	}
	float contentWidth = rcCtrls.size.width;
	CGRect rcTitle = rcCtrls;
	NSString *sTitle = _labelTitle.text;
	if(!sTitle || !sTitle.length)
		sTitle = @"W";
	CGSize szTitle = [sTitle vlSizeWithFont:_labelTitle.font constrainedToSize:CGSizeMake(contentWidth, INT_MAX) lineBreakMode:_labelTitle.lineBreakMode];
	rcTitle.size.height = szTitle.height + ABS(_labelTitle.shadowOffset.height);
	NSString *sInfo = _labelInfo.text;
	if(!sInfo || !sInfo.length)
		sInfo = @"W";
	CGRect rcInfo = rcCtrls;
	rcInfo.origin.y = CGRectGetMaxY(rcTitle) + distY + titleSepSize + distY;
	CGSize szInfo = [sInfo vlSizeWithFont:_labelInfo.font constrainedToSize:CGSizeMake(contentWidth, INT_MAX) lineBreakMode:_labelInfo.lineBreakMode];
	rcInfo.size.height = szInfo.height + ABS(_labelInfo.shadowOffset.height);
	CGRect rcButns = rcCtrls;
	rcButns.origin.y = CGRectGetMaxY(rcInfo) + distY + buttonsSepSize;
	rcButns.size.height = CGRectGetMaxY(rcCtrls) - rcButns.origin.y;
	CGRect rcBtnSkip = rcButns;
	rcBtnSkip.size.width = (int)(rcButns.size.width/2 - buttonsSepSize/2);
	CGRect rcBtnOK = rcButns;
	rcBtnOK.origin.x = CGRectGetMaxX(rcBtnSkip) + buttonsSepSize;
	rcBtnOK.size.width = CGRectGetMaxX(rcCtrls) - rcBtnOK.origin.x;
	_labelTitle.frame = rcTitle;
	_labelInfo.frame = rcInfo;
	_buttonOkay.frame = rcBtnOK;
	_buttonSkip.frame = rcBtnSkip;
	[self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 0;
	UIEdgeInsets insets = [self contentInsets];
	float distY = [self distY];
	float buttonHeight = [self buttonHeight];
	float arrowHeight = [self arrowHeight];
	float titleSepSize = [self titleSeparatorSize];
	float buttonsSepSize = [self buttonsSeparatorSize];
	float contentWidth = size.width - insets.left - insets.right;
	if(_arrowDirection == EVLPopupTipViewArrowDirectionTop)
		size.height += arrowHeight;
	size.height += insets.top;
	NSString *sTitle = _labelTitle.text;
	if(!sTitle || !sTitle.length)
		sTitle = @"W";
	CGSize szTitle = [sTitle vlSizeWithFont:_labelTitle.font constrainedToSize:CGSizeMake(contentWidth, INT_MAX) lineBreakMode:_labelTitle.lineBreakMode];
	size.height += szTitle.height + ABS(_labelTitle.shadowOffset.height);
	size.height += distY;
	size.height += titleSepSize;
	size.height += distY;
	NSString *sInfo = _labelInfo.text;
	if(!sInfo || !sInfo.length)
		sInfo = @"W";
	CGSize szInfo = [sInfo vlSizeWithFont:_labelInfo.font constrainedToSize:CGSizeMake(contentWidth, INT_MAX) lineBreakMode:_labelInfo.lineBreakMode];
	size.height += szInfo.height + ABS(_labelInfo.shadowOffset.height);
	size.height += distY;
	size.height += buttonsSepSize;
	size.height += buttonHeight;
	size.height += insets.bottom;
	if(_arrowDirection == EVLPopupTipViewArrowDirectionBottom)
		size.height += arrowHeight;
	return size;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	float arrowHeight = [self arrowHeight];
	float titleSepSize = [self titleSeparatorSize];
	float buttonsSepSize = [self buttonsSeparatorSize];
	float distY = [self distY];
	CGRect rcBnds = self.bounds;
	CGRect rcBubble = rcBnds;
	if(_arrowDirection == EVLPopupTipViewArrowDirectionTop) {
		rcBubble.origin.y += arrowHeight;
		rcBubble.size.height -= arrowHeight;
	} else if(_arrowDirection == EVLPopupTipViewArrowDirectionBottom) {
		rcBubble.size.height -= arrowHeight;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float corner = 4.0;
	//UIColor *colorBack = [UIColor colorWithRed:0.99 green:0.99 blue:0.89 alpha:0.75];
	UIColor *colorBack = [UIColor colorWithRed:0.99 green:0.99 blue:0.89 alpha:1.0];
	UIColor *colorBorder = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
	float borderW = 1.0;
	
	CGRect rcRect = rcBubble;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, rcRect.origin.x + corner, rcRect.origin.y);
	if(_arrowDirection == EVLPopupTipViewArrowDirectionTop) {
		float cx = rcBnds.origin.x + _arrowOffset;
		float dd = arrowHeight;
		if((cx - dd) < (rcRect.origin.x + corner))
			cx -= (cx - dd) - (rcRect.origin.x + corner);
		if((cx + dd) > (CGRectGetMaxX(rcRect) - corner))
			cx -= (cx + dd) - (CGRectGetMaxX(rcRect) - corner);
		CGPathAddLineToPoint(path, nil, cx - dd, rcRect.origin.y);
		CGPathAddLineToPoint(path, nil, cx, rcRect.origin.y - dd);
		CGPathAddLineToPoint(path, nil, cx + dd, rcRect.origin.y);
	}
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(rcRect) - corner, rcRect.origin.y);
	CGPathAddArc(path, nil, CGRectGetMaxX(rcRect) - corner, rcRect.origin.y + corner, corner, -M_PI/2, 0, 0);
	CGPathAddLineToPoint(path, nil, CGRectGetMaxX(rcRect), CGRectGetMaxY(rcRect) - corner);
	CGPathAddArc(path, nil, CGRectGetMaxX(rcRect) - corner, CGRectGetMaxY(rcRect) - corner, corner, 0, M_PI/2, 0);
	if(_arrowDirection == EVLPopupTipViewArrowDirectionBottom) {
		float cx = rcBnds.origin.x + _arrowOffset;
		float dd = arrowHeight;
		if((cx - dd) < (rcRect.origin.x + corner))
			cx -= (cx - dd) - (rcRect.origin.x + corner);
		if((cx + dd) > (CGRectGetMaxX(rcRect) - corner))
			cx -= (cx + dd) - (CGRectGetMaxX(rcRect) - corner);
		CGPathAddLineToPoint(path, nil, cx - dd, CGRectGetMaxY(rcRect));
		CGPathAddLineToPoint(path, nil, cx, CGRectGetMaxY(rcRect) + dd);
		CGPathAddLineToPoint(path, nil, cx + dd, CGRectGetMaxY(rcRect));
	}
	CGPathAddLineToPoint(path, nil, rcRect.origin.x + corner, CGRectGetMaxY(rcRect));
	CGPathAddArc(path, nil, rcRect.origin.x + corner, CGRectGetMaxY(rcRect) - corner, corner, M_PI/2, M_PI, 0);
	CGPathAddLineToPoint(path, nil, rcRect.origin.x, rcRect.origin.y + corner);
	CGPathAddArc(path, nil, rcRect.origin.x + corner, rcRect.origin.y + corner, corner, M_PI, 3*M_PI/2, 0);
	
	CGContextAddPath(ctx, path);
	[colorBack setFill];
	CGContextFillPath(ctx);
	[colorBorder setStroke];
	CGContextSetLineWidth(ctx, borderW);
	CGContextStrokePath(ctx);
	
	CGPathRelease(path);
	
	UIColor *colorTitleSep = _labelTitle.textColor;
	CGRect rcTitleSep = rcBubble;
	rcTitleSep.origin.y = CGRectGetMaxY(_labelTitle.frame) + distY;
	rcTitleSep.size.height = titleSepSize;
	[colorTitleSep setFill];
	CGContextFillRect(ctx, rcTitleSep);
	
	UIColor *colorButtonsSep = [UIColor lightGrayColor];
	CGRect rcButnsSepVert = rcBubble;
	rcButnsSepVert.origin.y = CGRectGetMaxY(_labelInfo.frame) + distY;
	rcButnsSepVert.size.height = buttonsSepSize;
	[colorButtonsSep setFill];
	CGContextFillRect(ctx, rcButnsSepVert);
	CGRect rcButnsSepHorz = rcBubble;
	rcButnsSepHorz.origin.x = CGRectGetMaxX(_buttonSkip.frame);
	rcButnsSepHorz.size.width = buttonsSepSize;
	rcButnsSepHorz.origin.y = CGRectGetMaxY(rcButnsSepVert);
	rcButnsSepHorz.size.height = CGRectGetMaxY(rcBubble) - rcButnsSepHorz.origin.y;
	CGContextFillRect(ctx, rcButnsSepHorz);
}

- (void)dealloc {
	[_labelTitle release];
	[_labelInfo release];
	[_buttonSkip release];
	[_buttonOkay release];
	[super dealloc];
}

@end



@implementation VLPopupTipView_TagView

- (void)dealloc {
	if(self.tipInfo)
		[[VLPopupTipsManager shared] hideTipViewWithInfo:self.tipInfo];
	[super dealloc];
}

@end



@implementation VLPopupTipView

@synthesize infoView = _infoView;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor clearColor];
		_shadeView = [[VLPopupTipView_ShadeView alloc] initWithFrame:CGRectZero];
		[self addSubview:_shadeView];
		_infoView = [[VLPopupTipView_InfoView alloc] initWithFrame:CGRectZero];
		[self addSubview:_infoView];
		_fakeInfoView = [[VLPopupTipView_InfoView alloc] initWithFrame:CGRectZero];
		_fakeInfoView.hidden = YES;
	}
	return self;
}

- (void)onTipInfoChanged {
	[super onTipInfoChanged];
	VLPopupTipInfo *tipInfo = self.tipInfo;
	if(tipInfo) {
		_infoView.tipInfo = tipInfo;
		_fakeInfoView.tipInfo = tipInfo;
		[self updateFrame];
	}
}

- (void)updateFrame {
	UIWindow *window = self.window;
	if(window) {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if(orientation == UIInterfaceOrientationLandscapeLeft) {
			self.transform = CGAffineTransformMakeRotation(-M_PI/2);
		} else if(orientation == UIInterfaceOrientationLandscapeRight) {
			self.transform = CGAffineTransformMakeRotation(M_PI/2);
		} else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
			self.transform = CGAffineTransformMakeRotation(M_PI);
		} else {
			self.transform = CGAffineTransformIdentity;
		}
		
		CGRect rcAppBounds = [UIScreen mainScreen].bounds;
		CGRect rcAppFrame = [UIScreen mainScreen].applicationFrame;
		rcAppBounds = [window convertRect:rcAppBounds toView:self.superview];
		rcAppFrame = [window convertRect:rcAppFrame toView:self.superview];
		if(!CGRectEqualToRect(self.frame, rcAppBounds)) {
			self.frame = rcAppBounds;
		}
		VLPopupTipInfo *tipInfo = self.tipInfo;
		if(tipInfo) {
			CGRect rcBnds = [self.superview convertRect:rcAppFrame toView:self];
			UIView *targetView = tipInfo.viewPointer;
			CGRect rcTargetView = [targetView convertRect:targetView.bounds toView:self];
			CGRect rcInfoView = rcBnds;
			float edges = 8.0;
			rcInfoView = CGRectInset(rcInfoView, edges, edges);
			_fakeInfoView.arrowDirection = EVLPopupTipViewArrowDirectionTop;
			rcInfoView.size = [_fakeInfoView sizeThatFits:rcInfoView.size];
			rcInfoView.origin.y = CGRectGetMaxY(rcTargetView);
			if(CGRectGetMaxY(rcInfoView) > CGRectGetMaxY(rcBnds)) {
				if(rcInfoView.size.height <= (rcTargetView.origin.y - rcBnds.origin.y)) {
					rcInfoView.origin.y = rcTargetView.origin.y - rcInfoView.size.height;
					_fakeInfoView.arrowDirection = EVLPopupTipViewArrowDirectionBottom;
				}
			}
			_infoView.arrowDirection = _fakeInfoView.arrowDirection;
			_infoView.arrowOffset = CGRectGetMidX(rcTargetView) - rcInfoView.origin.x;
			_infoView.frame = rcInfoView;
			_shadeView.frame = self.bounds;
			_shadeView.rectHole = [self convertRect:rcTargetView toView:_shadeView];
		}
	}
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	UIView *superview = self.superview;
	[superview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
	[self updateFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	UIView *superview = self.superview;
	if(superview && object == superview && [keyPath isEqualToString:@"frame"]) {
		[self updateFrame];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	//[[VLPopupTipsManager shared] hideTipView:self];
}

- (void)dealloc {
	[_shadeView release];
	[_infoView release];
	[_fakeInfoView release];
	[super dealloc];
}

@end



#define kStorageDataKey @"VLPopupTipsManager_Data"
#define kStorageVersionKey @"VLPopupTipsManager_Version"

static VLPopupTipsManager *_shared;

@implementation VLPopupTipsManager

@synthesize delegate = _delegate;

+ (VLPopupTipsManager *)shared {
	if(!_shared)
		_shared = [[VLPopupTipsManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_dictInfoById = [[NSMutableDictionary alloc] init];
		_dictInfoByViewKey = [[NSMutableDictionary alloc] init];
		
		[self loadData];
		
		[NSTimer scheduledTimerWithTimeInterval:0.1
										 target:self
									   selector:@selector(onTimerEvent:)
									   userInfo:nil
										repeats:YES];
		
		//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	return self;
}

+ (void)setVersion:(int)version {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *numCurVersion = [defs objectForKey:kStorageVersionKey];
	if(numCurVersion) {
		int curVersion = numCurVersion.intValue;
		if(curVersion != version)
			numCurVersion = nil;
	}
	if(!numCurVersion) {
		numCurVersion = [NSNumber numberWithInt:version];
		[defs setObject:numCurVersion forKey:kStorageVersionKey];
		[defs synchronize];
		[[VLPopupTipsManager shared] clearData];
		[[VLPopupTipsManager shared] saveData];
	}
}

- (void)clearData {
	[_dictInfoById removeAllObjects];
	[_dictInfoByViewKey removeAllObjects];
}

- (void)saveData {
	_needsSave = NO;
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_dictInfoById];
	[defs setObject:data forKey:kStorageDataKey];
	[defs synchronize];
}

- (void)loadData {
	[self clearData];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSDictionary *dictInfoById = nil;
	NSData *data = [defs dataForKey:kStorageDataKey];
	if(data)
		dictInfoById = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(dictInfoById)
		[_dictInfoById addEntriesFromDictionary:dictInfoById];
	for(VLPopupTipInfo *tipInfo in _dictInfoById.allValues)
		if(tipInfo.orderIndex >= _curNewTipOrderIndex)
			_curNewTipOrderIndex = tipInfo.orderIndex + 1;
	_needsSave = NO;
}

- (void)showTipWithInfo:(VLPopupTipInfo *)tipInfo {
	_lastAppFrame = [UIScreen mainScreen].applicationFrame;
	VLPopupTipView *tipView = [[[VLPopupTipView alloc] initWithFrame:CGRectZero] autorelease];

	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window addSubview:tipView];
	tipView.tipInfo = tipInfo;
	[_visibleTipView release];
	_visibleTipView = [tipView retain];
	[_visibleTipView.infoView.buttonSkip addTarget:self action:@selector(onButtonSkipTapped:) forControlEvents:UIControlEventTouchUpInside];
	[_visibleTipView.infoView.buttonOkay addTarget:self action:@selector(onButtonOkayTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideTipView:(VLPopupTipView *)tipView {
	[[tipView retain] autorelease];
	VLPopupTipInfo *tipInfo = tipView.tipInfo;
	if(!tipInfo.shown) {
		tipInfo.shown = YES;
		[self setNeedsSave];
	}
	[tipView removeFromSuperview];
	[_visibleTipView release];
	_visibleTipView = nil;
}

- (void)hideTipViewWithInfo:(VLPopupTipInfo *)tipInfo currentSuperview:(UIView *)curSuperview {
	for(UIView *view in curSuperview.subviews) {
		if([view isKindOfClass:[VLPopupTipView class]]) {
			VLPopupTipView *tipView = (VLPopupTipView *)view;
			if(tipView.tipInfo == tipInfo) {
				[self hideTipView:tipView];
				return;
			}
		}
		[self hideTipViewWithInfo:tipInfo currentSuperview:view];
	}
}


- (void)hideTipViewWithInfo:(VLPopupTipInfo *)tipInfo {
	[self hideTipViewWithInfo:tipInfo currentSuperview:[UIApplication sharedApplication].keyWindow];
}

- (void)skipAllTips {
	for(VLPopupTipInfo *tipInfo in _dictInfoById.allValues) {
		if(!tipInfo.shown) {
			tipInfo.shown = YES;
			[self setNeedsSave];
		}
	}
}

- (void)onButtonSkipTapped:(id)sender {
	[self hideTipView:_visibleTipView];
	
	// Skip all:
	if(_delegate && [_delegate respondsToSelector:@selector(popupTipsManager:shouldSkipAllTipsWithResultBlock:)]) {
		[_delegate popupTipsManager:self shouldSkipAllTipsWithResultBlock:^(BOOL cancel) {
			if(!cancel)
				[self skipAllTips];
		}];
	} else
		[self skipAllTips];
}

- (void)onButtonOkayTapped:(id)sender {
	[self hideTipView:_visibleTipView];
}

- (VLPopupTipView_TagView *)tagViewFormView:(UIView *)view {
	for(UIView *subview in view.subviews)
		if([subview isKindOfClass:[VLPopupTipView_TagView class]])
			return (VLPopupTipView_TagView *)subview;
	return nil;
}

- (void)setTipWithIdentifier:(NSString *)identifier title:(NSString *)title text:(NSString *)text targetView:(UIView *)targetView {
	if(!identifier)
		identifier = @"";
	if(!title)
		title = @"";
	if(!text)
		text = @"";
	if(!targetView)
		return;
	BOOL needsSave = NO;
	VLPopupTipInfo *tipInfo = [_dictInfoById objectForKey:identifier];
	if(!tipInfo) {
		tipInfo = [[[VLPopupTipInfo alloc] init] autorelease];
		tipInfo.identifier = identifier;
		tipInfo.orderIndex = ++_curNewTipOrderIndex;
		[_dictInfoById setObject:tipInfo forKey:identifier];
		needsSave = YES;
	}
	if(![tipInfo.title isEqual:title] || ![tipInfo.text isEqual:text])
		needsSave = YES;
	tipInfo.title = title;
	tipInfo.text = text;
	tipInfo.viewPointer = targetView;
	
	VLPopupTipView_TagView *tagView = [self tagViewFormView:targetView];
	if(!tagView) {
		tagView = [[[VLPopupTipView_TagView alloc] initWithFrame:CGRectZero] autorelease];
		tagView.hidden = YES;
		tagView.tipInfo = tipInfo;
		[targetView addSubview:tagView];
	}
	
	NSString *viewKey = [NSString stringWithFormat:@"%p", targetView];
	[_dictInfoByViewKey setObject:tipInfo forKey:viewKey];
	
	if(needsSave)
		[self setNeedsSave];
}

- (void)setTipWithIdentifier:(NSString *)identifier title:(NSString *)title text:(NSString *)text targetBarItem:(UIBarItem *)targetBarItem {
	if(!targetBarItem)
		return;
	[[VLMessageCenter shared] performBlock:^{
		UIView *targetView = [targetBarItem valueForKey:@"view"];
		if(!targetView)
			return;
		[self setTipWithIdentifier:identifier title:title text:text targetView:targetView];
	} afterDelay:0.1 ignoringTouches:NO];
}

- (BOOL)checkViewVisible:(UIView *)view {
	if(view.hidden || !view.window)
		return NO;
	UIView *superview = view.superview;
	while(superview) {
		if(superview.hidden)
			return NO;
		superview = superview.superview;
	}
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	CGRect rcAppFrame = [UIScreen mainScreen].applicationFrame;
	CGRect rcView = [view convertRect:view.bounds toView:window];
	if(!CGRectIntersectsRect(rcAppFrame, rcView))
		return NO;
	return YES;
}

- (void)processSubViewsInSuperview:(UIView *)superview resultInfos:(NSMutableArray *)resultInfos {
	if(_visibleTipView || superview.hidden)
		return;
	for(UIView *subview in superview.subviews) {
		if(subview.hidden)
			continue;
		NSString *viewKey = [[NSString alloc] initWithFormat:@"%p", subview];
		VLPopupTipInfo *info = [_dictInfoByViewKey objectForKey:viewKey];
		[viewKey release];
		if(info && !info.shown) {
			if([self checkViewVisible:subview]) {
				info.viewPointer = subview;
				[resultInfos addObject:info];
				//[self showTipWithInfo:info];
				//break;
			}
		}
		[self processSubViewsInSuperview:subview resultInfos:resultInfos];
	}
}

- (void)onTimerEvent:(id)sender {
	_timerCounter++;
	if(_visibleTipView) {
		CGRect rcFrame = [UIScreen mainScreen].applicationFrame;
		if(!CGRectEqualToRect(_lastAppFrame, rcFrame)) {
			_lastAppFrame = rcFrame;
			[_visibleTipView updateFrame];
		}
	}
	if((_timerCounter % 10) == 0) {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		NSMutableArray *resultInfos = [NSMutableArray array];
		[self processSubViewsInSuperview:window resultInfos:resultInfos];
		[resultInfos sortUsingComparator:^NSComparisonResult(VLPopupTipInfo *obj1, VLPopupTipInfo *obj2) {
			return obj1.orderIndex - obj2.orderIndex;
		}];
		if(resultInfos.count) {
			VLPopupTipInfo *info = [resultInfos objectAtIndex:0];
			[self showTipWithInfo:info];
		}
	}
	if(_needsSave) {
		[self saveData];
	}
}

- (void)onOrientationChanged:(NSNotification *)notification {
	if(_visibleTipView) {
		[_visibleTipView updateFrame];
	}
}

- (void)setNeedsSave {
	_needsSave = YES;
}

- (void)dealloc {
	[_dictInfoById release];
	[_dictInfoByViewKey release];
	[super dealloc];
}

@end

