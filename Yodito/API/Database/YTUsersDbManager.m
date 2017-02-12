
#import "YTUsersDbManager.h"
#import "YTDatabaseManager.h"

static YTUsersDbManager *_shared;

@implementation YTUsersDbManager

+ (YTUsersDbManager *)shared {
	if(!_shared)
		_shared = [[YTUsersDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTUserInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (YTUserInfo *)getUserInfo {
	[self checkIsDatabaseThread];
	NSArray *entities = self.entities;
	if(entities.count)
		return [entities objectAtIndex:0];
	return nil;
}

- (void)dealloc {
	[super dealloc];
}

@end

