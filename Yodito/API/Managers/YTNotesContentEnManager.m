
#import "YTNotesContentEnManager.h"

static YTNotesContentEnManager *_shared;

@implementation YTNotesContentEnManager

+ (YTNotesContentEnManager *)shared {
	if(!_shared)
		_shared = [[YTNotesContentEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTNotesContentDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTNotesContentDbManager *manrDb = [YTNotesContentDbManager shared];
	int64_t curVersionDT = manrDb.version;
	if(_lastVersionDT != curVersionDT) {
		_lastVersionDT = curVersionDT;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[self modifyVersion];
	_updatingMT = NO;
}

- (void)readNoteContentForNoteWithGuid:(NSString *)noteGuid waitingUntilDone:(BOOL)wait resultBlock:(void(^)(YTNoteContentInfo *entity))resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTNotesContentDbManager *manrDb = [YTNotesContentDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:wait performBlockOnDT:^
	{
		YTNoteContentInfo *entity = [manrDb readContentInfoWithNoteGuid:noteGuid];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock(entity);
		}];
	}];
}

- (void)writeNoteContent:(YTNoteContentInfo *)noteContent resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTNotesContentDbManager *manrDb = [YTNotesContentDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		if(!noteContent.nId)
			[manrDb addEntity:noteContent];
		else
			[manrDb saveEntityToDb:noteContent];
		[manrDb clearEntities];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[self modifyVersion];
			resultBlock();
		}];
	}];
}

- (void)dealloc {
	[super dealloc];
}

@end

