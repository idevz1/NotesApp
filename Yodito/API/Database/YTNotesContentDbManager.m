
#import "YTNotesContentDbManager.h"
#import "YTDatabaseManager.h"

static YTNotesContentDbManager *_shared;

@implementation YTNotesContentDbManager

+ (YTNotesContentDbManager *)shared {
	if(!_shared)
		_shared = [[YTNotesContentDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNoteContentInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
	}
	return self;
}

- (void)initialize {
	[super initialize];
	[self.database createIndexIfNotExistsInTableWithName:kYTDbTableNoteContent columnName:kYTJsonKeyNoteGUID indexName:@"index_note_guid"];
}

- (YTNoteContentInfo *)readContentInfoWithNoteGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	NSArray *entities = [self loadEntitiesFromDbWithWhereClause:[NSString stringWithFormat:@"%@ = '%@'", kYTJsonKeyNoteGUID, noteGuid]];
	if(entities.count)
		return [entities objectAtIndex:0];
	return nil;
}

- (NSString *)readContentWithNoteGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	YTNoteContentInfo *contentInfo = [self readContentInfoWithNoteGuid:noteGuid];
	return contentInfo ? contentInfo.content : @"";
}

- (void)writeNoteConentInfo:(YTNoteContentInfo *)noteContent {
	[self checkIsDatabaseThread];
	if(!noteContent.nId)
		[self addEntity:noteContent];
	else
		[self saveEntityToDb:noteContent];
	[self clearEntities]; // Keep clear
	[self modifyVersion];
}

- (void)writeConent:(NSString *)sContent toNoteWithGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	YTNoteContentInfo *existedNoteContentInfo = [self readContentInfoWithNoteGuid:noteGuid];
	if(existedNoteContentInfo) {
		existedNoteContentInfo.content = sContent;
		[self saveEntityToDb:existedNoteContentInfo];
		return;
	}
	YTNoteContentInfo *noteContentInfo = [[[YTNoteContentInfo alloc] init] autorelease];
	noteContentInfo.noteGuid = noteGuid;
	noteContentInfo.content = sContent;
	[self addEntity:noteContentInfo];
}

- (void)dealloc {
	[super dealloc];
}

@end

