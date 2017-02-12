
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

#define kYTStackIdDemo (-1)

@interface YTStackInfo : YTEntityBase {
@private
	int64_t _stackId;
	int64_t _personId;
	NSString *_stackName;
	VLDate *_createdDate;
	BOOL _isValid;
}

@property(nonatomic, assign) int64_t stackId;
@property(nonatomic, assign) int64_t personId;
@property(nonatomic, assign) NSString *stackName;
@property(nonatomic, assign) VLDate *createdDate;
@property(nonatomic, assign) BOOL isValid;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTStackInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTStackInfo *)other;
- (NSComparisonResult)compareDataTo:(YTStackInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 Data Structure Name: 		Stack
 Field Structure:
 
 StackId			int
 PersonId		int
 StackName		varchar
 CreatedDate		date
 IsValid			bit
 
 */

