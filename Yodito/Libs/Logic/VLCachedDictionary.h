
#import <Foundation/Foundation.h>
#import "VLCachedObjectsManager.h"

@interface VLCachedDictionary : VLCachedObjectsOwner
{
	int _maxSize;
	NSMutableDictionary *_map;
	NSMutableArray *_keys;
}

@property(nonatomic,assign) int maxSize;

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)pushToFront:(id)aKey;
- (void)clear;
- (void)freeUnusedMemory;

@end
