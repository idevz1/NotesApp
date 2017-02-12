
#import <Foundation/Foundation.h>
#import "VLLogicObject.h"

@interface VLCachedObjectsOwner : VLLogicObject
{
	
}

- (void)freeUnusedMemory;

@end



@interface VLCachedObjectHolder : VLCachedObjectsOwner
{
@private
	id _object;
}

@property(nonatomic,assign) id object;

- (void)releaseObject;
- (void)freeUnusedMemory;

@end



@interface VLCachedObjectsManager : NSObject
{
@private
	NSMutableArray *_objects;
	int64_t _objectsVersion;
}

+ (VLCachedObjectsManager*)shared;

- (void)registerObject:(VLCachedObjectsOwner*)obj;
- (void)unregisterObject:(VLCachedObjectsOwner*)obj;

- (void)freeUnusedMemory;

@end
