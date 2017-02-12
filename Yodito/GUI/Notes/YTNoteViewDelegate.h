
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTNoteView;

@protocol YTNoteViewDelegate <NSObject>
@required
- (void)noteView:(YTNoteView *)noteView finishWithAction:(EYTUserActionType)action;

@end


