
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTNoteToLocationInfo : YTEntityBase {
@private
	NSString *_noteGuid;
	int64_t _locationId;
}

@property(nonatomic, assign) NSString *noteGuid;
@property(nonatomic, assign) int64_t locationId;

- (void)assignDataFrom:(YTNoteToLocationInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTNoteToLocationInfo *)other;
- (NSComparisonResult)compareDataTo:(YTNoteToLocationInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;
+ (NSString *)entityName;

@end

