
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTWallpapersManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	int _customWallpaperVersion;
	NSString *_wallpaperFilePath;
}

@property(nonatomic, readonly) int customWallpaperVersion;

+ (YTWallpapersManager *)shared;

- (BOOL)customWallpaperExists;
- (void)removeCustomWallpaper;
- (UIImage *)getCustomWallpaper;
- (UIImage *)getDefaultWallpaper;
- (void)startChooseWalpaper;

@end

