
#import "YTSyncCommitManager.h"
#import "YTSyncManager.h"
#import "../Managers/Classes.h"
#import "../Notes/Classes.h"
#import "../Storage/Classes.h"
#import "../Web/Classes.h"
#import "../Resources/Classes.h"
#import "../Settings/Classes.h"
#import "../YTApiMediator.h"
#import "../Misc/Classes.h"

static YTSyncCommitManager *_shared;

@implementation YTSyncCommitManager

+ (YTSyncCommitManager *)shared {
	if(!_shared)
		_shared = [[YTSyncCommitManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
	}
	return self;
}

- (void)internalSyncResourcesWithWithTicketDT:(int)ticket resultBlockDT:(void (^)(NSArray *errors))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(!kYTSyncDownloadAndStoreAllPhotos) {
		resultBlockDT([NSArray array]);
		return;
	}
	YTResourcesStorage *manrRes = [YTResourcesStorage shared];
	NSArray *allResources = [NSArray arrayWithArray:[YTResourcesDbManager shared].entities];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
	{
		NSMutableArray *arrLoadingRef = [NSMutableArray array];
		NSMutableDictionary *mapResourceByHash = [NSMutableDictionary dictionary];
		//NSMutableArray *arrLoadingRefLoaded = [NSMutableArray array];
		NSMutableArray *errErrors = [NSMutableArray array];
		for(YTResourceInfo *resource in allResources) {
			if([manrRes isResourceDownloadedWithHash:resource.attachmenthash])
				continue;
			//if(resource.attachmentCategoryId != EYTResourceCategoryTypeImage)
			//	continue;
			YTResourceLoadingReference *loadingRef = [[[YTResourceLoadingReference alloc] init] autorelease];
			[loadingRef setResourceHash:resource.attachmenthash andType:resource.attachmentTypeName categoryId:(int)resource.attachmentCategoryId];
			[arrLoadingRef addObject:loadingRef];
			[mapResourceByHash setObject:resource forKey:resource.attachmenthash];
		}
		if(!arrLoadingRef.count) {
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^ {
				resultBlockDT([NSArray array]);
			}];
			return;
		}
		[[VLMessageCenter shared] waitWithCheckBlock:^BOOL {
			if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
				return YES;
			}
			BOOL processing = NO;
			for(int i = 0; i < arrLoadingRef.count; i++) {
				id val = [arrLoadingRef objectAtIndex:i];
				YTResourceLoadingReference *loadingRef = ObjectCast(val, YTResourceLoadingReference);
				if(!loadingRef)
					continue;
				if(loadingRef.parentInfoRef.processing) {
					processing = YES;
					continue;
				} else {
					if(loadingRef.parentInfoRef.error) {
						[errErrors addObject:loadingRef.parentInfoRef.error];
					}
					[arrLoadingRef replaceObjectAtIndex:i withObject:[NSNull null]];
				}
			}
			return !processing;
		}
		 ignoringTouches:NO completeBlock:^ {
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^ {
				resultBlockDT(errErrors);
			}];
		}];
	}];
}

- (void)startSyncDTWithTicket:(int)ticket
				   managers:(NSArray *)managers
	syncExceptResourcesDoneBlockDT:(VLBlockVoid)syncExceptResourcesDoneBlockDT
				resultBlockDT:(void (^)(NSArray *outErrors))resultBlockDT {
	
	[[YTDatabaseManager shared] checkIsDatabaseThread];

	NSMutableArray *allErrors = [NSMutableArray array];
	
	NSMutableArray *resultsManagers = [NSMutableArray array];
	
	void (^__block blockStartSync)() = ^() {
		if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
			[allErrors addObject:[NSError makeCancel]];
			resultBlockDT(allErrors);
			return;
		}
		YTDbEntitiesManager *manr = [managers objectAtIndex:resultsManagers.count];
		[manr startSyncWithTicket:ticket resultBlock:^(NSMutableArray *errors)
		{
			[allErrors addObjectsFromArray:errors];
			[resultsManagers addObject:manr];
			if(resultsManagers.count == managers.count) {
				NSError *error = nil;
				if(allErrors.count)
					error = [allErrors objectAtIndex:0];
				if([[YTSyncManager shared] isSyncTicketValid:ticket]) {
					if(error) {
						self.processingState = EVLProcessingStateFailed;
						//[[YTStorageManager shared] deleteUnusedEntitiesFromDb];
						//[[YTStorageManager shared] updateConsistencyWithAllowModify:NO];
						[allErrors addObject:error];
						resultBlockDT(allErrors);
						return;
					}
					syncExceptResourcesDoneBlockDT();
					[self internalSyncResourcesWithWithTicketDT:ticket resultBlockDT:^(NSArray *errors) {
						[allErrors addObjectsFromArray:errors];
						resultBlockDT(allErrors);
					}];
				} else {
					[allErrors addObject:[NSError makeCancel]];
					resultBlockDT(allErrors);
				}
				Block_release(blockStartSync);
			} else
				blockStartSync();
		}];
	};
	
	blockStartSync = Block_copy(blockStartSync);
	blockStartSync();
}

- (void)dealloc {
	[super dealloc];
}

@end

