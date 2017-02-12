
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTImagePreviewView_TiledView;
@class YTImagePreviewView;

@protocol YTImagePreviewView_TiledViewDeleate <NSObject>
@optional
- (void)tiledView:(YTImagePreviewView_TiledView *)tiledView imageDrawn:(UIImage *)image;
@end


@protocol YTImagePreviewViewDeleate <NSObject>
@optional
- (BOOL)imagePreviewView:(YTImagePreviewView *)imagePreviewView isVisible:(id)param;
@end


@interface YTImagePreviewView : YTBaseView <YTImagePreviewView_TiledViewDeleate> {
@private
	CGSize _imageSize;
	UIViewContentMode _imageContentMode;
	BOOL _useMiniImage;
	NSString *_imageFilePath;
	BOOL _drawAsync;
	YTImagePreviewView_TiledView *_tiledView;
	UIImageView *_imageViewMini;
	UIImageView *_imageView;
	BOOL _imageDrawn;
	NSObject<YTImagePreviewViewDeleate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTImagePreviewViewDeleate> *delegate;

- (id)initImageFilePath:(NSString *)imageFilePath
			  imageSize:(CGSize)imageSize
	   imageContentMode:(UIViewContentMode)imageContentMode
			  drawAsync:(BOOL)drawAsync
		  miniImagePath:(NSString *)miniImagePath;
- (CGSize)imageSize;
- (BOOL)isImageShown;

@end




@interface YTImagePreviewView_TiledView : YTBaseView {
@private
	NSString *_imageFilePath;
	CGSize _imageSize;
	NSObject<YTImagePreviewView_TiledViewDeleate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTImagePreviewView_TiledViewDeleate> *delegate;

- (id)initImageFilePath:(NSString *)imageFilePath
			  imageSize:(CGSize)imageSize;

@end

