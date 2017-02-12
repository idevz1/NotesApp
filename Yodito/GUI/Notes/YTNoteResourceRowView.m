
#import "YTNoteResourceRowView.h"
#import "YTNoteResourcesListView.h"

#define kDefaultHeight 30.0
#define kEdgeInsets UIEdgeInsetsMake(2, 8, 2, 8)


@implementation YTNoteResourceRowView

@synthesize resourceView = _resourceView;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_lbTitle.textColor = kYTLabelsBlueTextColor;
	_lbTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;
	[self addSubview:_lbTitle];
	_lbTitle.font = [[YTFontsManager shared] fontWithSize:10 fixed:YES];
	
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
	[self addGestureRecognizer:tap];
	
	[self updateViewAsync];
}

- (void)setResource:(YTResourceInfo *)resource {
	[super setResource:resource];
}

- (BOOL)isImageAndLoaded {
	YTResourceInfo *res = self.resource;
	if(!res || !res.isImage)
		return NO;
	BOOL isLoaded = [[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash];
	return isLoaded;
}

- (CGSize)sizeOfLoadedImage {
	YTResourceInfo *res = self.resource;
	if(!res)
		return CGSizeZero;
	return [[YTResourcesStorage shared] sizeOfLoadedImage:res];
}

- (BOOL)isImageLoaded {
	YTResourceInfo *res = self.resource;
	if(!res || ![res isImage])
		return NO;
	BOOL bResult = [[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash];
	return bResult;
}

- (BOOL)isImageShown {
	return _resourceView && [_resourceView isImageShown];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceInfo *res = self.resource;
	if(!res)
		return;
	YTResourceInfo *resImage = nil;
	if([res isImage]) {
		resImage = res;//[[YTResourcesManager shared] thumbnailForImage:res];
	}
	if(resImage) {
		_lbTitle.visible = NO;
		if(!_resourceView) {
			_resourceView = [[YTResourceView alloc] init];
			_resourceView.makePreview = YES;
			_resourceView.makeThumbnails = NO;
			_resourceView.aspectFill = YES;
			_resourceView.backgroundColor = [UIColor clearColor];
			_resourceView.activityBackColor = kYTNoteImageLoadingBackColor;
			[self addSubview:_resourceView];
			[self setNeedsLayout];
		}
		_resourceView.resource = resImage;
	} else {
		NSString *sTitle = [NSString stringWithFormat:@"%@", res.filename];
		_lbTitle.text = sTitle;
		_lbTitle.visible = YES;
	}
	[self setNeedsLayout];
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

- (UIEdgeInsets)getEdgeInsets {
	if(self.resource && [self.resource isImage])
		return UIEdgeInsetsZero;
	return kEdgeInsets;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = kDefaultHeight;
	YTResourceInfo *res = self.resource;
	if(!res)
		return size;
	if(res.isImage) {
		UIEdgeInsets edgeInsets = [self getEdgeInsets];
		CGSize szImage = [[YTResourcesStorage shared] sizeOfLoadedImage:res];
		if(szImage.width > 0) {
			float widthForImage = size.width;
			if(widthForImage > szImage.width)
				widthForImage = szImage.width;
			size.height = widthForImage * szImage.height / szImage.width;
		}
		size.height = edgeInsets.top + ceil(size.height) + edgeInsets.bottom;
	}
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;

	UIEdgeInsets edgeInsets = [self getEdgeInsets];
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, edgeInsets);
	
	CGRect rcTitle = rcCtrls;
	_lbTitle.frame = rcTitle;
	
	if(_resourceView && _resourceView.superview == self) {
		_resourceView.frame = rcCtrls;
	}
}

- (void)onBtnArrowTap:(id)sender {
	
}

- (void)onTap:(id)sender {
	YTNoteResourcesListView *view = (YTNoteResourcesListView *)[VLCtrlsUtils getParentViewOfClass:[YTNoteResourcesListView class] ofView:self];
	if(view)
		[view onRowTapped:self];
}

- (void)dealloc {
	[_lbTitle release];
	[_resourceView release];
	[super dealloc];
}

@end

