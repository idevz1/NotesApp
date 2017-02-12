
#import "YTNoteContentInfo.h"

@implementation YTNoteContentInfo

@synthesize noteGuid = _noteGuid;
@synthesize content = _content;

- (id)init {
	self = [super init];
	if(self) {
		_noteGuid = [@"" retain];
		_content = [@"" retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableNoteContent;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];

	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"noteGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNoteGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"content"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyContent
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
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

- (void)setContent:(NSString *)content {
	if(!content)
		content = @"";
	if(![_content isEqual:content]) {
		[_content release];
		_content = [content copy];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNoteContentInfo *)other {
	[super assignDataFrom:other];
	self.noteGuid = other.noteGuid;
	self.content = other.content;
}

- (NSComparisonResult)compareIdentityTo:(YTNoteContentInfo *)other {
	return [self.noteGuid compare:other.noteGuid];
}

- (NSComparisonResult)compareDataTo:(YTNoteContentInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	if([self.content compare:other.content])
		return [self.content compare:other.content];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.noteGuid = [data stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	self.content = [data stringValueForKey:kYTJsonKeyContent defaultVal:@""];
}

- (void)dealloc {
	[_noteGuid release];
	[_content release];
	[super dealloc];
}

@end

