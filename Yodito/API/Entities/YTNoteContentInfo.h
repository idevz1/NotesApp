
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTNoteContentInfo : YTEntityBase {
@private
	NSString *_noteGuid;
	NSString *_content;
}

@property(nonatomic, assign) NSString *noteGuid;
@property(nonatomic, assign) NSString *content;

@end

