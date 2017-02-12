
#import <Foundation/Foundation.h>

@interface VLObjectStorageBase : NSObject
{
@private
	NSString *_key;
	int _version;
}

@property(nonatomic, readonly) NSString *key;
@property(nonatomic, readonly) int version;

- (id)initWithKey:(NSString*)key version:(int)version;

- (void)saveDataWithRootObject:(NSObject*)rootObject;
- (id)loadRootObject;

- (void)saveData:(NSData*)data;
- (NSData*)loadData;
- (void)removeData;

@end


