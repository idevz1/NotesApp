
#import <Foundation/Foundation.h>
#import "VLObjectStorageBase.h"

@interface VLObjectFileStorage : VLObjectStorageBase
{
@private
}

- (id)initWithKey:(NSString*)key version:(int)version;

- (void)saveData:(NSData*)data;
- (NSData*)loadData;
- (void)removeData;

+ (void)saveDataWithRootObject:(NSObject*)rootObject key:(NSString*)key version:(int)version;
+ (id)loadRootObjectWithKey:(NSString*)key version:(int)version;

@end
