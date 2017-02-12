
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTNoteToResourceInfo : YTEntityBase {
@private
	NSString *_noteGuid;
	int64_t _resourceId;
}

@property(nonatomic, assign) NSString *noteGuid;
@property(nonatomic, assign) int64_t resourceId;

- (void)assignDataFrom:(YTNoteToResourceInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTNoteToResourceInfo *)other;
- (NSComparisonResult)compareDataTo:(YTNoteToResourceInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

