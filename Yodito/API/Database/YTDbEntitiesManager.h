
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Entities/Classes.h"
#import "../Web/Classes.h"

typedef enum
{
	EYTSyncOperationTypeNone,
	EYTSyncOperationTypeAdd,
	EYTSyncOperationTypeModify,
	EYTSyncOperationTypeDelete,
	EYTSyncOperationTypeList
}
EYTSyncOperationType;


@interface YTDbEntitiesManager : VLSqliteEntitiesManager {
@private
	//NSMutableSet *_setEntitiesNotDeteled;
}

- (void)checkIsDatabaseThread;
- (void)initialize;

- (NSString *)apiOperationForDelete;
- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity;
- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity;
- (NSString *)apiOperationForList;
- (BOOL)canPerformOperationWithEntity:(YTEntityBase *)entity syncType:(EYTSyncOperationType)syncType;
- (void)onBeforeSyncEntitiesAdded:(NSMutableArray *)entitiesAdded
				 entitiesModified:(NSMutableArray *)entitiesModified
				  entitiesDeleted:(NSMutableArray *)entitiesDeleted;
- (void)onSortEntitiesToDelete:(NSMutableArray *)entitiesToDelete;
- (void)onEntitiesListGotten;
- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues;
- (void)onRequestDeleteSucceedWithEntity:(YTEntityBase *)entity;
- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip;
- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response;
- (void)onGetResponseForModifyEntity:(YTEntityBase *)entity response:(NSDictionary *)response;
- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues;
- (void)getRequestsParamsForList:(NSMutableArray *)arrRequestsParams;
- (void)getRequestForListWithParam:(NSObject *)param postValues:(NSMutableArray *)postValues;
- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities;
- (void)onRequestFailedWithEntity:(YTEntityBase *)entity param:(NSObject *)param syncType:(EYTSyncOperationType)syncType error:(NSError *)error;
- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param;

- (void)startSyncWithTicket:(int)ticket resultBlock:(void (^)(NSMutableArray *errors))resultBlock;

@end

