
#import "VLSqliteDatabase.h"

@implementation VLSqliteDatabase

@synthesize db = _db;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (BOOL)openWithFilePath:(NSString *)filePath createIfNotExists:(BOOL)createIfNotExists {
	[self close];
	int res = sqlite3_open_v2([filePath UTF8String], &_db, SQLITE_OPEN_READWRITE, NULL);
	if(res == SQLITE_OK) {
		VLLogEvent(@"Database opened successfully");
		return YES;
	}
	[self close];
	if(createIfNotExists) {
		res = sqlite3_open_v2([filePath UTF8String], &_db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL);
		if(res == SQLITE_OK) {
			VLLogEvent(@"Database created successfully");
			return YES;
		}
	}
	VLLogError(@"Failed to open database");
	return NO;
}

- (void)close {
	if(_db) {
		sqlite3_close(_db);
		_db = nil;
	}
}

- (BOOL)tableExistsWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:
							   @"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'", tableName];
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		return NO;
	}
	BOOL result = NO;
	if(sqlite3_step(stmt) == SQLITE_ROW) {
		result = YES;
	}
	sqlite3_finalize(stmt);
	return result;
}

- (BOOL)createTableWithName:(NSString *)tableName colNames:(NSArray *)colNames colTypeFlags:(NSArray *)colTypeFlags {
	NSMutableString *sQuery = [NSMutableString string];
	[sQuery appendString:@"CREATE TABLE"];
	[sQuery appendFormat:@" %@", tableName];
	for(int i = 0; i < colNames.count; i++) {
		if(i == 0) {
			[sQuery appendString:@" ("];
		}
		if(i > 0)
			[sQuery appendString:@", "];
		NSString *colName = [colNames objectAtIndex:i];
		NSNumber *num = [colTypeFlags objectAtIndex:i];
		EVLSqliteFieldTypeFlag colTypeFlags = (EVLSqliteFieldTypeFlag)num.intValue;
		[sQuery appendFormat:@"%@ ", colName];
		if(colTypeFlags & EVLSqliteFieldTypeFlagInteger)
			[sQuery appendString:@"INTEGER"];
		else if(colTypeFlags & EVLSqliteFieldTypeFlagReal)
			[sQuery appendString:@"REAL"];
		else if(colTypeFlags & EVLSqliteFieldTypeFlagText)
			[sQuery appendString:@"TEXT"];
		else if(colTypeFlags & EVLSqliteFieldTypeFlagBlob)
			[sQuery appendString:@"BLOB"];
		if(colTypeFlags & EVLSqliteFieldTypeFlagPrimaryKey)
			[sQuery appendString:@" PRIMARY KEY NOT NULL UNIQUE"];
		if(i == colNames.count - 1) {
			[sQuery appendString:@")"];
		}
	}
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	VLLogEvent(([NSString stringWithFormat:@"Table %@ created", tableName]));
	return YES;
}

- (BOOL)updateTableWithName:(NSString *)tableName colNames:(NSArray *)colNames colTypeFlags:(NSArray *)colTypeFlags {
	if(![self tableExistsWithName:tableName]) {
		return [self createTableWithName:tableName colNames:colNames colTypeFlags:colTypeFlags];
	}
	NSMutableString *sQuery = [NSMutableString stringWithFormat:
				//@"SELECT sql FROM sqlite_master WHERE tbl_name = '%@' AND type = 'table_name'", tableName];
				@"SELECT * FROM %@", tableName];
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		return NO;
	}
	NSMutableArray *existedColNames = [NSMutableArray array];
	int colsCount = sqlite3_column_count(stmt);
	for(int nCol = 0; nCol < colsCount; nCol++) {
		const char *cColName = sqlite3_column_name(stmt, nCol);
		//int colType = sqlite3_column_type(stmt, nCol);
		NSString *colName = [[[NSString alloc] initWithUTF8String:cColName] autorelease];
		[existedColNames addObject:colName];
	}
	NSMutableArray *addedColNames = [NSMutableArray array];
	NSMutableArray *deletedColNames = [NSMutableArray array];
	for(NSString *colName in colNames) {
		if(![existedColNames containsObject:colName]) {
			[addedColNames addObject:colName];
		}
	}
	for(NSString *colName in existedColNames) {
		if(![colNames containsObject:colName]) {
			[deletedColNames addObject:colName];
		}
	}
	// !WARNING: DROP COLUMN not working im sqlite
	for(NSString *colName in deletedColNames) {
		NSMutableString *sQueryCol = [NSMutableString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@", tableName, colName];
		char *errorMsgCol;
		int resCol = sqlite3_exec(_db, [sQueryCol UTF8String], NULL, NULL, &errorMsgCol);
		if(resCol != SQLITE_OK) {
			VLLogError(([NSString stringWithFormat:@"%s", errorMsgCol]));
			sqlite3_free(errorMsgCol);
		}
	}
	for(NSString *colName in addedColNames) {
		int index = (int)[colNames indexOfObject:colName];
		NSString *sColType = @"";
		NSString *sDefVal = @"(NULL)";
		NSNumber *num = [colTypeFlags objectAtIndex:index];
		EVLSqliteFieldTypeFlag colTypeFlags = (EVLSqliteFieldTypeFlag)num.intValue;
		if(colTypeFlags & EVLSqliteFieldTypeFlagInteger) {
			sColType = @"INTEGER";
			sDefVal = @"'0'";
		} else if(colTypeFlags & EVLSqliteFieldTypeFlagReal) {
			sColType = @"REAL";
			sDefVal = @"'0'";
		} else if(colTypeFlags & EVLSqliteFieldTypeFlagText) {
			sColType = @"TEXT";
			sDefVal = @"''";
		} else if(colTypeFlags & EVLSqliteFieldTypeFlagBlob) {
			sColType = @"BLOB";
		}
		NSMutableString *sQueryCol = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@ DEFAULT %@",
									  tableName, colName, sColType, sDefVal];
		char *errorMsgCol;
		int resCol = sqlite3_exec(_db, [sQueryCol UTF8String], NULL, NULL, &errorMsgCol);
		if(resCol != SQLITE_OK) {
			VLLogError(([NSString stringWithFormat:@"%s", errorMsgCol]));
			sqlite3_free(errorMsgCol);
		}
	}
	sqlite3_finalize(stmt);
	return YES;
}

