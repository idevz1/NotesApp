
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTTagInfo : YTEntityBase {
@private
	int64_t _tagId;
	NSString *_name;
	VLDate *_lastUpdateTS;
}

@property(nonatomic, assign) int64_t tagId;
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) VLDate *lastUpdateTS;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTTagInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTTagInfo *)other;
- (NSComparisonResult)compareDataTo:(YTTagInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 Data Structure Name: 		Tag
 Field Structure:
 
 TagId			Int
 Name			String
 LastUpdateTS		Timestamp
 
 */


