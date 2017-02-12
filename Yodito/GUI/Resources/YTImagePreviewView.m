
#import "YTImagePreviewView.h"
#import "../YTUiMediator.h"

#define kFadeDuration 0.25

@implementation YTImagePreviewView

@synthesize delegate = _delegate;

- (id)initImageFilePath:(NSString *)imageFilePath
			  imageSize:(CGSize)imageSize
	   imageContentMode:(UIViewContentMode)imageContentMode
			  drawAsync:(BOOL)drawAsync
		  miniImagePath:(NSString *)miniImagePath {
	self = [super initWithFrame:CGRectZero];
	if(self) {
		_imageFilePath = [imageFilePath copy];
		_imageSize = imageSize;
		_imageContentMode = imageContentMode;
		_drawAsync = drawAsync;
		
		if(_drawAsync) {
			_tiledView = [[YTImagePreviewView_TiledView alloc] initImageFilePath:_imageFilePath imageSize:_imageSize];
			_tiledView.delegate = self;
			[self addSubview:_tiledView];
		} else {
			_useMiniImage = ![NSString isEmpty:miniImagePath];
			if(_useMiniImage) {
				UIImage *imageMini = [UIImage imageWithContentsOfFile:miniImagePath];
				if(imageMini) {
					_imageViewMini = [[UIImageView alloc] initWithFrame:self.bounds];
					_imageViewMini.contentMode = _imageContentMode;
					_imageViewMini.image = imageMini;
					[self insertSubview:_imageViewMini atIndex:0];
				}
			}

			[self createImageView];
			_imageView.alpha = 0.0;
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
				UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
				if(image) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if(!self.superview)
							return;
						_imageView.image = image;
						[UIView animateWithDuration:0.25 animations:^{
							_imageView.alpha = 1.0;
						}];
					});
				}
				[arpool drain];
			});
		}
		
		[[YTUiMediator shared].msgrScrollingEnded addObserver:self selector:@selector(onScrollingEnded:)];
	}
	return self;
}

- (void)initialize {
	[super initialize];
	self.clipsToBounds = YES;
	self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(_tiledView && _imageSize.width > 0 && _imageSize.height > 0) {
		UIViewContentMode contentMode = _imageContentMode;
		CGRect rcTile = _tiledView.bounds;
		float ratioBnds = rcBnds.size.width / rcBnds.size.height;
		float ratioTile = rcTile.size.width / rcTile.size.height;
		CGRect rcNeed = rcBnds;
		if(contentMode == UIViewContentModeScaleAspectFit) {
			if(ratioTile >= ratioBnds) {
				rcNeed.size.height = rcNeed.size.width / ratioTile;
			} else {
				rcNeed.size.width = rcNeed.size.height * ratioTile;
			}
		} else if(contentMode == UIViewContentModeScaleAspectFill) {
			if(ratioTile >= ratioBnds) {
				rcNeed.size.width = rcNeed.size.height * ratioTile;
			} else {
				rcNeed.size.height = rcNeed.size.width / ratioTile;
			}
		}
		rcNeed.origin.x = CGRectGetMidX(rcBnds) - rcNeed.size.width/2;
		rcNeed.origin.y = CGRectGetMidY(rcBnds) - rcNeed.size.height/2;
		float zoomScale = rcNeed.size.width / rcTile.size.width;
		CGAffineTransform transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
		float dx = -(rcTile.size.width/2 - rcBnds.size.width/2)/zoomScale;
		float dy = -(rcTile.size.height/2 - rcBnds.size.height/2)/zoomScale;
		transform = CGAffineTransformTranslate(transform, dx, dy);
		_tiledView.transform = transform;
	}
	if(_imageView)
		_imageView.frame = rcBnds;
	if(_imageViewMini)
		_imageViewMini.frame = rcBnds;
}

- (void)tiledView:(YTImagePreviewView_TiledView *)tiledView imageDrawn:(UIImage *)image {
	_imageDrawn = YES;
	if([[YTUiMediator shared] isScrolling])
		return;
	[self setImage:image];
}

- (void)createImageView {
	if(!_imageView) {
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.backgroundColor = [UIColor clearColor];
		_imageView.contentMode = _imageContentMode;
		//_imageView.layer.drawsAsynchronously = YES;
		[self addSubview:_imageView];
	}
}

- (void)setImage:(UIImage *)image {
	_imageDrawn = YES;
	if(_tiledView) {
		_tiledView.delegate = nil;
		[self createImageView];
		//VLLoggerTrace(@"");
		_imageView.image = image;
		[_tiledView removeFromSuperview];
		[_tiledView release];
		_tiledView = nil;
		if(_imageViewMini) {
			[_imageViewMini removeFromSuperview];
			[_imageViewMini release];
			_imageViewMini = nil;
		}
	}
}

