
#import <Foundation/Foundation.h>
#import "YTDbEntitiesManager.h"
#import "YTSqliteDatabaseManager.h"

@class YTDatabaseManager;

@protocol YTDatabaseManagerDelegate <NSObject>
@required
- (void)databaseManager:(YTDatabaseManager *)databaseManager updateOnDT:(id)param;
@end


@interface YTDatabaseManager : VLLogicObject <YTSqliteDatabaseManagerDelegate> {
@private
	NSThread *_thread;
	YTSqliteDatabaseManager *_databaseManager;
	NSMutableArray *_delegates;
	NSMutableArray *_managersOrdered;
	NSMutableArray *_managersOrderedSavedVersions;
	BOOL _initialized;
	VLDelegate *_dlgtEntityIdChanged;
}

@property(nonatomic, readonly) VLSqliteDatabase *database;
@property(readonly) BOOL initialized;
@property(nonatomic, readonly) VLDelegate *dlgtEntityIdChanged;

+ (YTDatabaseManager *)shared;
- (void)initializeMT;
- (void)initializeWithResultBlockMT:(VLBlockVoid)resultBlockMT;
- (BOOL)isDatabaseThread;
- (void)checkIsDatabaseThread;
- (void)checkIsMainThread;
- (void)addDelegate:(NSObject<YTDatabaseManagerDelegate> *)delegate;
- (void)deleteAllUserEntities;
- (void)checkHasAnyChangesForSyncWithResultBlock:(void(^)(BOOL result, NSString *info))resultBlock;
- (void)waitingUntilDone:(BOOL)wait performBlockOnDT:(VLBlockVoid)blockOnDT;
- (void)waitingUntilDone:(BOOL)wait performBlockOnMT:(VLBlockVoid)blockOnMT;
- (void)cleanDatabase;
- (void)cleanDatabaseWithResultBlock:(VLBlockVoid)resultBlock;
- (void)searchNotesWithText:(NSString *)searchText resultBlock:(void(^)(NSArray *notes))resultBlock;
- (int64_t)makeNewTempId;
- (BOOL)isTempId:(int64_t)nId;
- (void)notifyIdChangedForEntiy:(YTEntityBase *)entity formId:(int64_t)idLast toId:(int64_t)idNew;

@end



@interface YTEntityIdChangedArgs : NSObject {
@private
	YTEntityBase *_entity;
	int64_t _idLast;
	int64_t _idNew;
}

@property(retain) YTEntityBase *entity;
@property(assign) int64_t idLast;
@property(assign) int64_t idNew;

@end



