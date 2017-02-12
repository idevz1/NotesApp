
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTStacksEnManager : YTEntitiesManager {
@private
	NSMutableArray *_stacks;
	NSMutableArray *_stacksST;
	int64_t _lastVersionST;
	BOOL _updatingMT;
}

+ (YTStacksEnManager *)shared;
- (NSArray *)getStacks;

@end

