
#import "YTStacksDbManager.h"
#import "YTDatabaseManager.h"
#import "YTUsersDbManager.h"
#import "YTNotebooksDbManager.h"

static YTStacksDbManager *_shared;

@implementation YTStacksDbManager

+ (YTStacksDbManager *)shared {
	if(!_shared)
		_shared = [[YTStacksDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTStackInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (NSString *)apiOperationForDelete {
	return kYTUrlValueOperationDeleteStack;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationCreateStack;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationUpdateStack;
}

- (NSString *)apiOperationForList {
	return kYTUrlValueOperationListStacks;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTStackInfo *stack = ObjectCast(entity, YTStackInfo);
	[postValues addObject:[NSNumber numberWithLongLong:stack.stackId]];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	for(int i = 0; i < arrData.count; i++) {
		int64_t nId = [arrData int64ValueAtIndex:i defaultVal:0];
		if(nId) {
			YTStackInfo *stack = [[YTStackInfo new] autorelease];
			stack.stackId = nId;
			[arrEntities addObject:stack];
		}
	}
}

- (void)onBeforeSyncEntitiesAdded:(NSMutableArray *)entitiesAdded
				 entitiesModified:(NSMutableArray *)entitiesModified
				  entitiesDeleted:(NSMutableArray *)entitiesDeleted {
	[super onBeforeSyncEntitiesAdded:entitiesAdded entitiesModified:entitiesModified entitiesDeleted:entitiesDeleted];
	YTUsersDbManager *manrUsers = [YTUsersDbManager shared];
	YTUserInfo *userInfo = [manrUsers getUserInfo];
	if(userInfo.hasDemoData) {
		// Do not upload demo stacks and notebooks
		[entitiesAdded removeAllObjects];
		[entitiesModified removeAllObjects];
	}
}

- (void)onEntitiesListGotten {
	[super onEntitiesListGotten];
	YTUsersDbManager *manrUsers = [YTUsersDbManager shared];
	YTUserInfo *userInfo = [manrUsers getUserInfo];
	if(userInfo.hasDemoData) {
		// Move notebooks in demo stacks to real stack
		YTStackInfo *stackDemo = nil;
		YTStackInfo *stackNew = nil;
		NSArray *allStacks = [NSArray arrayWithArray:self.entities];
		for(YTStackInfo *stack in allStacks) {
			if(stack.stackId == kYTStackIdDemo) {
				stackDemo = stack;
			} else {
				if(!stackNew)
					stackNew = stack;
			}
		}
		if(stackDemo && stackNew) {
			NSArray *allNotebooks = [NSArray arrayWithArray:[YTNotebooksDbManager shared].entities];
			for(YTNotebookInfo *book in allNotebooks) {
				if(book.stackId == stackDemo.stackId) {
					book.stackId = stackNew.stackId;
				}
			}
		}
		if(stackDemo) {
			[self deleteEntityFromDb:stackDemo];
		}
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

