
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../User/Classes.h"
#import "../Notes/Classes.h"
#import "YTMainStatusView.h"
#import "../Ctrls/Classes.h"

@interface YTNotesContentView_StatusBarBackView : YTBaseView {
@private
	//NSMutableArray *_backColors;
}

//- (void)pushBackColor:(UIColor *)color;
//- (void)popBackColor;

@end



@interface YTNotesContentView : YTBaseView <YTMainStatusViewDelegate, YTNavigatingViewDelegate> {
@private
	BOOL _isMainNotesContentView;
	YTNavigationView *_navigationView;
	YTNotesContentView_StatusBarBackView *_statusBarBack;
	BOOL _statusBarBackVisible;
	YTMainStatusView *_mainStatusView;
	BOOL _mainStatusViewShown;
}

@property(nonatomic, readonly) BOOL isMainNotesContentView;
@property(nonatomic, readonly) YTNavigationView *navigationView;
@property(nonatomic, readonly) YTNotesContentView_StatusBarBackView *statusBarBack;

- (id)initWithFrame:(CGRect)frame isMainNotesContentView:(BOOL)isMainNotesContentView;
- (void)pushView:(YTBaseView *)view animated:(BOOL)animated;
- (void)popView:(YTBaseView *)view animated:(BOOL)animated;
- (void)setStatusBarBackVisible:(BOOL)statusBarBackVisible animated:(BOOL)animated animations:(void (^)(void))animations;

@end

