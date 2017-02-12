
#import "YTMainStatusView.h"

@implementation YTMainStatusView

@synthesize delegate = _delegate;
@synthesize shouldBeShown = _shouldBeShown;

+ (UIFont *)labelFont {
	return [[YTFontsManager shared] boldFontWithSize:10 fixed:YES];
}

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor cyanColor];
	
	_labelTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelTitle.backgroundColor = [UIColor clearColor];
	_labelTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelTitle.textAlignment = NSTextAlignmentRight;
	_labelTitle.textColor = [UIColor darkGrayColor];
	[self addSubview:_labelTitle];
	
	_labelValue = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelValue.backgroundColor = [UIColor clearColor];
	_labelValue.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelValue.textColor = [UIColor lightGrayColor];
	[self addSubview:_labelValue];
	
	[[YTResourcesStorage shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	
	[self updateFonts:self];
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	_labelTitle.font = _labelValue.font = [[self class] labelFont];
	if(sender != self) {
		[self setNeedsLayout];
		if(self.superview)
			[self.superview setNeedsLayout];
	}
}

- (void)internalSetShouldBeShown:(BOOL)shouldBeShown {
	if(_shouldBeShown != shouldBeShown) {
		_shouldBeShown = shouldBeShown;
		if(_delegate && [_delegate respondsToSelector:@selector(mainStatusView:statusChanged:)])
			[_delegate mainStatusView:self statusChanged:nil];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourcesStorage *resourcesStorage = [YTResourcesStorage shared];
	int downloadingFilesCount = resourcesStorage.downloadingFilesCount;
	if(downloadingFilesCount > 0) {
		// TODO: localize later
		_labelTitle.text = NSLocalizedString(@"DOWNLOADING FILES:", nil);
		_labelValue.text = [NSString stringWithFormat:@"%d", downloadingFilesCount];
		[self internalSetShouldBeShown:YES];
	} else {
		_labelTitle.text = @"";
		_labelValue.text = @"";
		[self internalSetShouldBeShown:NO];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	float space = 4.0;
	CGRect rcLabelTitle = rcBnds;
	rcLabelTitle.size.width = (int)(rcBnds.size.width/2 - space/2);
	CGRect rcLabelValue = rcBnds;
	rcLabelValue.origin.x = CGRectGetMaxX(rcLabelTitle) + space;
	rcLabelValue.size.width = CGRectGetMaxX(rcBnds) - rcLabelValue.origin.x;
	_labelTitle.frame = rcLabelTitle;
	_labelValue.frame = rcLabelValue;
}

- (CGSize)sizeThatFits:(CGSize)size {
	UIFont *labelFont = [[self class] labelFont];
	size.height = [@"W" vlSizeWithFont:labelFont].height;
	return size;
}

- (void)dealloc {
	[[YTResourcesStorage shared].msgrVersionChanged removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_labelTitle release];
	[_labelValue release];
	[super dealloc];
}

@end

