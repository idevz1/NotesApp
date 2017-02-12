
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"
#import "YTResourceLoadingReference.h"

@interface YTResourceLoadingInfo : VLLogicObject {
@private
	NSMutableArray *_references;
	//YTResourceInfo *_resource;
	NSString *_resourceHash;
	NSString *_resourceType;
	int _resourceCategoryId;
	NSError *_error;
	//UIImage *_image;
	NSString *_resourceFilePath;
}

@property(nonatomic, readonly) NSArray *references;
//@property(nonatomic, assign) YTResourceInfo *resource;
@property(nonatomic, assign) NSString *resourceHash;
@property(nonatomic, assign) NSString *resourceType;
@property(nonatomic, assign) int resourceCategoryId;
@property(nonatomic, assign) NSError *error;
//@property(nonatomic, assign) UIImage *image;
@property(nonatomic, assign) NSString *resourceFilePath;

- (void)addReference:(YTResourceLoadingReference *)reference;
- (void)removeReference:(YTResourceLoadingReference *)reference;
- (void)notifyReferences;

@end
