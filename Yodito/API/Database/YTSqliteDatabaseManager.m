
#import "YTSqliteDatabaseManager.h"
#import "YTDatabaseManager.h"

@implementation YTSqliteDatabaseManager

@synthesize delegate = _delegate;

- (void)initialize {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
}

- (void)onDatabaseVersionChangedFromLastVersion:(int)lastVersion newVersion:(int)newVersion {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	[super onDatabaseVersionChangedFromLastVersion:lastVersion newVersion:newVersion];
	if(_delegate)
		[_delegate sqliteDatabaseManager:self databaseVersionChanged:nil];
}

@end

