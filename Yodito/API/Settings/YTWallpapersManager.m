
#import "YTWallpapersManager.h"
#import "YTImagePickerController.h"
#import "YTSettingsManager.h"

#define kSavedDataKey @"YTWallpapersManager"
#define kSavedDataVersion (kYTManagersBaseVersion + 3)

static YTWallpapersManager *_shared = nil;

@implementation YTWallpapersManager

@synthesize customWallpaperVersion = _customWallpaperVersion;

+ (YTWallpapersManager *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[YTWallpapersManager alloc] init] autorelease];
		[_shared retain];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		//NSString *dirHome = NSHomeDirectory();
		//NSString *dirDocs = @"Documents";
		//NSString *pathDirDocs = [dirHome stringByAppendingPathComponent:dirDocs];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *pathDirDocs = [paths objectAtIndex:0];
		_wallpaperFilePath = [[pathDirDocs stringByAppendingPathComponent:@"wallpaper.jpg"] retain];
		
		if(aDecoder) {
			if(![aDecoder containsValueForKey:@"_customWallpaperVersion"]) {
				[[VLFileManager shared] deleteFileOrDir:_wallpaperFilePath error:nil];
			}
			_customWallpaperVersion = [aDecoder decodeIntForKey:@"_customWallpaperVersion"];
		}
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt:_customWallpaperVersion forKey:@"_customWallpaperVersion"];
}

- (void)onVersionChanged:(id)sender {
	if(_savedDataVersion != self.version) {
		VLLogEvent(@"Saving");
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}
}

- (BOOL)customWallpaperExists {
	return [[VLFileManager shared] fileExists:_wallpaperFilePath];
}

- (void)removeCustomWallpaper {
	if([self customWallpaperExists]) {
		[[VLFileManager shared] deleteFileOrDir:_wallpaperFilePath error:nil];
		_customWallpaperVersion++;
		[self modifyVersion];
	}
}

- (UIImage *)getCustomWallpaper {
	if(![self customWallpaperExists])
		return nil;
	UIImage *image = [UIImage imageWithContentsOfFile:_wallpaperFilePath];
	return image;
}

- (UIImage *)getDefaultWallpaper {
	UIImage *image = [UIImage imageNamed:@"ios-7-wallpaper-galaxy.jpg"];
	return image;
}

- (void)startChooseWalpaper {
	NSString *actionTake = NSLocalizedString(@"Take Photo", nil);
	NSString *actionChoose = NSLocalizedString(@"Choose From Library", nil);
	NSString *actionRemove = NSLocalizedString(@"Remove {Button}", nil);
	NSString *actionCancel = NSLocalizedString(@"Cancel {Button}", nil);
	VLActionSheet *actionSheet = [[[VLActionSheet alloc] init] autorelease];
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[actionSheet addButtonWithTitle:actionTake];
	[actionSheet addButtonWithTitle:actionChoose];
	if([self customWallpaperExists]) {
		[actionSheet addButtonWithTitle:actionRemove];
		actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
	}
	[actionSheet addButtonWithTitle:actionCancel];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	[actionSheet showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
		if([NSString isEmpty:btnTitle])
			return;
		if([btnTitle isEqual:actionTake] || [btnTitle isEqual:actionChoose]) {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"settings2"];
			[[VLMessageCenter shared] performBlock:^{
				YTImagePickerController *picker = [[[YTImagePickerController alloc] init] autorelease];
				[picker showWithSource:[btnTitle isEqual:actionTake] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum
						fromParentView:nil
								  rect:CGRectZero
						   orBarButton:nil
						   resultBlock:^(UIImage *image)
				{
					if(!image) {
						return;
					}
					image = [image limitSizeAndRotate:1136];
					NSData *data = UIImageJPEGRepresentation(image, kYTDefaultJpegImageQuality);
					if(!data) {
						//resultBlock(NO);
						return;
					}
					NSError *error = nil;
					if([[VLFileManager shared] fileExists:_wallpaperFilePath])
						[[VLFileManager shared] deleteFileOrDir:_wallpaperFilePath error:nil];
					[data writeToFile:_wallpaperFilePath options:NSDataWritingAtomic error:&error];
					if(error) {
						[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
						//resultBlock(NO);
						return;
					}
					_customWallpaperVersion++;
					[self modifyVersion];
					//resultBlock(YES);
				}];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
		} else if([btnTitle isEqual:actionRemove]) {
			[self removeCustomWallpaper];
		}
	}];
}

- (void)dealloc {
	[_wallpaperFilePath release];
	[super dealloc];
}

@end

