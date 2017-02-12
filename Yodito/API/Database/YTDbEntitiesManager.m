
#import "YTDbEntitiesManager.h"
#import "YTDatabaseManager.h"
#import "../Sync/Classes.h"
#import "YTResourcesDbManager.h"
#import "YTUsersEnManager.h"

/*Boolean YTDbEntitiesManager_EntityEqualByReference(CFTypeRef cf1, CFTypeRef cf2) {
	return (cf1 == cf2);
}

CFHashCode YTDbEntitiesManager_EntityReferenceHashCode(const void *value) {
	return *((CFHashCode *)value);
}*/

@implementation YTDbEntitiesManager

- (void)checkIsDatabaseThread {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
}

- (id)initWithEntityClass:(Class)entityClass database:(VLSqliteDatabase *)database {
	self = [super initWithEntityClass:entityClass database:database];
	if(self) {
		[self checkIsDatabaseThread];
		//CFSetCallBacks acb = {0, NULL, NULL, CFCopyDescription, YTDbEntitiesManager_EntityEqualByReference, YTDbEntitiesManager_EntityReferenceHashCode};
		//_setEntitiesNotDeteled = (NSMutableSet *)CFSetCreateMutable(NULL, 0, &acb);
	}
	return self;
}

- (void)initialize {
	[self checkIsDatabaseThread];
}

- (void)clearEntities {
	[self checkIsDatabaseThread];
	[super clearEntities];
}

- (void)deleteAllEntitiesFromDb {
	[self checkIsDatabaseThread];
	[super deleteAllEntitiesFromDb];
}

- (void)loadEntitiesFromDb {
	[self checkIsDatabaseThread];
	[super loadEntitiesFromDb];
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[self checkIsDatabaseThread];
	VLLoggerTrace(@"%@", [entity description]);
	[super addEntity:entity];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[self checkIsDatabaseThread];
	VLLoggerTrace(@"%@", [entity description]);
	[super deleteEntityFromDb:entity];
}

//- (void)saveEntityToDb:(VLSqliteEntity *)entity {
//	[super saveE];
//}

- (void)saveChangesToDb {
	[self checkIsDatabaseThread];
	[super saveChangesToDb];
}

- (void)updateEntitiesFromOutside:(NSArray *)newEntities {
	[self checkIsDatabaseThread];
	[super updateEntitiesFromOutside:newEntities];
}

- (void)recreateTableInDb {
	[self checkIsDatabaseThread];
	[super recreateTableInDb];
}

- (void)updateTableInDb {
	[self checkIsDatabaseThread];
	[super updateTableInDb];
}

- (BOOL)containsEntityReference:(VLSqliteEntity *)entity {
	[self checkIsDatabaseThread];
	return [super containsEntityReference:entity];
}

- (NSArray *)entities {
	[self checkIsDatabaseThread];
	return [super entities];
}

- (NSArray *)entitiesNotDeleted {
	[self checkIsDatabaseThread];
	return [super entitiesNotDeleted];
}

- (NSString *)apiOperationForDelete {
	[self checkIsDatabaseThread];
	return @"";
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	[self checkIsDatabaseThread];
	return @"";
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	[self checkIsDatabaseThread];
	return @"";
}

- (NSString *)apiOperationForList {
	[self checkIsDatabaseThread];
	return @"";
}

- (BOOL)canPerformOperationWithEntity:(YTEntityBase *)entity syncType:(EYTSyncOperationType)syncType {
	[self checkIsDatabaseThread];
	return YES;
}

- (void)onBeforeSyncEntitiesAdded:(NSMutableArray *)entitiesAdded
				 entitiesModified:(NSMutableArray *)entitiesModified
				  entitiesDeleted:(NSMutableArray *)entitiesDeleted {
	[self checkIsDatabaseThread];
}

- (void)onSortEntitiesToDelete:(NSMutableArray *)entitiesToDelete {
	[self checkIsDatabaseThread];
}

- (void)onEntitiesListGotten {
	[self checkIsDatabaseThread];
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
}

