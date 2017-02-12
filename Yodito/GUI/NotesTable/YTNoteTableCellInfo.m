
#import "YTNoteTableCellInfo.h"

@implementation YTNoteTableCellInfo

@synthesize note = _note;
@synthesize lastNoteVersion = _lastNoteVersion;
@synthesize showThumbnail = _showThumbnail;
@synthesize showAttachmentIcon = _showAttachmentIcon;
@synthesize resourceImage = _resourceImage;
@synthesize thumbnailHash = _thumbnailHash;
@synthesize title = _title;
@synthesize showDateLabels = _showDateLabels;
@synthesize strTime = _strTime;
@synthesize strDay = _strDay;
@synthesize strWeekday = _strWeekday;

- (BOOL)isEqual:(id)object {
	YTNoteTableCellInfo *other = ObjectCast(object, YTNoteTableCellInfo);
	if(!other)
		return NO;
	if(self.note != other.note)
		return NO;
	if(self.lastNoteVersion != other.lastNoteVersion)
		return NO;
	if(self.showThumbnail != other.showThumbnail)
		return NO;
	if(self.showAttachmentIcon != other.showAttachmentIcon)
		return NO;
	if(self.resourceImage != other.resourceImage)
		return NO;
	if((!!self.thumbnailHash != !!other.thumbnailHash) || (self.thumbnailHash && other.thumbnailHash && ![self.thumbnailHash isEqual:other.thumbnailHash]))
		return NO;
	if((!!self.title != !!other.title) || (self.title && other.title && ![self.title isEqual:other.title]))
		return NO;
	if(self.showDateLabels != other.showDateLabels)
		return NO;
	if((!!self.strTime != !!other.strTime) || (self.strTime && other.strTime && ![self.strTime isEqual:other.strTime]))
		return NO;
	if((!!self.strDay != !!other.strDay) || (self.strDay && other.strDay && ![self.strDay isEqual:other.strDay]))
		return NO;
	if((!!self.strWeekday != !!other.strWeekday) || (self.strWeekday && other.strWeekday && ![self.strWeekday isEqual:other.strWeekday]))
		return NO;
	return YES;
}

- (void)assignFrom:(YTNoteTableCellInfo *)other {
	self.note = other.note;
	self.lastNoteVersion = other.lastNoteVersion;
	self.showThumbnail = other.showThumbnail;
	self.showAttachmentIcon = other.showAttachmentIcon;
	self.resourceImage = other.resourceImage;
	self.thumbnailHash = other.thumbnailHash;
	self.title = other.title;
	self.showDateLabels = other.showDateLabels;
	self.strTime = other.strTime;
	self.strDay = other.strDay;
	self.strWeekday = other.strWeekday;
}

- (id)copyWithZone:(NSZone *)zone {
	YTNoteTableCellInfo *res = [[YTNoteTableCellInfo allocWithZone:zone] init];
	[res assignFrom:self];
	return res;
}

- (void)dealloc {
	[_note release];
	[_resourceImage release];
	[_thumbnailHash release];
	[_title release];
	[_strTime release];
	[_strDay release];
	[_strWeekday release];
	[super dealloc];
}

@end

