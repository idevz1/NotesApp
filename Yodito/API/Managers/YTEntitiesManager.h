
#import <Foundation/Foundation.h>
#import "../Database/Classes.h"
#import "../Notes/Classes.h"

#define kYTEntitiesManager_InitialCollectionCapacity 100

@interface YTEntitiesManager : VLLogicObject {
@private
}

- (YTDbEntitiesManager *)dbEntitiesManager;
- (void)initialize;
- (void)initializeDT;
- (void)updateOnDT;
- (void)updateOnMT;
- (void)addEntities:(NSArray *)entities withAddingBlockDT:(VLBlockVoid)addingBlockDT withResultBlock:(VLBlockVoid)resultBlock;
- (void)checkIsMainThread;

@end

