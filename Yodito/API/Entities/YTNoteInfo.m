
#import "YTNoteInfo.h"
#import "YTPriorityTypeInfo.h"
#import "../Notes/Classes.h"

static int _debugIgnoreDetectTimestampChanges = 0;

@implementation YTNoteInfo

@synthesize noteGuid = _noteGuid;
@synthesize notebookId = _notebookId;
@synthesize notebookGuid = _notebookGuid;
@synthesize priorityId = _priorityId;
@synthesize createdAt = _createdAt;
@synthesize title = _title;
@synthesize contentLimited = _contentLimited;
@synthesize contentToUpdateFromIPhone = _contentToUpdateFromIPhone;
@synthesize characters = _characters;
@synthesize words = _words;
@synthesize createdDate = _createdDate;
@synthesize dueDate = _dueDate;
@synthesize endDate = _endDate;
@synthesize isValid = _isValid;
@synthesize hasAttachment = _hasAttachment;
@synthesize hasTag = _hasTag;
@synthesize hasLocation = _hasLocation;
@synthesize lastUpdateTS = _lastUpdateTS;
@synthesize mapNoteChanges = _mapNoteChanges;

- (id)init {
	self = [super init];
	if(self) {
		_noteGuid = [@"" retain];
		_notebookGuid = [@"" retain];
		_title = [@"" retain];
		_contentLimited = [@"" retain];
		_contentToUpdateFromIPhone = [@"" retain];
		_createdDate = [[VLDate date] retain];
		_dueDate = [[VLDate empty] retain];
		_endDate = [[VLDate empty] retain];
		_lastUpdateTS = [[VLDate date] retain];
		_mapNoteChanges = [NSMutableDictionary new];
		_isValid = YES;
		_priorityId = EYTPriorityTypeDefault;
	}
	return self;
}

+ (void)startDebugIgnoreDetectTimestampChanges {
	_debugIgnoreDetectTimestampChanges++;
}

+ (void)stopDebugIgnoreDetectTimestampChanges {
	if(_debugIgnoreDetectTimestampChanges > 0)
		_debugIgnoreDetectTimestampChanges--;
}

- (NSString *)dbTableName {
	return kYTDbTableNote;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"noteGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNoteGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"notebookId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyNotebookId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"notebookGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNotebookGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"priorityId"
																   attrType:EVLSqliteEntityAttrTypeInt
																  fieldName:kYTJsonKeyPriorityId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"createdAt"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyCreatedAt
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"title"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyTitle
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"contentLimited"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyContentLimited
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"contentToUpdateFromIPhone"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyContentToUpdateFromIPhone
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"characters"
																   attrType:EVLSqliteEntityAttrTypeInt
																  fieldName:kYTJsonKeyCharacters
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"words"
																   attrType:EVLSqliteEntityAttrTypeInt
																  fieldName:kYTJsonKeyWords
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"createdDate"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyCreatedDate
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"dueDate"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyDueDate
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"endDate"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyEndDate
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isValid"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsValid
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"hasAttachment"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyHasAttachment
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"hasTag"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyHasTag
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"hasLocation"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyHasLocation
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
}

- (void)setModified:(BOOL)modified {
	if(self.modified != modified && modified) {
		int idebug=0;
		idebug++;
	}
	[super setModified:modified];
}

