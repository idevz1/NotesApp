
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"
#import "../../API/Classes.h"

@class YTCustomNavigationBar;
@class YTBaseView;
@class YTNotesContentView;


@protocol YTNavigatingViewDelegate <NSObject>
@optional
- (void)navigatingView:(YTBaseView *)navigatingView handleGoBack:(id)param;

@end


@interface YTBaseView_StatusBarBackView : VLBaseView {
@private
}

@end


@interface YTBaseView : VLBaseView {
@private
	YTCustomNavigationBar *_customNavBar;
	YTBaseView_StatusBarBackView *_statusBarBackView;
	BOOL _stickNavigationBar;
	YTNoteInfo *_note;
	YTResourceInfo *_resource;
	YTTagInfo *_noteTag;
	YTNoteEditInfo *_noteEditInfo;
	YTLocationInfo *_locationInfo;
	NSObject *_objectTag;
	NSTimeInterval _updateViewMinDelay;
	NSTimeInterval _lastUpdateViewUptime;
	BOOL _callingOnUpdateViewYTWithDelay;
	NSObject<YTNavigatingViewDelegate> *_navigatingViewDelegate;
	BOOL _navigationBarHidden;
	BOOL _slidingSuspended;
	UIStatusBarStyle _lastStatusBarStyle;
	BOOL _isScrolling;
}

@property(nonatomic, readonly) YTCustomNavigationBar *customNavBar;
@property(nonatomic, readonly) BOOL customNavBarCreated;
@property(nonatomic, readonly) CGRect boundsNoBars;
@property(nonatomic, readonly) CGRect frameOfBar;
@property(nonatomic, assign) BOOL stickNavigationBar;
@property(nonatomic, assign) YTNoteInfo *note;
@property(nonatomic, assign) YTResourceInfo *resource;
@property(nonatomic, assign) YTTagInfo *noteTag;
@property(nonatomic, assign) YTNoteEditInfo *noteEditInfo;
@property(nonatomic, assign) YTLocationInfo *locationInfo;
@property(nonatomic, retain) NSObject *objectTag;
@property(nonatomic, assign) NSObject<YTNavigatingViewDelegate> *navigatingViewDelegate;

- (YTNotesContentView *)parentContentView;

- (void)setUpdateViewMinDelay:(NSTimeInterval)updateViewMinDelay;
- (void)resetUpdateViewMinDelay;
- (void)onUpdateViewYT;

- (void)onNoteDataChanged;
- (void)onResourceDataChanged;
- (void)onNoteTagDataChanged;
- (void)onNoteEditInfoDataChanged;
- (void)onLocationInfoDataChanged;

- (void)onNotesManagerChanged;
- (void)onNotesContentManagerChanged;
- (void)onResourcesManagerChanged;
- (void)onLocationsManagerChanged;

- (void)assignEntitiesFrom:(YTBaseView *)other;

- (void)setNavigationBarHidden:(BOOL)hidden withStatusBarBackColor:(UIColor *)statusBarBackColor animated:(BOOL)animated;
- (void)suspendSliding:(BOOL)suspend;

- (void)beginIsScrolling;
- (void)endIsScrolling;

@end
