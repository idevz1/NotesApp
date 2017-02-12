
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

typedef enum
{
	EYTNoteContentSeparatorStyleTwoLines,
	EYTNoteContentSeparatorStyleOneLine
}
EYTNoteContentSeparatorStyle;

@interface YTNoteContentSeparator : YTBaseView {
@private
	EYTNoteContentSeparatorStyle _style;
}

@property(nonatomic, assign) EYTNoteContentSeparatorStyle style;

@end

