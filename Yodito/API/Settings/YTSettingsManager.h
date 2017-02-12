
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTSettingsManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	BOOL _syncOnWiFiOnly;
	BOOL _autoAddNoteLocation;
	BOOL _saveTakenPhotosToCameraRoll;
}

@property(nonatomic, assign) BOOL syncOnWiFiOnly;
@property(nonatomic, assign) BOOL autoAddNoteLocation;
@property(nonatomic, assign) BOOL saveTakenPhotosToCameraRoll;

+ (YTSettingsManager *)shared;

@end
