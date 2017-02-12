
#import "YTNotesDisplayParams.h"

@implementation YTNotesDisplayParams

@synthesize notebookGuid = _notebookGuid;
@synthesize priorityType = _priorityType;
@synthesize tagName = _tagName;

- (id)init {
	self = [super init];
	if(self) {
		_notebookGuid = [@"" retain];
		_tagName = [@"" retain];
	}
	return self;
}

- (void)setNotebookGuid:(NSString *)notebookGuid {
	if(!notebookGuid)
		notebookGuid = @"";
	if(![_notebookGuid isEqual:notebookGuid]) {
		[_notebookGuid release];
		_notebookGuid = [notebookGuid copy];
		[self modifyVersion];
	}
}

- (void)setPriorityType:(EYTPriorityType)priorityType {
	if(_priorityType != priorityType) {
		_priorityType = priorityType;
		[self modifyVersion];
	}
}

- (void)setTagName:(NSString *)tagName {
	if(!tagName)
		tagName = @"";
	if(![_tagName isEqual:tagName]) {
		[_tagName release];
		_tagName = [tagName copy];
		[self modifyVersion];
	}
}

- (void)dealloc {
	[_notebookGuid release];
	[_tagName release];
	[super dealloc];
}

@end

