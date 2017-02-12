
#import "YTNoteToTagInfo.h"

@implementation YTNoteToTagInfo

@synthesize noteGuid = _noteGuid;
@synthesize tagId = _tagId;

- (id)init {
	self = [super init];
	if(self) {
		_noteGuid = [@"" retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableNoteToTag;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"noteGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNoteGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"tagId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyTagId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setNoteGuid:(NSString *)noteGuid {
	if(!noteGuid)
		noteGuid = @"";
	if(![_noteGuid isEqual:noteGuid]) {
		[_noteGuid release];
		_noteGuid = [noteGuid copy];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setTagId:(int64_t)tagId {
	if(_tagId != tagId) {
		_tagId = tagId;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNoteToTagInfo *)other {
	[super assignDataFrom:other];
	self.noteGuid = other.noteGuid;
	self.tagId = other.tagId;
}

- (NSComparisonResult)compareIdentityTo:(YTNoteToTagInfo *)other {
	if(self.tagId != other.tagId)
		return (self.tagId < other.tagId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTNoteToTagInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.tagId != other.tagId)
		return (self.tagId < other.tagId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.noteGuid = [data stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	self.tagId = [data int64ValueForKey:kYTJsonKeyTagId defaultVal:self.tagId];
}

+ (NSString *)entityName {
	return @"NOTETAG";
}

- (void)dealloc {
	[_noteGuid release];
	[super dealloc];
}

@end