- (void)onRequestDeleteSucceedWithEntity:(YTEntityBase *)entity {
	[self checkIsDatabaseThread];
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	[self checkIsDatabaseThread];
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	[entity getData:data];
	[postValues addObject:data];
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	[self checkIsDatabaseThread];
}

- (void)onGetResponseForModifyEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	[self checkIsDatabaseThread];
}

- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	[entity getData:data];
	[postValues addObject:data];
}

- (void)getRequestsParamsForList:(NSMutableArray *)arrRequestsParams {
	[self checkIsDatabaseThread];
	[arrRequestsParams addObject:[NSNull null]];
}

- (void)getRequestForListWithParam:(NSObject *)param postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	[self checkIsDatabaseThread];
}

- (void)onRequestFailedWithEntity:(YTEntityBase *)entity param:(NSObject *)param syncType:(EYTSyncOperationType)syncType error:(NSError *)error {
	[self checkIsDatabaseThread];
}

- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param {
	[self checkIsDatabaseThread];
}

- (void)startGetListWithTicket:(int)ticket resultBlock:(void (^)(NSMutableArray *errors))resultBlock {
	[self checkIsDatabaseThread];
	if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
		resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
		return;
	}
	
	NSMutableArray *requestsErrors = [NSMutableArray array];
	if(kYTUseSyncChunksApi) {
		[[VLMessageCenter shared] performBlock:^{
			resultBlock(requestsErrors);
		} afterDelay:0.001 ignoringTouches:NO];
		//resultBlock(requestsErrors);
		return;
	}
	
	NSMutableArray *arrRequestsParams = [NSMutableArray array];
	[self getRequestsParamsForList:arrRequestsParams];
	NSMutableArray *arrRequestsParamsLeft = [NSMutableArray arrayWithArray:arrRequestsParams];
	NSMutableArray *arrRequestsParamsProcessed = [NSMutableArray array];
	
	NSMutableArray *arrOfArrsEntitiesGot = [NSMutableArray array];
	NSMutableArray *arrOfParamsForEntitiesGot = [NSMutableArray array];
	
	void (^__block blockListing)() = nil;
	
	void (^__block blockComplete)
	(YTWebRequest *request, YTEntityBase *entity, NSMutableArray *lastEntitiesArray, NSDictionary *response, NSError *responseError) =
	^(YTWebRequest *request, YTEntityBase *entity, NSMutableArray *lastEntitiesArray, NSDictionary *response, NSError *responseError) {
		if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
			resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
			Block_release(blockListing);
			Block_release(blockComplete);
			return;
		}
		if(responseError) {
			VLLogError(responseError);
			[requestsErrors addObject:responseError];
		}
		if(arrRequestsParamsProcessed.count < arrRequestsParams.count) {
			blockListing();
			return;
		}
		if(arrRequestsParamsProcessed.count == arrRequestsParams.count) {
			if(!requestsErrors.count && !kYTUseSyncChunksApi) {
				for(int i = 0; i < arrOfArrsEntitiesGot.count; i++) {
					NSArray *entities = [arrOfArrsEntitiesGot objectAtIndex:i];
					NSObject *objParam = [arrOfParamsForEntitiesGot objectAtIndex:i];
					[self updateEntitiesFromOutside:entities];
					for(YTEntityBase *entity in entities) {
						entity.added = NO;
						entity.deleted = NO;
						entity.modified = NO;
						[self onEntityFromListingUpdated:entity param:objParam];
					}
				}
			}
			resultBlock(requestsErrors);
			Block_release(blockListing);
			Block_release(blockComplete);
		}
	};
	
	blockListing = ^ () {
		NSMutableArray *curRequestsParams = [NSMutableArray array];
		for(int i = 0; i < kYTMaxSimulRequestsListing; i++) {
			if(!arrRequestsParamsLeft.count)
				break;
			[curRequestsParams addObject:[arrRequestsParamsLeft objectAtIndex:0]];
			[arrRequestsParamsLeft removeObjectAtIndex:0];
		}
		for(NSObject *objParam in curRequestsParams) {
			BOOL needSkip = NO;
			NSString *sOper = [self apiOperationForList];
			if([NSString isEmpty:sOper])
				needSkip = YES;
			YTEntityBase *objEntity = ObjectCast(objParam, YTEntityBase);
			if(objEntity && ![self canPerformOperationWithEntity:objEntity syncType:EYTSyncOperationTypeList]) {
				needSkip = YES;
			}
			if(needSkip) {
				[arrRequestsParamsProcessed addObject:objParam];
				continue;
			}
			NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
									 kYTUrlParamOperation, sOper];
			NSMutableArray *postValues = [NSMutableArray array];
			[postValues addObject:[YTUsersEnManager shared].authenticationToken];
			[self getRequestForListWithParam:objParam postValues:postValues];
			YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
			[request postWithUrl:sUrl
						  values:postValues
					 resultBlock:^(NSDictionary *response, NSError *error)
			{
				if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
					blockComplete(nil, nil, nil, nil, nil);
					return;
				}
				if(!error) {
					NSArray *arrData = [response arrayValueForKey:@"" defaultIsEmpty:YES];
					if(!arrData.count && [sOper rangeOfString:@"get" options:NSCaseInsensitiveSearch].location == 0
						&& response.count > 0) {
						arrData = [NSMutableArray arrayWithObject:response];
					}
					NSMutableArray *arrEntities = [NSMutableArray array];
					[self parseEntitiesFromDataArray:arrData param:objParam result:arrEntities];
					[arrOfArrsEntitiesGot addObject:arrEntities];
					[arrOfParamsForEntitiesGot addObject:objParam];
				}
				if(error)
					[self onRequestFailedWithEntity:nil param:objParam syncType:EYTSyncOperationTypeList error:error];
				[arrRequestsParamsProcessed addObject:objParam];
				blockComplete(request, nil, nil, response, error);
			}];
		}
	};
	
	blockListing = Block_copy(blockListing);
	blockComplete = Block_copy(blockComplete);
	
	blockComplete(nil, nil, nil, nil, nil);
}

