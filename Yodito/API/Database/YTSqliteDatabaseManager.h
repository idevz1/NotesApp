
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTSqliteDatabaseManager;

@protocol YTSqliteDatabaseManagerDelegate <NSObject>
@required
- (void)sqliteDatabaseManager:(YTSqliteDatabaseManager *)sqliteDatabaseManager databaseVersionChanged:(id)param;
@end

@interface YTSqliteDatabaseManager : VLSqliteDatabaseManager {
@private
	NSObject<YTSqliteDatabaseManagerDelegate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTSqliteDatabaseManagerDelegate> *delegate;

- (void)initialize;

@end