- (void)setNoteGuid:(NSString *)noteGuid {
	if(!noteGuid)
		noteGuid = @"";
	if(![_noteGuid isEqual:noteGuid]) {
		[_noteGuid release];
		_noteGuid = [noteGuid copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setNotebookId:(int64_t)notebookId {
	if(_notebookId != notebookId) {
		_notebookId = notebookId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setNotebookGuid:(NSString *)notebookGuid {
	if(!notebookGuid)
		notebookGuid = @"";
	if(![_notebookGuid isEqual:notebookGuid]) {
		[_notebookGuid release];
		_notebookGuid = [notebookGuid copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setPriorityId:(int)priorityId {
	if(_priorityId != priorityId) {
		_priorityId = priorityId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setCreatedAt:(int64_t)createdAt {
	if(_createdAt != createdAt) {
		_createdAt = createdAt;
		self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setTitle:(NSString *)title {
	if(!title)
		title = @"";
	if(![_title isEqual:title]) {
		[_title release];
		_title = [title copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setContentLimited:(NSString *)contentLimited {
	if(!contentLimited)
		contentLimited = @"";
	if(![_contentLimited isEqual:contentLimited]) {
		[_contentLimited release];
		_contentLimited = [contentLimited copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setContentToUpdateFromIPhone:(NSString *)contentToUpdateFromIPhone {
	if(!contentToUpdateFromIPhone)
		contentToUpdateFromIPhone = @"";
	if(![_contentToUpdateFromIPhone isEqual:contentToUpdateFromIPhone]) {
		[_contentToUpdateFromIPhone release];
		_contentToUpdateFromIPhone = [contentToUpdateFromIPhone copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setCharacters:(int)characters {
	if(_characters != characters) {
		_characters = characters;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setWords:(int)words {
	if(_words != words) {
		_words = words;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setCreatedDate:(VLDate *)createdDate {
	if(!createdDate)
		createdDate = [VLDate empty];
	if(![_createdDate isEqual:createdDate]) {
		[_createdDate release];
		_createdDate = [createdDate retain];
		self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setDueDate:(VLDate *)dueDate {
	if(!dueDate)
		dueDate = [VLDate empty];
	if(![_dueDate isEqual:dueDate]) {
		[_dueDate release];
		_dueDate = [dueDate retain];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setEndDate:(VLDate *)endDate {
	if(!endDate)
		endDate = [VLDate empty];
	if(![_endDate isEqual:endDate]) {
		[_endDate release];
		_endDate = [endDate retain];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setIsValid:(BOOL)isValid {
	if(_isValid != isValid) {
		_isValid = isValid;
		self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setHasAttachment:(BOOL)hasAttachment {
	if(_hasAttachment != hasAttachment) {
		_hasAttachment = hasAttachment;
		self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setHasTag:(BOOL)hasTag {
	if(_hasTag != hasTag) {
		_hasTag = hasTag;
		self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setLastUpdateTS:(VLDate *)lastUpdateTS {
	if(!lastUpdateTS)
		lastUpdateTS = [VLDate empty];
	if(![_lastUpdateTS isEqual:lastUpdateTS]) {
		if(self.parent) {
			int idebug = 0;
			idebug++;
		}
		if(_debugIgnoreDetectTimestampChanges == 0) {
			int idebug = 0;
			idebug++;
		}
		[_lastUpdateTS release];
		_lastUpdateTS = [lastUpdateTS retain];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNoteInfo *)other {
	[super assignDataFrom:other];
	self.noteGuid = other.noteGuid;
	self.notebookId = other.notebookId;
	self.notebookGuid = other.notebookGuid;
	self.priorityId = other.priorityId;
	self.createdAt = other.createdAt;
	self.title = other.title;
	self.contentLimited = other.contentLimited;
	self.contentToUpdateFromIPhone = other.contentToUpdateFromIPhone;
	self.characters = other.characters;
	self.words = other.words;
	self.createdDate = other.createdDate;
	self.dueDate = other.dueDate;
	self.endDate = other.endDate;
	self.isValid = other.isValid;
	self.hasAttachment = other.hasAttachment;
	self.hasTag = other.hasTag;
	self.hasLocation = other.hasLocation;
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTNoteInfo *)other {
	return [self.noteGuid compare:other.noteGuid];
}

- (NSComparisonResult)compareDataTo:(YTNoteInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.notebookId != other.notebookId)
		return (self.notebookId < other.notebookId) ? -1 : 1;
	if(self.priorityId != other.priorityId)
		return (self.priorityId < other.priorityId) ? -1 : 1;
	if(self.createdAt != other.createdAt)
		return self.createdAt - other.createdAt;
	if(self.characters != other.characters)
		return self.characters - other.characters;
	if(self.words != other.words)
		return self.words - other.words;
	if(self.isValid != other.isValid)
		return (int)self.isValid - (int)other.isValid;
	if(self.hasAttachment != other.hasAttachment)
		return (int)self.hasAttachment - (int)other.hasAttachment;
	if(self.hasTag != other.hasTag)
		return (int)self.hasTag - (int)other.hasTag;
	if(self.hasLocation != other.hasLocation)
		return (int)self.hasLocation - (int)other.hasLocation;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	if([self.notebookGuid compare:other.notebookGuid])
		return [self.notebookGuid compare:other.notebookGuid];
	if([self.title compare:other.title])
		return [self.title compare:other.title];
	if([self.contentLimited compare:other.contentLimited])
		return [self.contentLimited compare:other.contentLimited];
	if([self.contentToUpdateFromIPhone compare:other.contentToUpdateFromIPhone])
		return [self.contentToUpdateFromIPhone compare:other.contentToUpdateFromIPhone];
	if([self.createdDate compare:other.createdDate])
		return [self.createdDate compare:other.createdDate];
	if([self.dueDate compare:other.dueDate])
		return [self.dueDate compare:other.dueDate];
	if([self.endDate compare:other.endDate])
		return [self.endDate compare:other.endDate];
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	[YTNoteInfo startDebugIgnoreDetectTimestampChanges];
	self.noteGuid = [data stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	self.notebookId = [data int64ValueForKey:kYTJsonKeyNotebookId defaultVal:self.notebookId];
	self.notebookGuid = [data stringValueForKey:kYTJsonKeyNotebookGUID defaultVal:@""];
	self.priorityId = [data intValueForKey:kYTJsonKeyPriorityId defaultVal:0];
	self.createdAt = [data int64ValueForKey:kYTJsonKeyCreatedAt defaultVal:0];
	NSString *sTitle = [data stringValueForKey:kYTJsonKeyTitle defaultVal:@""];
	if(urlDecode)
		sTitle = [[YTNoteHtmlParser shared] urlDecode:sTitle];
	self.title = sTitle;
	//self.content = [data stringValueForKey:kYTJsonKeyContent defaultVal:@""];
	self.contentLimited = [data stringValueForKey:kYTJsonKeyContentLimited defaultVal:@""];
	self.contentToUpdateFromIPhone = [data stringValueForKey:kYTJsonKeyContentToUpdateFromIPhone defaultVal:self.contentToUpdateFromIPhone];
	self.characters = [data intValueForKey:kYTJsonKeyCharacters defaultVal:0];
	self.words = [data intValueForKey:kYTJsonKeyWords defaultVal:0];
	NSString *sCreatedDate = [data stringValueForKey:kYTJsonKeyCreatedDate defaultVal:@""];
	self.createdDate = [VLDate yoditoDateWithString:sCreatedDate];
	NSString *sDueDate = [data stringValueForKey:kYTJsonKeyDueDate defaultVal:@""];
	self.dueDate = [VLDate yoditoDateWithString:sDueDate];
	NSString *sEndDate = [data stringValueForKey:kYTJsonKeyEndDate defaultVal:@""];
	self.endDate = [VLDate yoditoDateWithString:sEndDate];
	self.isValid = [data yoditoBoolValueForKey:kYTJsonKeyIsValid defaultVal:NO];
	self.hasAttachment = [data yoditoBoolValueForKey:kYTJsonKeyHasAttachment defaultVal:NO];
	self.hasTag = [data yoditoBoolValueForKey:kYTJsonKeyHasTag defaultVal:NO];
	self.hasLocation = [data yoditoBoolValueForKey:kYTJsonKeyHasLocation defaultVal:NO];
	
	NSString *sNoteChanges = [data stringValueForKey:kYTJsonKeyNoteChanges defaultVal:@""];
	id valDictNoteChanges = ![NSString isEmpty:sNoteChanges] ? [sNoteChanges JSONValue] : nil;
	NSDictionary *dictNoteChanges = ObjectCast(valDictNoteChanges, NSDictionary);
	if(!dictNoteChanges)
		dictNoteChanges = [NSDictionary dictionary];
	NSMutableDictionary *mapNoteChanges = [NSMutableDictionary dictionary];
	static NSMutableArray *_arrKeys;
	if(!_arrKeys) {
		_arrKeys = [[NSMutableArray alloc] init];
		[_arrKeys addObject:kYTJsonKeyCheckList];
		[_arrKeys addObject:kYTJsonKeyAttachment];
		[_arrKeys addObject:kYTJsonKeyReminder];
		[_arrKeys addObject:kYTJsonKeyTag];
		[_arrKeys addObject:kYTJsonKeyURL];
		[_arrKeys addObject:kYTJsonKeyRelation];
		[_arrKeys addObject:kYTJsonKeyLocation];
		[_arrKeys addObject:kYTJsonKeyRepeat];
		[_arrKeys addObject:kYTJsonKeyTitle];
		[_arrKeys addObject:kYTJsonKeyContent];
	}
	for(NSString *key in _arrKeys) {
		NSString *sDate = [dictNoteChanges stringValueForKey:key defaultVal:nil];
		if(![NSString isEmpty:sDate]) {
			VLDate *date = [VLDate yoditoDateWithString:sDate];
			if(date)
				[mapNoteChanges setObject:date forKey:key];
		}
	}
	if(![_mapNoteChanges isEqualToDictionary:mapNoteChanges]) {
		[_mapNoteChanges removeAllObjects];
		[_mapNoteChanges addEntriesFromDictionary:mapNoteChanges];
		[self modifyVersion];
	}
	
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
	[YTNoteInfo stopDebugIgnoreDetectTimestampChanges];
}

- (BOOL)hasEndDate {
	return ![VLDate isEmpty:self.endDate];
}

- (void)getDueDate:(VLDateNoTime **)ppDueDateNoTime dueTime:(VLTime **)ppDueTime endDate:(VLDate **)ppEndDate {
	if(ppDueDateNoTime)
		*ppDueDateNoTime = nil;
	if(ppDueTime)
		*ppDueTime = nil;
	if(ppEndDate)
		*ppEndDate = nil;
	VLDateNoTime *dueDateNoTime = nil;
	VLTime *dueTime = nil;
	VLDate *endDate = nil;
	if([VLDate isEmpty:self.endDate]) {
		// Only due Date
		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
		dueDateNoTime = [[[VLDateNoTime alloc] initWithYear:[self.dueDate gregorianYearWithTimezone:tz]
						month:[self.dueDate gregorianMonthWithTimezone:tz] day:[self.dueDate gregorianDayWithTimezone:tz]] autorelease];
	} else {
		// Due Date and Time
		NSTimeZone *tz = [NSTimeZone defaultTimeZone];
		dueDateNoTime = [[[VLDateNoTime alloc] initWithDate:self.dueDate timezone:tz] autorelease];
		dueTime = [[[VLTime alloc] initWithDate:self.dueDate timezone:tz] autorelease];
		endDate = self.endDate;
	}
	if(ppDueDateNoTime)
		*ppDueDateNoTime = dueDateNoTime;
	if(ppDueTime)
		*ppDueTime = dueTime;
	if(ppEndDate)
		*ppEndDate = endDate;
}

- (void)setDueDate:(VLDateNoTime *)dueDateNoTime dueTime:(VLTime *)dueTime endDate:(VLDate *)endDate {
	if(![VLDate isEmpty:endDate]) {
		NSTimeZone *tz = [NSTimeZone defaultTimeZone];
		VLDate *dueDate = [[[VLDate alloc] initWithYear:dueDateNoTime.year month:dueDateNoTime.month day:dueDateNoTime.day
								hours:dueTime.hours minutes:dueTime.minutes seconds:dueTime.seconds milliseconds:0 timeZone:tz] autorelease];
		self.dueDate = dueDate;
		self.endDate = endDate;
	} else {
		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
		VLDate *dueDate = [[[VLDate alloc] initWithYear:dueDateNoTime.year month:dueDateNoTime.month day:dueDateNoTime.day
								hours:0 minutes:0 seconds:0 milliseconds:0 timeZone:tz] autorelease];
		self.dueDate = dueDate;
		self.endDate = endDate;
	}
}

- (NSString *)titlePlaceholder {
	return NSLocalizedString(@"Untitled Note", nil);
}

+ (NSString *)getContentLimitedWithContent:(NSString *)content wordsCount:(int *)pWordsCount charsCount:(int *)pCharsCount {
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	
	NSString *contentLimited = content;
	NSString *contentLimited1 = [[YTNoteHtmlParser shared] correctHtmlText:contentLimited];
	//NSString *contentLimited2 = [[YTNoteHtmlParser shared] plainTextFromHtml:contentLimited1];
	NSString *contentLimited2 = contentLimited1;
	NSString *contentLimitedFinal = contentLimited2;
	if(contentLimitedFinal.length > kYTNoteContentLimitedLimit)
		contentLimitedFinal = [contentLimitedFinal substringToIndex:kYTNoteContentLimitedLimit];
	
	if(pCharsCount)
		*pCharsCount = (int)content.length;
	
	if(pWordsCount) {//countWords) {
		__block NSUInteger wordCount = 0;
		[content enumerateSubstringsInRange:NSMakeRange(0, content.length)
									options:NSStringEnumerationByWords
								 usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
									 wordCount++;
								 }];
		*pWordsCount = (int)wordCount;
	}
	
	[contentLimitedFinal retain];
	
	[arpool drain];
	
	[contentLimitedFinal autorelease];
	
	return contentLimitedFinal;
}

- (void)dealloc {
	[_noteGuid release];
	[_notebookGuid release];
	[_title release];
	[_contentLimited release];
	[_contentToUpdateFromIPhone release];
	[_createdDate release];
	[_dueDate release];
	[_endDate release];
	[_lastUpdateTS release];
	[_mapNoteChanges release];
	[super dealloc];
}

@end



@implementation YTNoteInfoArgs

@synthesize note;

@end


/*
 
// {\"CheckList\":\"\",\"Attachment\":\"2012-11-12 18:03:07\",\"Reminder\":\"\",\"Tag\":\"\",\"URL\":\"\",\"Relation\":\"\",\"Location\":\"\"}
 
*/


