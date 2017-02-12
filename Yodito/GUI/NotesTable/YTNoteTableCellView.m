
#import "YTNoteTableCellView.h"
#import "YTNotesTableView.h"

#define kDrawThumbOnMainThread NO//YES//NO

#define kInsetLeft 10.0
#define kInsetTop 7.0
#define kInsetRight 12.0
#define kInsetBottom 7.0
#define kThumbnailSize CGSizeMake(62, 56)//CGSizeMake(54, 54)
//#define kContentHeight (kInsetTop + kThumbnailSize.height + kInsetBottom)
#define kMaxTextLinesCount 3
#define kBottomSeparatorHeight 2.0
#define kDateColorNoImage [UIColor colorWithRed:0x30/255.0 green:0x30/255.0 blue:0x30/255.0 alpha:1.0]
//#define kDateColorNoImage [UIColor colorWithRed:0xEE/255.0 green:0x80/255.0 blue:0x30/255.0 alpha:1.0]
#define kDateColorWithImage [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
#define kSeparatorColorTop [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]
#define kSeparatorColorBottom [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

static UIFont *_fontForTextCapital;
static UIFont *_fontForTextContent;
static UIFont *_fontForLabelDateDay;
static UIFont *_fontForLabelDateWeekday;
static float _heightForTextCapitalLine = -1;
static float _heightForTextContentLine = -1;
static float _heightForLabelDateDay = -1;
static float _heightForLabelDateWeekday = -1;
static UIColor *_dateDayTextColorStarred = nil;



static YTNoteTableCellViewManager *_shared;

@implementation YTNoteTableCellViewManager

+ (YTNoteTableCellViewManager *)shared {
	if(!_shared)
		_shared = [[YTNoteTableCellViewManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(onFontsChanged:)];
	}
	return self;
}

- (void)initialize {
	
}

- (void)onFontsChanged:(id)sender {
	_fontForTextCapital = nil;
	_fontForTextContent = nil;
	_fontForLabelDateDay = nil;
	_fontForLabelDateWeekday = nil;
	_heightForTextCapitalLine = -1;
	_heightForTextContentLine = -1;
	_heightForLabelDateDay = -1;
	_heightForLabelDateWeekday = -1;
}

- (UIFont *)fontForTextCapital {
	if(!_fontForTextCapital)
		_fontForTextCapital = [[[YTFontsManager shared] fontNoteTextCapital] retain];
	return _fontForTextCapital;
}

- (UIFont *)fontForTextContent {
	if(!_fontForTextContent)
		_fontForTextContent = [[[YTFontsManager shared] fontNoteTextContent] retain];
	return _fontForTextContent;
}

- (UIFont *)fontForLabelDateDay {
	if(!_fontForLabelDateDay)
		_fontForLabelDateDay = [[[YTFontsManager shared] boldFontWithSize:26 fixed:YES] retain];
	return _fontForLabelDateDay;
}

- (UIFont *)fontForLabelDateWeekday {
	if(!_fontForLabelDateWeekday)
		_fontForLabelDateWeekday = [[[YTFontsManager shared] fontWithSize:8 fixed:YES] retain];
	return _fontForLabelDateWeekday;
}

- (float)heightForTextCapitalLine {
	if(_heightForTextCapitalLine < 0)
		_heightForTextCapitalLine = [@"W" vlSizeWithFont:[self fontForTextCapital]].height;
	return _heightForTextCapitalLine;
}

- (float)heightForTextContentLine {
	if(_heightForTextContentLine < 0)
		_heightForTextContentLine = [@"W" vlSizeWithFont:[self fontForTextContent]].height;
	return _heightForTextContentLine;
}

- (float)heightForLabelDateDay {
	if(_heightForLabelDateDay < 0)
		_heightForLabelDateDay = [@"W" vlSizeWithFont:[self fontForLabelDateDay]].height;
	return _heightForLabelDateDay;
}

