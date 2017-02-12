
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Resources/Classes.h"
#import "../Ctrls/Classes.h"

@interface YTNoteAttachmentsView : YTBaseView {
@private
	UIView *_topBar;
	YTFigureView *_borderBack;
	UIButton *_btnBack;
	YTFigureView *_borderDelete;
	UIButton *_btnDelete;
	UIView *_bottomBar;
	UIButton *_btnPrev;
	UIButton *_btnNext;
	VLLabel *_lbTitle;
	YTFigureView *_borderArrows;
	BOOL _barsVisible;
	int _curIndex;
	NSMutableArray *_resources;
	NSMutableArray *_arrViews; // Array of YTCachedContentView with YTResourceView
	BOOL _editMode;
	UIView *_statusBarBackViewNAW;
}

@property(nonatomic, assign) BOOL editMode;

- (void)setCurrentResource:(YTResourceInfo *)res;
- (BOOL)isCurrentImageResourceShown;

@end
