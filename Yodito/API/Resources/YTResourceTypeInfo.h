
#import <Foundation/Foundation.h>

typedef enum
{
	EYTResourceCategoryTypeNone = 0,
	EYTResourceCategoryTypeImage = 1,
	EYTResourceCategoryTypeVideo = 2,
	EYTResourceCategoryTypeAudio = 3,
	EYTResourceCategoryTypeRichText = 4,
	EYTResourceCategoryTypeSpreadSheet = 5,
	EYTResourceCategoryTypeSlideShow = 6,
	EYTResourceCategoryTypeTextDoc = 7,
	EYTResourceCategoryTypeOther = 8
}
EYTResourceCategoryType;


@interface YTResourceTypeInfo : NSObject {
@private
	EYTResourceCategoryType _categoryType;
	NSMutableArray *_filesExts;
	BOOL _downloadable;
	BOOL _storable;
	BOOL _viewable;
}

@property(nonatomic, readonly) EYTResourceCategoryType categoryType;
@property(nonatomic, readonly) NSArray *filesExts;
@property(nonatomic, readonly) BOOL downloadable;
@property(nonatomic, readonly) BOOL storable;
@property(nonatomic, readonly) BOOL viewable;

- (id)initWithCategoryType:(EYTResourceCategoryType)categoryType
				 filesExts:(NSArray *)filesExts
			  downloadable:(BOOL)downloadable
				  storable:(BOOL)storable
				  viewable:(BOOL)viewable;

+ (NSArray *)allTypes;
+ (YTResourceTypeInfo *)infoByCategoryType:(EYTResourceCategoryType)categoryType;
+ (YTResourceTypeInfo *)infoByFileExt:(NSString *)fileExt;
- (BOOL)containsFileExt:(NSString *)fileExt;
- (BOOL)isImage;
+ (BOOL)isWebDocViewable:(NSString *)sFileExt;
+ (BOOL)isOtherType:(NSString *)sFileExt;

@end

