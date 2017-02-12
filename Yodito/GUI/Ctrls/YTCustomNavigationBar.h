
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTCustomNavigationBar_TapBlockView;


@interface YTCustomNavigationBar : YTBaseView {
@private
	UIView *_contentViewCNB;
	UIImageView *_ivBotShadow;
	VLLabel *_titleLabel;
	UIImageView *_imageViewTitle;
	UIButton *_btnBack;
	UIButton *_btnLeft;
	UIButton *_btnRight;
	YTCustomNavigationBar_TapBlockView *_tapBlockView;
	float _bottomTapBlockAreaRatio;
}

@property(nonatomic, readonly) UIView *contentView;
@property(nonatomic, readonly) VLLabel *titleLabel;
@property(nonatomic, readonly) UIButton *btnBack;
@property(nonatomic, readonly) UIButton *btnLeft;
@property(nonatomic, readonly) UIButton *btnRight;
@property(nonatomic, assign) float bottomTapBlockAreaRatio;

- (void)setTitleImage:(UIImage *)image;

@end