- (void)startSyncWithTicket:(int)ticket resultBlock:(void (^)(NSMutableArray *errors))resultBlock {
	[self checkIsDatabaseThread];
	if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
		resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
		return;
	}
	NSArray *lastEntities = [NSArray arrayWithArray:self.entities];
	NSMutableArray *entitiesDeleted = [NSMutableArray array];
	NSMutableArray *entitiesAdded = [NSMutableArray array];
	NSMutableArray *entitiesModified = [NSMutableArray array];
	for(YTEntityBase *entity in lastEntities) {
		if(entity.added && entity.deleted) {
			[self deleteEntityFromDb:entity];
			continue;
		}
		if(entity.isTemporary)
			continue;
		if(entity.deleted) {
			[entitiesDeleted addObject:entity];
		} else if(entity.added) {
			[entitiesAdded addObject:entity];
			entity.deleted = entity.modified = NO;
		} else if(entity.modified) {
			[entitiesModified addObject:entity];
		}
	}
	
	if(kYTDisableUploadChangesToServer) {
		[entitiesAdded removeAllObjects];
		[entitiesDeleted removeAllObjects];
		[entitiesModified removeAllObjects];
	}
	
	[self onBeforeSyncEntitiesAdded:entitiesAdded entitiesModified:entitiesModified entitiesDeleted:entitiesDeleted];
	
	[self onSortEntitiesToDelete:entitiesDeleted];
	
	NSMutableArray *entitiesAddedLeft = [NSMutableArray arrayWithArray:entitiesAdded];
	NSMutableArray *entitiesDeletedLeft = [NSMutableArray arrayWithArray:entitiesDeleted];
	NSMutableArray *entitiesModifiedLeft = [NSMutableArray arrayWithArray:entitiesModified];
	
	NSMutableArray *entitiesAddedProcessed = [NSMutableArray array];
	NSMutableArray *entitiesDeletedProcessed = [NSMutableArray array];
	NSMutableArray *entitiesModifiedProcessed = [NSMutableArray array];
	
	NSMutableArray *requestsErrors = [NSMutableArray array];
	
	void (^__block blockAdding)() = nil;
	void (^__block blockDeleting)() = nil;
	void (^__block blockModifying)() = nil;
	
	void (^__block blockComplete)
	(YTWebRequest *request, YTEntityBase *entity, NSMutableArray *lastEntitiesArray, NSDictionary *response, NSError *responseError) =
	^(YTWebRequest *request, YTEntityBase *entity, NSMutableArray *lastEntitiesArray, NSDictionary *response, NSError *responseError) {
		if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
			resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
			Block_release(blockAdding);
			Block_release(blockDeleting);
			Block_release(blockModifying);
			Block_release(blockComplete);
			return;
		}
		if(responseError) {
			VLLogError(responseError);
			[requestsErrors addObject:responseError];
		}
		if(entitiesAddedProcessed.count < entitiesAdded.count) {
			blockAdding();
			return;
		} else if(entitiesDeletedProcessed.count < entitiesDeleted.count) {
			blockDeleting();
			return;
		} else if(entitiesModifiedProcessed.count < entitiesModified.count) {
			blockModifying();
			return;
		}
		[self startGetListWithTicket:ticket resultBlock:^(NSMutableArray *errors) {
			[requestsErrors addObjectsFromArray:errors];
			if(!requestsErrors.count) {
				[self onEntitiesListGotten];
			}
			resultBlock(requestsErrors);
			Block_release(blockAdding);
			Block_release(blockDeleting);
			Block_release(blockModifying);
			Block_release(blockComplete);
		}];
	};
	
	blockAdding = ^ () {
		NSMutableArray *curEntities = [NSMutableArray array];
		for(int i = 0; i < kYTMaxSimulRequestsAdding; i++) {
			if(!entitiesAddedLeft.count)
				break;
			[curEntities addObject:[entitiesAddedLeft objectAtIndex:0]];
			[entitiesAddedLeft removeObjectAtIndex:0];
		}
		for(YTEntityBase *entity in curEntities) {
			BOOL needSkip = NO;
			if(![self canPerformOperationWithEntity:entity syncType:EYTSyncOperationTypeAdd])
				needSkip = YES;
			NSString *sOper = [self apiOperationForAddEntity:entity];
			if([NSString isEmpty:sOper]) {
				entity.added = NO;
				needSkip = YES;
			}
			if(needSkip) {
				[entitiesAddedProcessed addObject:entity];
				blockComplete(nil, entity, entitiesAdded, nil, nil);
				continue;
			}
			if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
				resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
				return;
			}
			NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
									 kYTUrlParamOperation, sOper];
			NSMutableArray *postValues = [NSMutableArray array];
			[postValues addObject:[YTUsersEnManager shared].authenticationToken];
			NSMutableArray *arrFiles = [NSMutableArray array];
			[self getRequestForAddEntity:entity postValues:postValues arrFiles:arrFiles needSkip:&needSkip];
			if(needSkip) {
				[entitiesAddedProcessed addObject:entity];
				blockComplete(nil, entity, entitiesAdded, nil, nil);
				continue;
			}
			YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
			[request postWithUrl:sUrl
						  values:postValues
						   files:arrFiles
			 resultBlock:^(NSDictionary *response, NSError *error)
			{
				NSError *error1 = error;
				if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
					blockComplete(nil, nil, nil, nil, nil);
					return;
				}
				VLLogEvent(([NSString stringWithFormat:@"Got response from %@", [sUrl yoditoCutServerUrl]]));
				BOOL alreadyAdded = NO;
				if(error1) {
					NSString *sError = [NSString stringWithFormat:@"%@", error1];
					if([sError rangeOfString:@"already exist"].length) {
						error1 = nil;
						alreadyAdded = YES;
					}
				}
				if(!error1) {
					entity.added = NO;
					if(alreadyAdded)
						entity.modified = YES;
					[self onGetResponseForAddEntity:entity response:response];
				}
				if(error1)
					[self onRequestFailedWithEntity:entity param:nil syncType:EYTSyncOperationTypeAdd error:error1];
				[entitiesAddedProcessed addObject:entity];
				blockComplete(request, entity, entitiesAdded, response, error1);
			}];
		}
	};
	
	blockDeleting = ^ () {
		NSMutableArray *curEntities = [NSMutableArray array];
		for(int i = 0; i < kYTMaxSimulRequestsDeleting; i++) {
			if(!entitiesDeletedLeft.count)
				break;
			[curEntities addObject:[entitiesDeletedLeft objectAtIndex:0]];
			[entitiesDeletedLeft removeObjectAtIndex:0];
		}
		for(YTEntityBase *entity in curEntities) {
			BOOL needSkip = NO;
			if(!entity.deleted)
				needSkip = YES;
			if(![self canPerformOperationWithEntity:entity syncType:EYTSyncOperationTypeDelete])
				needSkip = YES;
			NSString *sOper = [self apiOperationForDelete];
			if([NSString isEmpty:sOper])
				needSkip = YES;
			if(needSkip) {
				[entitiesDeletedProcessed addObject:entity];
				blockComplete(nil, entity, entitiesDeleted, nil, nil);
				continue;
			}
			if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
				resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
				return;
			}
			NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
									 kYTUrlParamOperation, sOper];
			NSMutableArray *postValues = [NSMutableArray array];
			[postValues addObject:[YTUsersEnManager shared].authenticationToken];
			[self getRequestForDeleteEntity:entity postValues:postValues];
			YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
			[request postWithUrl:sUrl
						  values:postValues
					 resultBlock:^(NSDictionary *response, NSError *error)
			{
				if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
					blockComplete(nil, nil, nil, nil, nil);
					return;
				}
				if(!error) {
					[self onRequestDeleteSucceedWithEntity:entity];
					[self deleteEntityFromDb:entity];
				}
				if(error)
					[self onRequestFailedWithEntity:entity param:nil syncType:EYTSyncOperationTypeDelete error:error];
				[entitiesDeletedProcessed addObject:entity];
				blockComplete(request, entity, entitiesDeleted, response, error);
			}];
		}
	};
	
	blockModifying = ^ () {
		NSMutableArray *curEntities = [NSMutableArray array];
		for(int i = 0; i < kYTMaxSimulRequestsModifying; i++) {
			if(!entitiesModifiedLeft.count)
				break;
			[curEntities addObject:[entitiesModifiedLeft objectAtIndex:0]];
			[entitiesModifiedLeft removeObjectAtIndex:0];
		}
		for(YTEntityBase *entity in curEntities) {
			BOOL needSkip = NO;
			if(![self canPerformOperationWithEntity:entity syncType:EYTSyncOperationTypeModify])
				needSkip = YES;
			NSString *sOper = [self apiOperationForModifyEntity:entity];
			if([NSString isEmpty:sOper])
				needSkip = YES;
			if(needSkip) {
				[entitiesModifiedProcessed addObject:entity];
				blockComplete(nil, entity, entitiesModified, nil, nil);
				continue;
			}
			if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
				resultBlock([NSMutableArray arrayWithObject:[NSError makeCancel]]);
				return;
			}
			NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
									 kYTUrlParamOperation, sOper];
			NSMutableArray *postValues = [NSMutableArray array];
			[postValues addObject:[YTUsersEnManager shared].authenticationToken];
			[self getRequestForModifyEntity:entity postValues:postValues];
			YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
			int64_t lastEntityVersion = entity.version;
			[request postWithUrl:sUrl
						  values:postValues
					 resultBlock:^(NSDictionary *response, NSError *error)
			{
				if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
					blockComplete(nil, nil, nil, nil, nil);
					return;
				}
				if(!error) {
					if(entity.version == lastEntityVersion)
						entity.modified = NO;
					[self onGetResponseForModifyEntity:entity response:response];
				}
				if(error)
					[self onRequestFailedWithEntity:entity param:nil syncType:EYTSyncOperationTypeModify error:error];
				[entitiesModifiedProcessed addObject:entity];
				blockComplete(request, entity, entitiesModified, response, error);
			}];
		}
	};
	
	blockAdding = Block_copy(blockAdding);
	blockDeleting = Block_copy(blockDeleting);
	blockModifying = Block_copy(blockModifying);
	blockComplete = Block_copy(blockComplete);
	
	blockComplete(nil, nil, nil, nil, nil);
}

- (void)dealloc {
	[super dealloc];
}

@end