- (BOOL)createTableWithName:(NSString *)tableName colNamesAndFlags:(NSArray *)colNamesAndFlags {
	NSMutableArray *colNames = [NSMutableArray array];
	NSMutableArray *colTypeFlags = [NSMutableArray array];
	for(int i = 0; i < colNamesAndFlags.count; i += 2) {
		[colNames addObject:[colNamesAndFlags objectAtIndex:i]];
		[colTypeFlags addObject:[colNamesAndFlags objectAtIndex:i + 1]];
	}
	return [self createTableWithName:tableName colNames:colNames colTypeFlags:colTypeFlags];
}

- (BOOL)createIndexIfNotExistsInTableWithName:(NSString *)tableName columnName:(NSString *)columnName indexName:(NSString *)indexName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:
							   @"CREATE INDEX IF NOT EXISTS %@ ON %@ (%@ ASC)",
							   indexName, tableName, columnName];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	return YES;
}

- (BOOL)dropTableWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString string];
	[sQuery appendString:@"DROP TABLE"];
	[sQuery appendFormat:@" %@", tableName];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	VLLogEvent(([NSString stringWithFormat:@"Table %@ dropped", tableName]));
	return YES;
}

- (BOOL)readRowsInTable:(NSString *)tableName whereClause:(NSString *)whereClause rowReadBlock:(VLSqliteDatabaseBlockRowRead)rowReadBlock {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"SELECT * FROM %@", tableName];
	if(![NSString isEmpty:whereClause]) {
		[sQuery appendString:@" WHERE ("];
		[sQuery appendString:whereClause];
		[sQuery appendString:@")"];
	}
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		return NO;
	}
	int colsCount = sqlite3_column_count(stmt);
	NSMutableDictionary *dictValues = nil;
	NSMutableArray *columnNames = nil;
	int columnTypes[colsCount];
	int index = -1;
	while(sqlite3_step(stmt) == SQLITE_ROW) {
		index++;
		if(index == 0) {
			if(!dictValues)
				dictValues = [[NSMutableDictionary alloc] init];
			if(!columnNames)
				columnNames = [[NSMutableArray alloc] init];
			for(int nCol = 0; nCol < colsCount; nCol++) {
				int colType = sqlite3_column_type(stmt, nCol);
				columnTypes[nCol] = colType;
				const char *name = sqlite3_column_name(stmt, nCol);
				NSString *columnName = [[[NSString alloc] initWithUTF8String:name] autorelease];
				[columnNames addObject:columnName];
			}
		}
		[dictValues removeAllObjects];
		for(int i = 0; i < colsCount; i++) {
			int colType = columnTypes[i];
			NSString *columnName = [columnNames objectAtIndex:i];
			id val = nil;
			if(colType == SQLITE_INTEGER)
				val = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
			else if(colType == SQLITE_FLOAT)
				val = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
			else if(colType == SQLITE_TEXT) {
				const char *text = (const char *)sqlite3_column_text(stmt, i);
				if(text)
					val = [[[NSString alloc] initWithUTF8String:text] autorelease];
			}
			[dictValues setObject:(val ? val : [NSNull null]) forKey:columnName];
		}
		rowReadBlock(dictValues);
	}
	sqlite3_finalize(stmt);
	if(dictValues) {
		[dictValues release];
	}
	if(columnNames) {
		[columnNames release];
	}
	return YES;
}

- (BOOL)readRowsInTable:(NSString *)tableName rowReadBlock:(VLSqliteDatabaseBlockRowRead)rowReadBlock {
	return [self readRowsInTable:tableName whereClause:nil rowReadBlock:rowReadBlock];
}

