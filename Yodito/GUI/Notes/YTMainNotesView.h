
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteEditView.h"
#import "../Ctrls/Classes.h"
#import "YTNoteView.h"
#import "../NotesTable/Classes.h"


@interface YTMainNotesView_MenuBackView : VLBaseView {
@private
	NSTimeInterval _lastUptimeTouch;
}
@end


@interface YTMainNotesView : YTBaseView {
@private
	UIView *_barBackView;
	YTNotesDisplayParams *_notesDisplayParams;
	YTNotesTableView *_notesTableView;
	YTTransparentActivityView *_activityView;
}

@property(nonatomic, readonly) BOOL menuShown;
@property(nonatomic, readonly) BOOL hasNotesLoadedOnce;
@property(nonatomic, readonly) YTNotesDisplayParams *notesDisplayParams;

+ (YTMainNotesView *)currentInstance;
- (id)initWithFrame:(CGRect)frame notesDisplayParams:(YTNotesDisplayParams *)notesDisplayParams;

@end

