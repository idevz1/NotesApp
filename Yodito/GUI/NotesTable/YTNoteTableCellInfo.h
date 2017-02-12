
#import <Foundation/Foundation.h>
#import "../../API/Classes.h"

@interface YTNoteTableCellInfo : VLLogicObject <NSCopying> {
@private
	YTNoteInfo *_note;
	int64_t _lastNoteVersion;
	BOOL _showThumbnail;
	BOOL _showAttachmentIcon;
	YTResourceInfo *_resourceImage;
	NSString *_thumbnailHash;
	NSString *_title;
	BOOL _showDateLabels;
	NSString *_strTime;
	NSString *_strDay;
	NSString *_strWeekday;
}

@property(nonatomic, retain) YTNoteInfo *note;
@property(nonatomic, assign) int64_t lastNoteVersion;
@property(nonatomic, assign) BOOL showThumbnail;
@property(nonatomic, assign) BOOL showAttachmentIcon;
@property(nonatomic, retain) YTResourceInfo *resourceImage;
@property(nonatomic, retain) NSString *thumbnailHash;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, assign) BOOL showDateLabels;
@property(nonatomic, retain) NSString *strTime;
@property(nonatomic, retain) NSString *strDay;
@property(nonatomic, retain) NSString *strWeekday;

- (BOOL)isEqual:(id)object;
- (void)assignFrom:(YTNoteTableCellInfo *)other;
- (id)copyWithZone:(NSZone *)zone;

@end