- (float)heightForLabelDateWeekday {
	if(_heightForLabelDateWeekday < 0)
		_heightForLabelDateWeekday = [@"W" vlSizeWithFont:[self fontForLabelDateWeekday]].height;
	return _heightForLabelDateWeekday;
}

- (UIColor *)dateDayTextColorStarred {
	if(!_dateDayTextColorStarred)
		_dateDayTextColorStarred = [kYTNoteDateDayTextColorStarred retain];
	return _dateDayTextColorStarred;
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[super dealloc];
}

@end




@interface YTNoteTableCellView_ThumbFrame : YTBaseView {
@private
}
@end

@implementation YTNoteTableCellView_ThumbFrame

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float lineW = 1.0;
	float corner = 1.33;
	static UIColor *_lineColor;
	if(!_lineColor)
		_lineColor = [[UIColor colorWithRed:95/255.0 green:93/255.0 blue:77/255.0 alpha:0.98] retain];
	[_lineColor setStroke];
	CGContextSetLineWidth(ctx, lineW);
	CGRect rc = rcBnds;//CGRectInset(rcBnds, lineW/2, lineW/2);
	CGContextMoveToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x, CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, rc.origin.x, rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextStrokePath(ctx);
}

- (float)padding {
	return 0;
}

/*- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float lineW = 2;
	float corner = 1.5;
	static UIColor *_lineColor;
	if(!_lineColor)
		_lineColor = [[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.9] retain];
	[_lineColor setStroke];
	CGContextSetLineWidth(ctx, lineW);
	CGRect rc = CGRectInset(rcBnds, lineW/2, lineW/2);
	CGContextMoveToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x, CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, rc.origin.x, rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextStrokePath(ctx);
	static UIColor *_lineColor2;
	if(!_lineColor2)
		_lineColor2 = [[UIColor colorWithRed:95/255.0 green:93/255.0 blue:77/255.0 alpha:0.8] retain];
	float lineW2 = 1;
	[_lineColor2 setStroke];
	CGContextSetLineWidth(ctx, lineW2);
	CGRect rc2 = CGRectInset(rcBnds, lineW - lineW2/2, lineW - lineW2/2);
	CGContextStrokeRect(ctx, rc2);
}

- (float)padding {
	return 1;
}*/

@end




@implementation YTNoteTableCellView_Separator

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[kSeparatorColorTop setFill];
	CGContextFillRect(ctx, CGRectMake(rcBnds.origin.x, rcBnds.origin.y, rcBnds.size.width, 1));
	[kSeparatorColorBottom setFill];
	CGContextFillRect(ctx, CGRectMake(rcBnds.origin.x, rcBnds.origin.y + 1, rcBnds.size.width, 1));
}

- (float)optimalHeight {
	return kBottomSeparatorHeight;
}

@end



@implementation YTNoteTableCellView

