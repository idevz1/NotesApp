
#import "YTResourceImageView.h"

#define kUseTiledView NO//YES
#define kUseTiledImagePreviewView YES//NO

@implementation YTResourceImageView

@synthesize drawOnMainThread = _drawOnMainThread;
@synthesize useMiniImage = _useMiniImage;
@synthesize delegate = _delegate;
@synthesize imageHolderView = _imageScrollView;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor blackColor];
	_lastImageKey = [@"" retain];
	_loadingAttachmentHash = [@"" retain];
	self.clipsToBounds = YES;

	[self updateViewAsync];
}

- (void)setImageFilePath:(NSString *)imageFilePath
			   imageSize:(CGSize)imageSize
		   miniImagePath:(NSString *)miniImagePath {
	
	UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
	if(self.makeThumbnails || self.aspectFill)
		contentMode = UIViewContentModeScaleAspectFill;
	if([NSString isEmpty:imageFilePath]) {
		/*if(_imageScrollView) {
			[_imageScrollView removeFromSuperview];
			[_imageScrollView release];
			_imageScrollView = nil;
		}*/
		if(_imageShowView) {
			[_imageShowView removeFromSuperview];
			[_imageShowView release];
			_imageShowView = nil;
		}
	} else {
		if(kUseTiledImagePreviewView) {
			if(!_imageShowView) {
				_imageShowView = [[YTImagePreviewView alloc] initImageFilePath:imageFilePath
																	   imageSize:imageSize
																imageContentMode:contentMode
																	   drawAsync:!_drawOnMainThread
																   miniImagePath:miniImagePath];
				_imageShowView.delegate = self;
				[self addSubview:_imageShowView];
				[self layoutSubviews];
			}
		}/* else if(kUseTiledView) {
			if(!_imageScrollView) {
				_imageScrollView = [[YTTilingImageScrollView alloc] initImageFilePath:imageFilePath
																		imageSize:imageSize
																 imageContentMode:contentMode
																	miniImagePath:miniImagePath
																 drawOnMainThread:_drawOnMainThread];
				_imageScrollView.userInteractionEnabled = NO;
				[self addSubview:_imageScrollView];
				[self layoutSubviews];
			}
		} else {
			_imageShowView = [[YTImageShowView alloc] initImageFilePath:imageFilePath
															  imageSize:imageSize
													   imageContentMode:contentMode
														   useMiniImage:_useMiniImage
														  miniImagePath:miniImagePath];
			[self addSubview:_imageShowView];
			[self layoutSubviews];
		}*/
	}
}

- (void)setResource:(YTResourceInfo *)resource {
	if(resource != self.resource) {
		[self setImageFilePath:nil imageSize:CGSizeZero miniImagePath:nil];
		if(self.loadingReference)
			[self.loadingReference setResourceHash:@"" andType:@"" categoryId:0];
		[self setIsProcessing:NO];
		[super setResource:resource];
	}
}

- (BOOL)imagePreviewView:(YTImagePreviewView *)imagePreviewView isVisible:(id)param {
	if(!self.superview)
		return NO;
	BOOL result = NO;
	if(_delegate && [_delegate respondsToSelector:@selector(resourceImageView:isVisible:)])
		result = [_delegate resourceImageView:self isVisible:nil];
	return result;
}

- (BOOL)isImageShown {
	//return (_imageScrollView && [_imageScrollView isImageShown]) || (_imageShowView && [_imageShowView isImageShown]);
	return (_imageShowView && [_imageShowView isImageShown]);
}

- (CGSize)sizeOfLoadedImage {
	//if(_imageScrollView)
	//	return _imageScrollView.imageSize;
	if(_imageShowView)
		return _imageShowView.imageSize;
	return CGSizeZero;
}

- (NSString *)imageKey {
	YTResourceInfo *resource = self.resource;
	if(!resource)
		return @"";
	NSString *imageKey = [NSString stringWithFormat:@"%@_%d_%d", resource.attachmenthash,
						  (int)self.makeThumbnails, (int)self.makePreview];
	return imageKey;
}

- (void)setIsProcessing:(BOOL)processing {
	if(!self.showActivityIndicator || !self.activityView)
		return;
	if(processing != self.activityView.visible) {
		if(processing) {
			self.activityView.visible = YES;
			[self.activityView startAnimating];
			[self bringSubviewToFront:self.activityView];
		} else {
			[self.activityView stopAnimating];
			self.activityView.visible = NO;
		}
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceInfo *resource = self.resource;
	if(resource) {
		NSString *imageKey = [self imageKey];
		if(![_lastImageKey isEqual:imageKey]) {
			[_lastImageKey release];
			_lastImageKey = [@"" retain];
			[self setImageFilePath:nil imageSize:CGSizeZero miniImagePath:nil];
		}
		
		if(_imageShowView && [_imageShowView isImageShown]) {
			[self setIsProcessing:NO];
			return;
		}
		
		[self.loadingReference setResourceHash:resource.attachmenthash andType:resource.attachmentTypeName categoryId:(int)resource.attachmentCategoryId];
		YTResourceLoadingInfo *loadingInfo = self.loadingReference.parentInfoRef;
		
		BOOL processing = loadingInfo.processing;
		if(loadingInfo.processing && !resource.isThumbnail) {
			[_loadingAttachmentHash release];
			_loadingAttachmentHash = [resource.attachmenthash copy];
		}
		BOOL skip = NO;
		if((_imageShowView && [_imageShowView isImageShown])
		   && [_lastImageKey isEqual:imageKey])
			skip = YES;
		if(!skip) {
			[_lastImageKey release];
			_lastImageKey = [imageKey copy];
			[self setImageFilePath:nil imageSize:CGSizeZero miniImagePath:nil];
			if(processing) {
				
			} else {
				NSString *imageFilePath = @"";
				CGSize imageSize = CGSizeZero;
				if(self.makePreview) {
					imageFilePath = [[YTPhotoPreviewMaker shared] getPreviewFilePath:resource.attachmenthash imageSize:&imageSize];
				} else {
					imageFilePath = [[YTPhotoPreviewMaker shared] getThumbnailFilePath:resource.attachmenthash imageSize:&imageSize];
				}
				NSString *miniImageFilePath = [[YTPhotoPreviewMaker shared] getMiniPreviewFilePath:resource.attachmenthash imageSize:nil];
				[self setImageFilePath:imageFilePath imageSize:imageSize miniImagePath:miniImageFilePath];
			}
		}
		if(_imageShowView && [_imageShowView isImageShown])
			processing = NO;
		[self setIsProcessing:processing];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	/*if(_imageScrollView && _imageScrollView.superview == self) {
		if(!CGRectEqualToRect(_imageScrollView.frame, rcBnds))
			_imageScrollView.frame = rcBnds;
	}*/
	if(_imageShowView && _imageShowView.superview == self) {
		if(!CGRectEqualToRect(_imageShowView.frame, rcBnds))
			_imageShowView.frame = rcBnds;
	}
}

- (void)dealloc {
	//[_imageScrollView release];
	//_imageScrollView = nil;
	[_imageShowView release];
	_imageShowView = nil;
	[_lastImageKey release];
	[_loadingAttachmentHash release];
	[super dealloc];
}

@end

