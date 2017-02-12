
#import "YTEntitiesManager.h"

@implementation YTEntitiesManager

- (YTDbEntitiesManager *)dbEntitiesManager {
	return nil;
}

- (void)initialize {
	
}

- (void)initializeDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
}

- (void)updateOnDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
}

- (void)updateOnMT {
	
}

- (void)addEntities:(NSArray *)entities withAddingBlockDT:(VLBlockVoid)addingBlockDT withResultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		YTDbEntitiesManager *manrDb = [self dbEntitiesManager];
		for(YTEntityBase *entity in entities)
			[manrDb addEntity:entity];
		if(addingBlockDT)
			addingBlockDT();
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock();
		}];
	}];
}

- (void)checkIsMainThread {
	[[YTDatabaseManager shared] checkIsMainThread];
}

@end
