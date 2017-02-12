
#import <Foundation/Foundation.h>
#import "../Common/Classes.h"

@interface VLDbCommon : NSObject

+ (NSString *)stringFromDate:(VLDate *)date;
+ (VLDate *)dateFromString:(NSString *)sDate;
+ (NSString *)stringFromDateNoTime:(VLDateNoTime *)date;
+ (VLDateNoTime *)dateNoTimeFromString:(NSString *)sDate;
+ (NSString *)stringFromTime:(VLTime *)time;
+ (VLTime *)timeFromString:(NSString *)sTime;

@end

typedef enum
{
	EVLSqliteFieldTypeFlagNone = 0,
	EVLSqliteFieldTypeFlagPrimaryKey = 0x1,
	EVLSqliteFieldTypeFlagInteger = 0x2,
	EVLSqliteFieldTypeFlagReal = 0x4,
	EVLSqliteFieldTypeFlagText = 0x8,
	EVLSqliteFieldTypeFlagBlob = 0x01
}
EVLSqliteFieldTypeFlag;

typedef enum
{
	EVLSqliteEntityAttrTypeNone = 0,
	EVLSqliteEntityAttrTypeInt64 = 1,
	EVLSqliteEntityAttrTypeInt = 2,
	EVLSqliteEntityAttrTypeString = 3,
	EVLSqliteEntityAttrTypeDate = 4,
	EVLSqliteEntityAttrTypeFloat = 5,
	EVLSqliteEntityAttrTypeDouble = 6,
	EVLSqliteEntityAttrTypeBool = 7,
	EVLSqliteEntityAttrTypeDateNoTime = 8,
	EVLSqliteEntityAttrTypeTime = 9,
	EVLSqliteEntityAttrTypeIds
}
EVLSqliteEntityAttrType;

#define kVLSqliteFieldKeyId @"id"
#define kVLSqliteFieldKeyModified @"modified"
#define kVLSqliteFieldKeyAdded @"added"
#define kVLSqliteFieldKeyDeleted @"deleted"

/*
 http://www.sqlite.org/draft/datatype3.html
 NULL. The value is a NULL value.
 INTEGER. The value is a signed integer, stored in 1, 2, 3, 4, 6, or 8 bytes depending on the magnitude of the value.
 REAL. The value is a floating point value, stored as an 8-byte IEEE floating point number.
 TEXT. The value is a text string, stored using the database encoding (UTF-8, UTF-16BE or UTF-16LE).
 BLOB. The value is a blob of data, stored exactly as it was input.
*/