@synthesize cellInfo = _cellInfo;
@synthesize textView = _textView;
@synthesize thumbnailView = _thumbnailView;
@synthesize resourceImage = _resourceImage;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame showDate:(BOOL)showDate showThumbnail:(BOOL)showThumbnail
		showAttachmentIcon:(BOOL)showAttachmentIcon {
	
	self = [super initWithFrame:frame];
	if(self) {
		_showDate = showDate;
		_showThumbnail = showThumbnail;
		_showAttachmentIcon = showAttachmentIcon;
		//_resourceImage = [resourceImage retain];
		
		_textView = [[YTNoteCellTextView alloc] initWithFrame:CGRectZero];
		[self addSubview:_textView];
		
		if(_showThumbnail) {
			_thumbnailView = [[YTResourceImageView alloc] initWithFrame:CGRectZero];
			_thumbnailView.drawOnMainThread = kDrawThumbOnMainThread;
			_thumbnailView.useMiniImage = NO;
			_thumbnailView.makeThumbnails = YES;
			_thumbnailView.makePreview = NO;
			_thumbnailView.backgroundColor = [UIColor clearColor];
			_thumbnailView.activityBackColor = kYTNoteImageLoadingBackColor;
			_thumbnailView.showActivityIndicator = kYTShowNoteThumbnailActivityIndicator;
			[self addSubview:_thumbnailView];
			_thumbFrame = [[YTNoteTableCellView_ThumbFrame alloc] initWithFrame:CGRectZero];
			[self addSubview:_thumbFrame];
		}
		
		if(_showDate) {
			_lbDateDay = [[VLLabel alloc] initWithFrame:CGRectZero];
			_lbDateWeekday = [[VLLabel alloc] initWithFrame:CGRectZero];
			NSArray *labels = [NSArray arrayWithObjects:_lbDateDay, _lbDateWeekday, nil];
			UIColor *textColor = _showThumbnail ? kDateColorWithImage : kDateColorNoImage;
			//UIColor *shadowColor = [UIColor whiteColor];
			for(VLLabel *label in labels) {
				label.adjustsFontSizeToFitWidth = YES;
				label.backgroundColor = [UIColor clearColor];
				label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
				label.textAlignment = NSTextAlignmentRight;
				label.textColor = textColor;
				//label.shadowColor = shadowColor;
				//label.shadowOffset = CGSizeMake(1, 1);
				[self addSubview:label];
			}
		}
		
		_separator = [[YTNoteTableCellView_Separator alloc] initWithFrame:CGRectZero];
		[self addSubview:_separator];
		
		[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
		[self updateFonts:self];
		
		[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	}
	return self;
}

- (void)updateFonts:(id)sender {
	if(_textView)
		[_textView setFontCapital:[[YTNoteTableCellViewManager shared] fontForTextCapital] fontContext:[[YTNoteTableCellViewManager shared] fontForTextContent]];
	if(_lbDateDay)
		_lbDateDay.font = [[YTNoteTableCellViewManager shared] fontForLabelDateDay];
	if(_lbDateWeekday)
		_lbDateWeekday.font = [[YTNoteTableCellViewManager shared] fontForLabelDateWeekday];
	[self setNeedsLayout];
}

- (YTNotesTableView *)getParentNotesTableView {
	return (YTNotesTableView *)[VLCtrlsUtils getParentViewOfClass:[YTNotesTableView class] ofView:self];
}

+ (float)contentHeight {
	float lineCapitalHeight = [[YTNoteTableCellViewManager shared] heightForTextCapitalLine];
	float lineContentHeight = [[YTNoteTableCellViewManager shared] heightForTextContentLine];
	float linesHeight = lineCapitalHeight + lineContentHeight * (kMaxTextLinesCount - 1);
	float thumbHeight = kThumbnailSize.height;
	float result = kInsetTop + MAX(linesHeight, thumbHeight) + kInsetBottom;
	return result;
}

+ (float)optimalHeight {
	return [self contentHeight] + kBottomSeparatorHeight;
}

- (void)prepareForAddToTable {
	if(_thumbnailView) {
		_thumbnailView.resource = nil;
	}
	if(_cellInfo) {
		[_cellInfo.msgrVersionChanged removeObserver:self];
		[_cellInfo release];
		_cellInfo = nil;
	}
	if(_thumbFrame)
		[self showThumbnailFrame:YES animated:NO];
}

- (void)applyCellInfo:(YTNoteTableCellInfo *)cellInfo {
	if(_cellInfo != cellInfo) {
		if(_cellInfo) {
			[_cellInfo.msgrVersionChanged removeObserver:self];
			[_cellInfo release];
		}
		_cellInfo = [cellInfo retain];
		[_cellInfo.msgrVersionChanged addObserver:self selector:@selector(onCellInfoDataChanged:)];
	}
	if(_resourceImage) {
		[_resourceImage release];
		_resourceImage = nil;
	}
	if(cellInfo.resourceImage)
		_resourceImage = [cellInfo.resourceImage retain];
	[_textView setText:cellInfo.title];
	if(_showThumbnail != cellInfo.showThumbnail) {
		_showThumbnail = cellInfo.showThumbnail;
		[self setNeedsLayout];
	}
	if(cellInfo.showThumbnail) {
		[_thumbnailView setResource:cellInfo.resourceImage];
	}
	if(_showDate != cellInfo.showDateLabels) {
		_showDate = cellInfo.showDateLabels;
		[self setNeedsLayout];
	}
	if(cellInfo.showDateLabels) {
		if(![_lbDateDay.text isEqual:cellInfo.strDay]) {
			_lbDateDay.text = cellInfo.strDay;
			[self setNeedsLayout];
		}
		_lbDateWeekday.text = cellInfo.strWeekday;
		if(cellInfo.note.priorityId != EYTPriorityTypeNone) { // Starred
			_lbDateDay.textColor = [[YTNoteTableCellViewManager shared] dateDayTextColorStarred];
		} else {
			_lbDateDay.textColor = _showThumbnail ? kDateColorWithImage : kDateColorNoImage;
		}
	}
	if(_showAttachmentIcon != cellInfo.showAttachmentIcon) {
		_showAttachmentIcon = cellInfo.showAttachmentIcon;
		[self setNeedsLayout];
	}
}

- (void)onCellInfoDataChanged:(id)sender {
	if(_cellInfo) {
		[self applyCellInfo:_cellInfo];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcContFixed = rcBnds;
	rcContFixed.size.height -= kBottomSeparatorHeight;
	CGRect rcCont = rcContFixed;
	//float offsetX = 0;
	float spaceX = 4.0;
	//rcCont.origin.x += offsetX;
	CGRect rcContFree = rcCont;
	rcContFree.origin.x += kInsetLeft;
	rcContFree.size.width -= kInsetLeft + kInsetRight;
	rcContFree.origin.y += kInsetTop;
	rcContFree.size.height -= kInsetTop + kInsetBottom;
	
	CGRect rcDay = CGRectZero;
	if(_showThumbnail || _showDate) {
		float datesDX = 0;
		float thumbsDX = 0;
		CGRect rcRightBox = rcContFree;
		rcRightBox.size = kThumbnailSize;
		rcRightBox.origin.x = CGRectGetMaxX(rcContFree) - rcRightBox.size.width;
		rcRightBox.origin.y = CGRectGetMidY(rcContFree) - rcRightBox.size.height/2;
		if(_showThumbnail) {
			CGRect rcThumb = rcRightBox;
			rcThumb.size = kThumbnailSize;
			_thumbnailView.frame = [UIScreen roundRect:rcThumb];
			_thumbFrame.frame = CGRectInset(_thumbnailView.frame, -[_thumbFrame padding], -[_thumbFrame padding]);
			thumbsDX = rcThumb.size.width;
		}
		if(_showDate) {
			float heightForLabelDateDay = [[YTNoteTableCellViewManager shared] heightForLabelDateDay];
			float heightForLabelDateWeekday = [[YTNoteTableCellViewManager shared] heightForLabelDateWeekday];
			CGRect rcDateAll = rcRightBox;
			rcDateAll.origin.x += 1;
			rcDateAll.size.width -= 2;
			CGRect rcWeekday = rcDateAll;
			rcWeekday.size.height = heightForLabelDateWeekday;
			rcWeekday.origin.y = CGRectGetMaxY(rcDateAll) - rcWeekday.size.height - rcDateAll.size.height * 0.04;
			rcDay = rcDateAll;
			rcDay.size.height = heightForLabelDateDay;
			rcDay.origin.y = rcWeekday.origin.y - rcDay.size.height;
			rcDay.origin.y += heightForLabelDateDay * 0.11;
			
			float freeH = (rcDateAll.size.height - rcDay.size.height - rcWeekday.size.height) / 3;
			float dy = freeH - (rcDay.origin.y - rcDateAll.origin.y);
			rcDay.origin.y += dy;
			rcWeekday.origin.y += dy;
			
			_lbDateWeekday.frame = [UIScreen roundRect:rcWeekday];
			_lbDateDay.frame = [UIScreen roundRect:rcDay];
			
			datesDX = rcDateAll.size.width;
		}
		float maxDX = MAX(datesDX, thumbsDX);
		if(maxDX)
			maxDX += spaceX;
		rcContFree.size.width -= maxDX;
	}

	if(_showAttachmentIcon && !_showThumbnail && _showDate) {
		if(!_iconAttachment) {
			_iconAttachment = [[UIImageView alloc] initWithFrame:CGRectZero];
			_iconAttachment.backgroundColor = [UIColor clearColor];
			_iconAttachment.contentMode = UIViewContentModeCenter;
			_iconAttachment.image = [UIImage imageNamed:@"res_attachment.png"];
			[self addSubview:_iconAttachment];
		}
		CGRect rcIcon = rcDay;
		rcIcon.size.width = _iconAttachment.image.size.width;
		rcIcon.origin.x = CGRectGetMaxX(rcDay) - [_lbDateDay.text vlSizeWithFont:_lbDateDay.font].width - 2 - rcIcon.size.width;
		_iconAttachment.frame = [UIScreen roundRect:rcIcon];
	} else {
		if(_iconAttachment)
			_iconAttachment.hidden = YES;
	}
	
	rcContFree.origin.x += spaceX;
	rcContFree.size.width -= spaceX;
	
	CGRect rcText = rcContFree;
	if(_textView.superview == self)
		_textView.frame = rcText;
	
	CGRect rcSep = rcBnds;
	rcSep.size.height = kBottomSeparatorHeight;
	rcSep.origin.y = CGRectGetMaxY(rcContFixed);// - rcSep.size.height;
	if(_separator)
		_separator.frame = rcSep;
}

- (void)onSelectedChanged:(BOOL)selected {
	if(selected)
		self.backgroundColor = kYTNoteCellBackColorSel;
	else
		self.backgroundColor = [UIColor clearColor];
}

- (BOOL)canBeSelected {
	return YES;
}

- (void)showThumbnailFrame:(BOOL)show animated:(BOOL)animated {
	if(_thumbFrame) {
		if(animated) {
			double delay = 0;
			double duration = kDefaultAnimationDuration/8;
			if(show) {
				delay = kDefaultAnimationDuration - duration;
			}
			_thumbFrame.alpha = show ? 0.0 : 1.0;
			[UIView animateWithDuration:duration
								  delay:delay
								options:0
			animations:^{
				_thumbFrame.alpha = show ? 1.0 : 0.0;
			}
			completion:^(BOOL finished) {
				if(finished) {
				}
			}];
		} else {
			_thumbFrame.hidden = !show;
			_thumbFrame.alpha = 1.0;
		}
	}
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	if(_cellInfo) {
		[_cellInfo.msgrVersionChanged removeObserver:self];
		[_cellInfo release];
	}
	[_thumbnailView release];
	[_thumbFrame release];
	[_resourceImage release];
	[_textView release];
	[_lbDateDay release];
	[_lbDateWeekday release];
	[_iconAttachment release];
	[_separator release];
	[super dealloc];
}

@end




@implementation YTNotesTableViewCell

- (void)internalSetSelected:(BOOL)selected {
	if(_lastSelected != selected) {
		_lastSelected = selected;
		YTNoteTableCellView *view = ObjectCast(self.subView, YTNoteTableCellView);
		if(view)
			[view onSelectedChanged:selected];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	YTNoteTableCellView *noteView = ObjectCast(self.subView, YTNoteTableCellView);
	if(noteView && ![noteView canBeSelected])
		return;
	[self internalSetSelected:selected];
	[super setSelected:selected animated:animated];
}

- (void)setSelected:(BOOL)selected {
	[self internalSetSelected:selected];
	[super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[self internalSetSelected:highlighted];
	[super setHighlighted:highlighted animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted {
	[self internalSetSelected:highlighted];
	[super setHighlighted:highlighted];
}

@end






