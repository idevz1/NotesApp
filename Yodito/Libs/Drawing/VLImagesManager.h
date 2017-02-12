
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"

@interface VLImagesManager : VLCachedObjectsOwner
{
@private
	NSMutableDictionary *_mapImagesNamed;
}

+ (VLImagesManager*)shared;

- (UIImage*)imageNamed:(NSString*)name;
- (void)releaseImageNamed:(NSString*)name;

- (void)freeUnusedMemory;

@end
