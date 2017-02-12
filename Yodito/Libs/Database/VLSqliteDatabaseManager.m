
#import "VLSqliteDatabaseManager.h"

#define kDbTableConfig @"t_vl_config"

#define kDbFieldKey @"f_key"
#define kDbFieldValue @"f_value"

#define kDbValueVersion @"version"

@implementation VLSqliteDatabaseManager

@synthesize database = _database;

- (id)initWithFilePath:(NSString *)filePath version:(int)version {
	self = [super init];
	if(self) {
		_filePath = [filePath copy];
		_databaseVersion = version;
		
		_database = [[VLSqliteDatabase alloc] init];
	}
	return self;
}

- (void)open {
	[_database openWithFilePath:_filePath createIfNotExists:YES];
	
	__block int lastDbVersion = 0;
	[_database readRowsInTable:kDbTableConfig rowReadBlock:^(NSDictionary *dictValues) {
		NSString *sKey = [dictValues valueForKey:kDbFieldKey];
		if(sKey && [sKey isEqual:kDbValueVersion]) {
			NSString *sVal = [dictValues valueForKey:kDbFieldValue];
			if(sVal)
				lastDbVersion = [sVal intValue];
		}
	}];
	if(lastDbVersion != _databaseVersion) {
		[_database dropTableWithName:kDbTableConfig];
		
		[_database createTableWithName:kDbTableConfig
							  colNames:[NSArray arrayWithObjects:kDbFieldKey, kDbFieldValue, nil]
						  colTypeFlags:[NSArray arrayWithObjects:[NSNumber numberWithInt:EVLSqliteFieldTypeFlagText], [NSNumber numberWithInt:EVLSqliteFieldTypeFlagText], nil]
		 ];
		[_database insertValues:[NSDictionary dictionaryWithObjectsAndKeys:kDbValueVersion, kDbFieldKey,
								 [NSString stringWithFormat:@"%d", _databaseVersion], kDbFieldValue,
								 nil]
				toTableWithName:kDbTableConfig];
		[self onDatabaseVersionChangedFromLastVersion:lastDbVersion newVersion:_databaseVersion];
	}
}

- (void)onDatabaseVersionChangedFromLastVersion:(int)lastVersion newVersion:(int)newVersion {
	
}

- (void)dealloc {
	[_database release];
	[_filePath release];
	[super dealloc];
}

@end