- (void)onScrollingEnded:(id)sender {
	if(_imageView)
		return;
	if(!_imageDrawn) {
		_imageDrawn = YES;
		/*static dispatch_queue_t _queue;
		if(!_queue) {
			_queue = dispatch_queue_create("YTImagePreviewView", NULL);
		}
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		//dispatch_async(_queue, ^{
			VLLoggerTrace(@"1");
			[NSThread sleepForTimeInterval:1.0];
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
			if(image) {
				//dispatch_async(dispatch_get_main_queue(), ^{
				dispatch_sync(dispatch_get_main_queue(), ^{
					[self setImage:image];
				});
			}
			[arpool drain];
			VLLoggerTrace(@"2");
		});*/
		
		static NSOperationQueue *_operQueue;
		if(!_operQueue) {
			_operQueue = [[NSOperationQueue alloc] init];
			_operQueue.maxConcurrentOperationCount = 1;
		}
		//NSOperation *oper = [[NSOperation alloc] init];
		NSInvocationOperation *oper = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageAsync) object:nil];
		[oper setThreadPriority:0.25];
		BOOL isVisible = NO;
		if(_delegate && [_delegate respondsToSelector:@selector(imagePreviewView:isVisible:)])
			isVisible = [_delegate imagePreviewView:self isVisible:nil];
		if(isVisible)
			[oper setQueuePriority:NSOperationQueuePriorityHigh];
		else
			[oper setQueuePriority:NSOperationQueuePriorityNormal];
		[_operQueue addOperation:oper];
		[oper release];
	}
}

- (void)loadImageAsync {
	if(!self.superview)
		return;
	//VLLoggerTrace(@"1");
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
	if(image) {
		[self performSelectorOnMainThread:@selector(setImageFromAsync:) withObject:image waitUntilDone:YES];
	}
	[arpool drain];
	//VLLoggerTrace(@"2");
}

- (void)setImageFromAsync:(UIImage *)image {
	if(!self.superview)
		return;
	//[NSThread sleepForTimeInterval:0.5];
	[self setImage:image];
}

- (CGSize)imageSize {
	return _imageSize;
}

- (BOOL)isImageShown {
	return YES;
}

- (void)dealloc {
	_delegate = nil;
	[[YTUiMediator shared].msgrScrollingEnded removeObserver:self];
	if(_tiledView) {
		_tiledView.delegate = nil;
		[_tiledView release];
	}
	[_imageViewMini release];
	[_imageView release];
	[_imageFilePath release];
	[super dealloc];
}

@end



@interface YTImagePreviewView_TiledView_Layer : CATiledLayer {
@private
}

@end

@implementation YTImagePreviewView_TiledView_Layer

+ (CFTimeInterval)fadeDuration {
	return kFadeDuration;
}

@end


@implementation YTImagePreviewView_TiledView

@synthesize delegate = _delegate;

+ (Class)layerClass {
	return [YTImagePreviewView_TiledView_Layer class];
}

- (id)initImageFilePath:(NSString *)imageFilePath
			  imageSize:(CGSize)imageSize {
	float maxScreenScale = 2.0;
	self = [super initWithFrame:CGRectMake(0, 0, imageSize.width/maxScreenScale, imageSize.height/maxScreenScale)];
	if(self) {
		_imageFilePath = [imageFilePath copy];
		_imageSize = imageSize;
		CALayer *layer = [self layer];
		YTImagePreviewView_TiledView_Layer *tiledLayer = (YTImagePreviewView_TiledView_Layer *)layer;
		tiledLayer.levelsOfDetail = 1;
		tiledLayer.tileSize = _imageSize;
	}
	return self;
}

// to handle the interaction between CATiledLayer and high resolution screens, we need to
// always keep the tiling view's contentScaleFactor at 1.0. UIKit will try to set it back
// to 2.0 on retina displays, which is the right call in most cases, but since we're backed
// by a CATiledLayer it will actually cause us to load the wrong sized tiles.
//
// We don't need it. We have only 1 tile.
- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
	[super setContentScaleFactor:1.0];
}

- (void)drawRect:(CGRect)rect {
	if(![NSString isEmpty:_imageFilePath]) {
		UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
		if(image) {
			CGSize imageSize = image.size;
			CGRect rcBnds = self.bounds;
			CGRect rcImage = rcBnds;
			float imageRatio = imageSize.width / imageSize.height;
			float boundsRatio = rcBnds.size.width / rcBnds.size.height;
			if(imageRatio != boundsRatio) {
				UIViewContentMode contentMode = self.contentMode;
				if(contentMode == UIViewContentModeScaleAspectFit) {
					if(imageRatio >= boundsRatio) {
						rcImage.size.height = rcImage.size.width / imageRatio;
					} else {
						rcImage.size.width = rcImage.size.height * imageRatio;
					}
				} else if(contentMode == UIViewContentModeScaleAspectFill) {
					if(imageRatio >= boundsRatio) {
						rcImage.size.width = rcImage.size.height * imageRatio;
					} else {
						rcImage.size.height = rcImage.size.width / imageRatio;
					}
				}
			}
			rcImage.origin.x = CGRectGetMidX(rcBnds) - rcImage.size.width/2;
			rcImage.origin.y = CGRectGetMidY(rcBnds) - rcImage.size.height/2;
			rcImage = [UIScreen roundRect:rcImage];
			[image drawInRect:rcImage];
			if(_delegate && [_delegate respondsToSelector:@selector(tiledView:imageDrawn:)] && ![[YTUiMediator shared] isScrolling]) {
				//dispatch_async(dispatch_get_main_queue(), ^{
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kFadeDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
					if(_delegate && [_delegate respondsToSelector:@selector(tiledView:imageDrawn:)]) {
						[_delegate tiledView:self imageDrawn:image];
					}
				});
			}
		}
	}
}

- (void)dealloc {
	[_imageFilePath release];
	[super dealloc];
}

@end

