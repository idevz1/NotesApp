
#import "YTStacksEnManager.h"

static YTStacksEnManager *_shared;

@implementation YTStacksEnManager

+ (YTStacksEnManager *)shared {
	if(!_shared)
		_shared = [[YTStacksEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_stacks = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_stacksST = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTStacksDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTStacksDbManager *manrDb = [YTStacksDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTStacksDbManager *manrDbStacks = [YTStacksDbManager shared];
	int64_t curVersionST = manrDbStacks.version;
	if(_lastVersionST != curVersionST) {
		[_stacksST removeAllObjects];
		for(YTStackInfo *entity in manrDbStacks.entities) {
			if(entity.deleted)
				continue;
			[_stacksST addObject:entity];
		}
		_lastVersionST = curVersionST;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_stacks removeAllObjects];
	[_stacks addObjectsFromArray:_stacksST];
	[self modifyVersion];
	_updatingMT = NO;
}

- (NSArray *)getStacks {
	return _stacks;
}

- (void)dealloc {
	[super dealloc];
}

@end

