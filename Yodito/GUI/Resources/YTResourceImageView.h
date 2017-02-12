
#import <Foundation/Foundation.h>
#import "YTResourceBaseView.h"
#import "YTImagePreviewView.h"

@class YTResourceImageView;

@protocol YTResourceImageViewDelegate <NSObject>
@optional
- (void)resourceImageView:(YTResourceImageView *)resourceImageView imageChanged:(UIImage *)image;
- (BOOL)resourceImageView:(YTResourceImageView *)resourceImageView isVisible:(id)param;

@end


@interface YTResourceImageView : YTResourceBaseView <YTImagePreviewViewDeleate> {
@private
	BOOL _drawOnMainThread;
	BOOL _useMiniImage;
	YTImagePreviewView *_imageShowView;
	NSString *_lastImageKey;
	NSString *_loadingAttachmentHash;
	NSObject<YTResourceImageViewDelegate> *_delegate;
}

@property(nonatomic, assign) BOOL drawOnMainThread;
@property(nonatomic, assign) BOOL useMiniImage;
@property(nonatomic, assign) NSObject<YTResourceImageViewDelegate> *delegate;
@property(nonatomic, readonly) UIView *imageHolderView;

- (BOOL)isImageShown;
- (CGSize)sizeOfLoadedImage;

@end
