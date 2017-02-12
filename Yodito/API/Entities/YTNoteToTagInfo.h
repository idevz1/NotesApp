
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTNoteToTagInfo : YTEntityBase {
@private
	NSString *_noteGuid;
	int64_t _tagId;
}

@property(nonatomic, assign) NSString *noteGuid;
@property(nonatomic, assign) int64_t tagId;

- (void)assignDataFrom:(YTNoteToTagInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTNoteToTagInfo *)other;
- (NSComparisonResult)compareDataTo:(YTNoteToTagInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;
+ (NSString *)entityName;

@end

