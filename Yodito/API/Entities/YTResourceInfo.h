
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTResourceInfo : YTEntityBase {
@private
	int64_t _attachmentId;
	int64_t _attachmentCategoryId;
	NSString *_attachmentTypeName;
	NSString *_s3StorageUUID;
	NSString *_filename;
	NSString *_descr;
	BOOL _isThumbnail;
	int64_t _parentAttachmentId;
	NSString *_attachmenthash;
	VLDate *_lastUpdateTS;
}

@property(nonatomic, assign) int64_t attachmentId;
@property(nonatomic, assign) int64_t attachmentCategoryId;
@property(nonatomic, assign) NSString *attachmentTypeName;
@property(nonatomic, assign) NSString *s3StorageUUID;
@property(nonatomic, assign) NSString *filename;
@property(nonatomic, assign) NSString *descr;
@property(nonatomic, assign) BOOL isThumbnail;
@property(nonatomic, assign) int64_t parentAttachmentId;
@property(nonatomic, assign) NSString *attachmenthash;
@property(nonatomic, assign) VLDate *lastUpdateTS;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTResourceInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTResourceInfo *)other;
- (NSComparisonResult)compareDataTo:(YTResourceInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

- (BOOL)isImage;
- (BOOL)isVideo;
- (BOOL)isAudio;
- (BOOL)isWebDocViewable;
- (BOOL)isOtherType;
+ (NSString *)entityName;

@end

// Start Time - Time when ToDo/Event recurrance starts (Only Time)
//
// End Time - Time when Note recurrance Ends (Only Time)
//
// Day - For Daily (e.g */1 - Repeat After One Day, */2 Repeat after two days)
//
// WeekDay - For EveryWeekDay (e.g 1,2,3,4,5/1 - From Monday to Friday, 1,3,5/1 - Only Monday, Wednesday and Friday )
//
// Month - For Monthly (e.g */1 - Every Month, */2 Repeat after two Months) and In day Field we will store selected date of the month 1-31 like 15, 25, 27 etc
//
// WeekNumber - For Monthly If we choose Day of the week then we store the selected day of the month like for wednesday - 3 , Friday - 5
//
// StartDate - Date when ToDo/Event recurrance starts (Only Date)
//
// EndDate - Date when ToDo/Event recurrance starts (Only Date)
//
// NumOccurances - Number of Occurances, How many times this ToDo/Event will repeat



