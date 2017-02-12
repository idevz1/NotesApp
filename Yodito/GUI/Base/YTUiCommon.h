
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"


typedef enum
{
	EYTUserActionTypeNone,
	EYTUserActionTypeDone,
	EYTUserActionTypeCancel,
	EYTUserActionTypeDelete,
	EYTUserActionTypeSave
}
EYTUserActionType;

#define kYTViewBackColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
#define kYTNoteCellBackColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]//[UIColor colorWithRed:0xF7/255.0 green:0xF7/255.0 blue:0xF7/255.0 alpha:1.0]
#define kYTNoteCellBackColorSel [UIColor colorWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:1.0]
#define kYTNoteTitleColor [UIColor colorWithRed:0x31/255.0 green:0x31/255.0 blue:0x31/255.0 alpha:1.0]
#define kYTNoteCapitalTitleColor [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kYTNoteContentColor [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]
#define kYTNoteDateColor [UIColor colorWithRed:0/255.0 green:119/255.0 blue:192/255.0 alpha:1.0]
#define kYTNoteImageLoadingBackColor [UIColor colorWithRed:0xD4/255.0 green:0xD4/255.0 blue:0xD4/255.0 alpha:1.0]
#define kYTTableSeparatorColor [UIColor colorWithWhite:252/255.0 alpha:1.0]
#define kYTNoteDateDayTextColorStarred [UIColor colorWithRed:0xEE/255.0 green:0x80/255.0 blue:0x33/255.0 alpha:1.0]

#define kYTHeaderBackColor [UIColor colorWithRed:94/255.0 green:125/255.0 blue:154/255.0 alpha:1.0]
#define kYTHeaderTitleColor [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]
#define kYTHeaderButtonTitleColor kYTHeaderTitleColor

#define kYTTableHeaderTextColor [UIColor colorWithRed:82/255.0 green:115/255.0 blue:147/255.0 alpha:1.0]
#define kYTLabelsBlueTextColor [UIColor colorWithRed:105/255.0 green:132/255.0 blue:161/255.0 alpha:1.0]

//#define kYTProgressIndicatorBackColor [UIColor colorWithRed:0x5A/255.0 green:0x5A/255.0 blue:0x5A/255.0 alpha:1.0]
#define kYTProgressIndicatorCenterBackColorTransparent [UIColor colorWithRed:0x5A/255.0 green:0x5A/255.0 blue:0x5A/255.0 alpha:0.80]
#define kYTProgressIndicatorBackColor [UIColor colorWithRed:0x5A/255.0 green:0x5A/255.0 blue:0x5A/255.0 alpha:0.25]

#define kYTSettingsViewBackColor [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]
#define kYTSettingsCellBackColor [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]

#define kYTPhotoThumbnailSizeToShow CGSizeMake(145*2, 100*2)
#define kYTUseMultiselectImagePicker YES//NO

#define kYTMaxPhotosToShowOnNoteView 5//5//4//999999

#define kYTNoteTitleLineSpacing 4.0
#define kYTNoteTitleLineSpacingCapitalLineAddition 6.0
#define kYTFirstNoteTextLineMaxChars 90

// Logging:
#define kYTLogEventsSetImage NO//YES
#define kYTLogEventsNoteCells NO//YES//NO
#define kYTLogEventsUpdateNotesTable NO//YES//NO

#define kYTShowSplashView NO//YES
#define kYTHideDefaultNotebook YES//NO
#define kYTLeftMenuSlideMaxOffsetRatio 0.885625
#define kYTShowEmptyNotesView NO//YES
#define kYTShowMainStatusView NO//YES
#define kYTShowNoteThumbnailActivityIndicator NO//YES
#define kYTHideStatusBarWhenShowPhotos NO//YES
#define kYTShowActivityOnBarWhenSearching NO//YES

// TODO: temporary had set to NO
#define kYTCashingPhotosThumbsView YES//NO



@interface YTUiCommon : NSObject

+ (NSString *)extractFirstNoteTextLine:(NSString *)noteText;

@end




