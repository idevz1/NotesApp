
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteEditView.h"
#import "YTNoteResourcesListView.h"
#import "YTNoteLocationLabelView.h"
#import "YTNoteViewDelegate.h"
#import "YTNoteDateLabelView.h"
#import "YTNoteContentSeparator.h"
#import "YTNoteEditView.h"
@class YTNoteView_SeeMorePhotosView;

@protocol YTNoteView_SeeMorePhotosViewDelegate <NSObject>
@optional
- (void)seeMorePhotosView:(YTNoteView_SeeMorePhotosView *)view tapped:(id)param;
@end

@interface YTNoteView_SeeMorePhotosView_ShadowView : YTBaseView {
@private
}

@end

@interface YTNoteView_SeeMorePhotosView : YTBaseView {
@private
	YTNoteView_SeeMorePhotosView_ShadowView *_shadowView;
	UIImageView *_iconView;
	VLLabel *_lbTitle;
	NSObject<YTNoteView_SeeMorePhotosViewDelegate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTNoteView_SeeMorePhotosViewDelegate> *delegate;

- (void)setTitle:(NSString *)title;

@end




@interface YTNoteView_ContentView : YTBaseView <UIScrollViewDelegate, YTNoteResourcesListViewDelegate,
	YTNoteView_SeeMorePhotosViewDelegate, NSLayoutManagerDelegate> {
@private
	YTNoteContentSeparator *_sepDateTop;
	YTNoteDateLabelView *_dateLabelView;
	YTNoteContentSeparator *_sepDateBot;
	YTNoteLocationLabelView *_locationLabelView;
	YTNoteContentSeparator *_sepLocBot;
	YTTagsLineView *_tagsLineView;
	UITextView *_textView;
	NSString *_lastText;
	BOOL _hasCapitalLine;
	YTNoteResourcesListView *_resourcesListViewImages;
	YTNoteView_SeeMorePhotosView *_seeMorePhotosView;
	YTNoteResourcesListView *_resourcesListViewDocs;
	YTNoteContentSeparator *_sepDocsBot;
	float _heightOfTextView;
	NSMutableArray *_resourcesReferences;
	NSMutableArray *_resourcesToShowInList;
	//NSMutableArray *_resourcesToShowInListNotDownloaded;
	BOOL _contentWasLoaded;
	BOOL _showAllPhotos;
}

@property(nonatomic, readonly) NSString *text;
@property(nonatomic, readonly) UIView *textView;
@property(nonatomic, readonly) YTNoteResourcesListView *resourcesListView;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock;
- (BOOL)isNoteLoaded;
- (BOOL)isAllImagesShown;

@end


@interface YTNoteView : YTBaseView <UIScrollViewDelegate, YTNoteEditViewDelegate> {
@private
	UIView *_backView;
	UIView *_toolbar;
	UIButton *_btnDelete;
	UIButton *_btnAdd;
	UIButton *_btnAction;
	BOOL _toolbarShown;
	NSObject<YTNoteViewDelegate> *_delegate;
	UIScrollView *_contentScrollView;
	YTNoteView_ContentView *_contentView;
	BOOL _wasShown;
	UIStatusBarStyle _statusBarStyleNeededMNV;
	UIStatusBarStyle _lastStatusBarStyleMNV;
	UIView *_statusBarBackViewMNV;
}

@property(nonatomic, assign) NSObject<YTNoteViewDelegate> *delegate;
@property(nonatomic, readonly) YTNoteView_ContentView *contentView;
@property(nonatomic, assign) YTResourceInfo *mainResource;

- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock;
- (BOOL)isNoteLoaded;
- (BOOL)isAllImagesShown;
- (UIView *)getContentTextView;
- (void)onShowAnimationBefore;
- (void)onShowAnimationDuring;
- (void)onShowAnimationAfter;
- (void)onCloseAnimationBefore;
- (void)onCloseAnimationDuring;
- (void)onCloseAnimationAfter;
- (void)close;

@end

