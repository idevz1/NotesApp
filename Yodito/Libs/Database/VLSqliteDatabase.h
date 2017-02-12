
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "../Logic/Classes.h"
#import "VLDbCommon.h"
#import "VLSqliteEntity.h"

typedef void (^VLSqliteDatabaseBlockRowRead)(NSDictionary *dictValues);

@interface VLSqliteDatabase : VLLogicObject {
@private
	sqlite3 *_db;
}

@property(nonatomic, readonly) sqlite3 *db;

- (BOOL)openWithFilePath:(NSString *)filePath createIfNotExists:(BOOL)createIfNotExists;
- (void)close;
- (BOOL)tableExistsWithName:(NSString *)tableName;
- (BOOL)createTableWithName:(NSString *)tableName colNames:(NSArray *)colNames colTypeFlags:(NSArray *)colTypeFlags;
- (BOOL)updateTableWithName:(NSString *)tableName colNames:(NSArray *)colNames colTypeFlags:(NSArray *)colTypeFlags;
- (BOOL)createTableWithName:(NSString *)tableName colNamesAndFlags:(NSArray *)colNamesAndFlags;
- (BOOL)createIndexIfNotExistsInTableWithName:(NSString *)tableName columnName:(NSString *)columnName indexName:(NSString *)indexName;
- (BOOL)dropTableWithName:(NSString *)tableName;
- (BOOL)readRowsInTable:(NSString *)tableName whereClause:(NSString *)whereClause rowReadBlock:(VLSqliteDatabaseBlockRowRead)rowReadBlock;
- (BOOL)readRowsInTable:(NSString *)tableName rowReadBlock:(VLSqliteDatabaseBlockRowRead)rowReadBlock;
- (BOOL)checkRowExistInTable:(NSString *)tableName whereClause:(NSString *)whereClause;
- (BOOL)readRowsValuesInTable:(NSString *)tableName columnName:(NSString *)columnName result:(NSMutableArray *)result;
- (int64_t)insertValues:(NSDictionary *)dictValues toTableWithName:(NSString *)tableName;
- (BOOL)updateRowWithId:(int64_t)nRowId colIdName:(NSString *)colIdName
				 values:(NSDictionary *)dictValues inTableWithName:(NSString *)tableName;
- (BOOL)deleteRowWithId:(int64_t)nRowId colIdName:(NSString *)colIdName fromTableWithName:(NSString *)tableName;
- (BOOL)deleteAllRowsFromTableWithName:(NSString *)tableName;
- (BOOL)beginTransaction;
- (BOOL)commitTransaction;

@end

