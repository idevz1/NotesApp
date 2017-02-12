
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@class YTResourceLoadingInfo;

@interface YTResourceLoadingReference : VLLogicObject {
@private
	NSString *_resourceHash;
	NSString *_resourceType;
	int _resourceCategoryId;
	YTResourceLoadingInfo *_parentInfoRef;
}

@property(nonatomic, readonly) NSString *resourceHash;
@property(nonatomic, readonly) NSString *resourceType;
@property(nonatomic, assign) int resourceCategoryId;
@property(nonatomic, assign) YTResourceLoadingInfo *parentInfoRef;

- (void)setResourceHash:(NSString *)resourceHash andType:(NSString *)resourceType categoryId:(int)resourceCategoryId;

@end