- (BOOL)checkRowExistInTable:(NSString *)tableName whereClause:(NSString *)whereClause {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:
							   @"SELECT EXISTS(SELECT 1 FROM %@ WHERE (%@) LIMIT 1)",
							   tableName, whereClause];
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		return NO;
	}
	int number = sqlite3_data_count(stmt);
	sqlite3_finalize(stmt);
	return number > 0;
}

- (BOOL)readRowsValuesInTable:(NSString *)tableName columnName:(NSString *)columnName result:(NSMutableArray *)result {
	[result removeAllObjects];
	NSMutableString *sQuery = [NSMutableString stringWithFormat:
							   @"SELECT %@ FROM %@",
							   columnName, tableName];
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		return NO;
	}
	int colType = 0;
	int index = -1;
	while(sqlite3_step(stmt) == SQLITE_ROW) {
		index++;
		if(index == 0) {
			colType = sqlite3_column_type(stmt, 0);
		}
		if(colType == SQLITE_TEXT) {
			NSString *sVal = @"";
			const char *text = (const char *)sqlite3_column_text(stmt, 0);
			if(text)
				sVal = [[[NSString alloc] initWithUTF8String:text] autorelease];
			[result addObject:sVal];
		}
	}
	sqlite3_finalize(stmt);
	return YES;
}

- (int64_t)insertValues:(NSDictionary *)dictValues toTableWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", tableName];
	NSArray *keys = dictValues.allKeys;
	for(int i = 0; i < keys.count; i++) {
		NSString *sKey = [keys objectAtIndex:i];
		if(i > 0)
			[sQuery appendString:@", "];
		[sQuery appendString:sKey];
	}
	[sQuery appendString:@") VALUES ("];
	for(int i = 0; i < keys.count; i++) {
		if(i > 0)
			[sQuery appendString:@","];
		[sQuery appendString:@"?"];
	}
	[sQuery appendString:@")"];
	
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		return 0;
	}
	
	for(int i = 0; i < keys.count; i++) {
		NSString *sKey = [keys objectAtIndex:i];
		id val = [dictValues objectForKey:sKey];
		NSString *sVal = ObjectCast(val, NSString);
		NSNumber *numVal = ObjectCast(val, NSNumber);
		if(numVal)
			sVal = [numVal stringValue];
		sqlite3_bind_text(stmt, i + 1, [sVal UTF8String], -1, SQLITE_TRANSIENT);
	}
	
	res = sqlite3_step(stmt);
	if(res != SQLITE_DONE) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		sqlite3_finalize(stmt);
		return 0;
	}
	
	int64_t lastInsertRowId = sqlite3_last_insert_rowid(_db);
	sqlite3_finalize(stmt);
	return lastInsertRowId;
}

- (BOOL)updateRowWithId:(int64_t)nRowId colIdName:(NSString *)colIdName
				 values:(NSDictionary *)dictValues inTableWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", tableName];
	NSArray *keys = dictValues.allKeys;
	for(int i = 0; i < keys.count; i++) {
		if(i > 0)
			[sQuery appendString:@", "];
		NSString *sKey = [keys objectAtIndex:i];
		[sQuery appendFormat:@"%@ = ?", sKey];
	}
	[sQuery appendFormat:@" WHERE %@ = %lld", colIdName, nRowId];
	
	sqlite3_stmt *stmt;
	int res = sqlite3_prepare_v2(_db, [sQuery UTF8String], -1, &stmt, NULL);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		return NO;
	}
	
	for(int i = 0; i < keys.count; i++) {
		NSString *sKey = [keys objectAtIndex:i];
		id val = [dictValues objectForKey:sKey];
		NSString *sVal = ObjectCast(val, NSString);
		NSNumber *numVal = ObjectCast(val, NSNumber);
		if(numVal)
			sVal = [numVal stringValue];
		sqlite3_bind_text(stmt, i + 1, [sVal UTF8String], -1, SQLITE_TRANSIENT);
	}
	
	res = sqlite3_step(stmt);
	if(res != SQLITE_DONE) {
		VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)]));
		sqlite3_finalize(stmt);
		return NO;
	}
	
	sqlite3_finalize(stmt);
	return YES;
}

- (BOOL)deleteRowWithId:(int64_t)nRowId colIdName:(NSString *)colIdName fromTableWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"DELETE FROM %@ ", tableName];
	[sQuery appendFormat:@" WHERE %@ = %lld", colIdName, nRowId];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	return YES;
}

- (BOOL)deleteAllRowsFromTableWithName:(NSString *)tableName {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"DELETE FROM %@", tableName];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	return YES;
}

- (BOOL)beginTransaction {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"%@", @"BEGIN"];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	return YES;
}

- (BOOL)commitTransaction {
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"%@", @"COMMIT"];
	char *errorMsg;
	int res = sqlite3_exec(_db, [sQuery UTF8String], NULL, NULL, &errorMsg);
	if(res != SQLITE_OK) {
		VLLogError(([NSString stringWithFormat:@"%s", errorMsg]));
		sqlite3_free(errorMsg);
		return NO;
	}
	return YES;
}

- (void)dealloc {
	[self close];
	[super dealloc];
}

@end

