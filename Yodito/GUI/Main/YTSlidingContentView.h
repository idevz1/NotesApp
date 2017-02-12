
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNotesContentView.h"

@interface YTSlidingContentView : YTBaseView <YTNavigatingViewDelegate> {
@private
	YTNotesContentView *_notesContentView;
}

@property(nonatomic, readonly) YTNotesContentView *notesContentView;

@end

