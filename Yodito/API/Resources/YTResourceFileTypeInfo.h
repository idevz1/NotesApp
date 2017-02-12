
#import <Foundation/Foundation.h>

@interface YTResourceFileTypeInfo : NSObject {
@private
	NSString *_fileExt;
	UIImage *_icon;
}

@property(nonatomic, readonly) NSString *fileExt;
@property(nonatomic, readonly) UIImage *icon;

- (id)initWithFileExt:(NSString *)fileExt icon:(UIImage *)icon;
+ (YTResourceFileTypeInfo *)infoByFileExt:(NSString *)fileExt;
+ (UIImage *)imageByFileExt:(NSString *)fileExt;

@end

