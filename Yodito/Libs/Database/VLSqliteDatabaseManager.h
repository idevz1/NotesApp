
#import <Foundation/Foundation.h>
#import "VLSqliteDatabase.h"

@interface VLSqliteDatabaseManager : VLLogicObject {
@private
	VLSqliteDatabase *_database;
	NSString *_filePath;
	int _databaseVersion;
}

@property(nonatomic, readonly) VLSqliteDatabase *database;

- (id)initWithFilePath:(NSString *)filePath version:(int)version;
- (void)open;
- (void)onDatabaseVersionChangedFromLastVersion:(int)lastVersion newVersion:(int)newVersion;

@end
