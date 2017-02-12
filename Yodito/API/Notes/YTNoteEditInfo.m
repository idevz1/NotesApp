
#import "YTNoteEditInfo.h"
#import "../Managers/Classes.h"

@implementation YTNoteEditInfo

@synthesize isNewNote = _isNewNote;
@synthesize noteLast = _noteLast;
@synthesize noteContentLast = _noteContentLast;
@synthesize resourcesLast = _resourcesLast;
@synthesize tagsLast = _tagsLast;
@synthesize locationLast = _locationLast;
@synthesize noteNew = _noteNew;
@synthesize noteContentNew = _noteContentNew;
@synthesize resourcesNew = _resourcesNew;
@synthesize tagsNew = _tagsNew;
@synthesize locationNew = _locationNew;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)initializeWithNoteOriginal:(YTNoteInfo *)noteOriginal isNewNote:(BOOL)isNewNote resultBlock:(VLBlockVoid)resultBlock {
	
	_isNewNote = isNewNote;
	_noteLast = [noteOriginal retain];
	_noteNew = [[YTNoteInfo alloc] init];
	[_noteNew assignDataFrom:_noteLast];
	_noteNew.modified = NO;
	
	[_noteLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	[_noteNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	
	[[YTNotesContentEnManager shared] readNoteContentForNoteWithGuid:_noteLast.noteGuid waitingUntilDone:NO resultBlock:^(YTNoteContentInfo *entity)
	{
		if(entity) {
			_noteContentLast = [entity retain];
		} else {
			_noteContentLast = [[YTNoteContentInfo alloc] init];
			_noteContentLast.noteGuid = _noteLast.noteGuid;
		}
		
		_noteContentNew = [[YTNoteContentInfo alloc] init];
		[_noteContentNew assignDataFrom:_noteContentLast];
		_noteContentNew.modified = NO;
		
		[_noteContentLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		[_noteContentNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		
		_resourcesLast = [[NSMutableArray alloc] initWithArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:_noteContentLast.noteGuid].allValues];
		_tagsLast = [[NSMutableArray alloc] initWithArray:[[YTTagsEnManager shared] getTagsByNoteGuid:_noteLast.noteGuid].allValues];
		_locationLast = [[YTLocationsEnManager shared] getLocationByNoteGuid:_noteLast.noteGuid];
		if(_locationLast) {
			[_locationLast retain];
			[_locationLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		_resourcesNew = [[NSMutableArray alloc] init];
		for(YTResourceInfo *entLast in _resourcesLast) {
			[entLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
			YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
			[entNew assignDataFrom:entLast];
			entNew.modified = NO;
			[_resourcesNew addObject:entNew];
			[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		_tagsNew = [[NSMutableArray alloc] init];
		for(YTTagInfo *entLast in _tagsLast) {
			[entLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
			YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
			[entNew assignDataFrom:entLast];
			entNew.modified = NO;
			[_tagsNew addObject:entNew];
			[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		if(_locationLast) {
			_locationNew = [[YTLocationInfo alloc] init];
			//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			[_locationNew assignDataFrom:_locationLast];
			_locationNew.modified = NO;
			[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}

		resultBlock();
	}];
}

- (void)transformToNotNewNote {
	if(!_isNewNote)
		return;
	_isNewNote = NO;
	
	if(_noteLast) {
		[_noteLast.msgrVersionChanged removeObserver:self];
		[_noteLast release];
		_noteLast = nil;
	}
	_noteLast = [_noteNew retain];
	[_noteNew release];
	_noteNew = nil;
	_noteNew = [[YTNoteInfo alloc] init];
	[_noteNew assignDataFrom:_noteLast];
	_noteNew.modified = NO;
	[_noteNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	
	if(_noteContentLast) {
		[_noteContentLast.msgrVersionChanged removeObserver:self];
		[_noteContentLast release];
		_noteContentLast = nil;
	}
	_noteContentLast = [_noteContentNew retain];
	[_noteContentNew release];
	_noteContentNew = nil;
	
	_noteContentNew = [[YTNoteContentInfo alloc] init];
	[_noteContentNew assignDataFrom:_noteContentLast];
	_noteContentNew.modified = NO;
	[_noteContentNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	
	if(_locationLast) {
		[_locationLast.msgrVersionChanged removeObserver:self];
		[_locationLast release];
		_locationLast = nil;
	}
	if(_locationNew) {
		_locationLast = [_locationNew retain];
		[_locationNew release];
		_locationNew = nil;
	}
	if(_locationLast) {
		_locationNew = [[YTLocationInfo alloc] init];
		//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
		[_locationNew assignDataFrom:_locationLast];
		_locationNew.modified = NO;
		[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
	
	while(_resourcesLast.count) {
		YTResourceInfo *entity = [_resourcesLast lastObject];
		[entity.msgrVersionChanged removeObserver:self];
		[_resourcesLast removeLastObject];
	}
	[_resourcesLast addObjectsFromArray:_resourcesNew];
	[_resourcesNew removeAllObjects];
	for(YTResourceInfo *entLast in _resourcesLast) {
		YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
		[entNew assignDataFrom:entLast];
		entNew.modified = NO;
		[_resourcesNew addObject:entNew];
		[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
	
	while(_tagsLast.count) {
		YTTagInfo *entity = [_tagsLast lastObject];
		[entity.msgrVersionChanged removeObserver:self];
		[_tagsLast removeLastObject];
	}
	[_tagsLast addObjectsFromArray:_tagsNew];
	[_tagsNew removeAllObjects];
	for(YTTagInfo *entLast in _tagsLast) {
		YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
		[entNew assignDataFrom:entLast];
		entNew.modified = NO;
		[_tagsNew addObject:entNew];
		[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
}

- (void)applyChanges {
	if(_isNewNote) {
		[self transformToNotNewNote];
		return;
	}
	
	if([_noteLast compareDataTo:_noteNew] != 0) {
		//[_noteLast assignDataFrom:_noteNew];
		VLLoggerWarn(@"%@", @"[_noteLast compareDataTo:_noteNew] != 0. Should have been applied in YTEntitiesManagersLister:applyModifiedNote");
		//[self modifyVersion];
	}
	
	if([_noteContentLast compareDataTo:_noteContentNew] != 0) {
		//[_noteContentLast assignDataFrom:_noteContentNew];
		VLLoggerWarn(@"%@", @"[_noteContentLast compareDataTo:_noteContentNew]. Should have been applied in YTEntitiesManagersLister:applyModifiedNote");
		//[self modifyVersion];
	}
	
	BOOL locationChanged = NO;
	if(!!_locationLast != !!_locationNew)
		locationChanged = YES;
	else if (_locationLast && _locationNew && [_locationLast compareDataTo:_locationNew] != 0)
		locationChanged = YES;
	if(locationChanged) {
		if(_locationLast) {
			[_locationLast.msgrVersionChanged removeObserver:self];
			[_locationLast release];
			_locationLast = nil;
		}
		if(_locationNew) {
			_locationLast = [_locationNew retain];
			[_locationNew release];
			_locationNew = nil;
		}
		if(_locationLast) {
			_locationNew = [[YTLocationInfo alloc] init];
			//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			[_locationNew assignDataFrom:_locationLast];
			_locationNew.modified = NO;
			[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		_noteNew.hasLocation = (_locationNew != nil);
		[self modifyVersion];
	}
	
	BOOL resourcesChanged = NO;
	if(_resourcesLast.count != _resourcesNew.count)
		resourcesChanged = YES;
	else {
		for(int i = 0; i < _resourcesLast.count; i++) {
			YTResourceInfo *resLast = [_resourcesLast objectAtIndex:i];
			YTResourceInfo *resNew = [_resourcesNew objectAtIndex:i];
			if([resLast compareDataTo:resNew] != 0) {
				resourcesChanged = YES;
				break;
			}
		}
	}
	if(resourcesChanged) {
		for(YTResourceInfo *entity in [NSArray arrayWithArray:_resourcesLast]) {
			if(entity.deleted) {
				[entity.msgrVersionChanged removeObserver:self];
				[_resourcesLast removeObject:entity];
			}
		}
		for(YTResourceInfo *entity in [NSArray arrayWithArray:_resourcesNew]) {
			if([entity isInDb]) {
				[_resourcesLast addObject:entity];
				YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
				[entNew assignDataFrom:entity];
				entNew.modified = NO;
				[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
				[_resourcesNew replaceObjectAtIndex:[_resourcesNew indexOfObject:entity] withObject:entNew];
			}
		}
		[self modifyVersion];
	}
	
	BOOL tagsChanged = NO;
	if(_tagsLast.count != _tagsNew.count)
		tagsChanged = YES;
	else {
		for(int i = 0; i < _tagsLast.count; i++) {
			YTTagInfo *tagLast = [_tagsLast objectAtIndex:i];
			YTTagInfo *tagNew = [_tagsNew objectAtIndex:i];
			if([tagLast compareDataTo:tagNew] != 0) {
				tagsChanged = YES;
				break;
			}
		}
	}
	if(tagsChanged) {
		for(YTTagInfo *entityLast in [NSArray arrayWithArray:_tagsLast]) {
			if(entityLast.deleted) {
				[entityLast.msgrVersionChanged removeObserver:self];
				[_tagsLast removeObject:entityLast];
				continue;
			}
			YTTagInfo *entityNew = nil;
			for(YTTagInfo *entity in _tagsNew) {
				if(entity.tagId == entityLast.tagId) {
					entityNew = entity;
					break;
				}
			}
			if(!entityNew) {
				[entityLast.msgrVersionChanged removeObserver:self];
				[_tagsLast removeObject:entityLast];
				continue;
			}
		}
		for(YTTagInfo *entity in [NSArray arrayWithArray:_tagsNew]) {
			if([entity isInDb]) {
				[_tagsLast addObject:entity];
				YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
				[entNew assignDataFrom:entity];
				entNew.modified = NO;
				[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
				[_tagsNew replaceObjectAtIndex:[_tagsNew indexOfObject:entity] withObject:entNew];
			}
		}
		[self modifyVersion];
	}
}

- (void)onChildVersionChanged:(id)sender {
	[self modifyVersion];
}

- (void)addTagNew:(YTTagInfo *)tagNew {
	if([_tagsNew containsObject:tagNew])
		return;
	[_tagsNew addObject:tagNew];
	[tagNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	[self modifyVersion];
}

- (void)removeTagNew:(YTTagInfo *)tagNew {
	if(![_tagsNew containsObject:tagNew])
		return;
	[tagNew.msgrVersionChanged removeObserver:self];
	[_tagsNew removeObject:tagNew];
	[self modifyVersion];
}

- (void)replaceTagNew:(YTTagInfo *)tagNewLast withTag:(YTTagInfo *)tagNewNew {
	if(tagNewLast == tagNewNew)
		return;
	if(![_tagsNew containsObject:tagNewLast])
		return;
	[tagNewLast.msgrVersionChanged removeObserver:self];
	[_tagsNew removeObject:tagNewLast];
	[_tagsNew addObject:tagNewNew];
	[tagNewNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	[self modifyVersion];
}

- (void)moveTagLastToEnd:(YTTagInfo *)tagLast {
	if(![_tagsLast containsObject:tagLast])
		return;
	if(_tagsLast.lastObject == tagLast)
		return;
	[[tagLast retain] autorelease];
	[_tagsLast removeObject:tagLast];
	[_tagsLast addObject:tagLast];
	[self modifyVersion];
}

- (void)addResourceNew:(YTResourceInfo *)resNew {
	if([_resourcesNew containsObject:resNew])
		return;
	[_resourcesNew addObject:resNew];
	[resNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	[self modifyVersion];
}

- (void)removeResourceNew:(YTResourceInfo *)resNew {
	if(![_resourcesNew containsObject:resNew])
		return;
	[resNew.msgrVersionChanged removeObserver:self];
	if(resNew.isImage && !resNew.isThumbnail) {
		YTResourceInfo *resThumbNew = [[YTResourcesEnManager shared] thumbnailForImage:resNew inResources:_resourcesNew];
		if(resThumbNew)
			[self removeResourceNew:resThumbNew];
	}
	[_resourcesNew removeObject:resNew];
	[self modifyVersion];
}

- (void)setLocationNew:(YTLocationInfo *)locationNew {
	if(_locationNew != locationNew) {
		if(_locationNew) {
			[_locationNew.msgrVersionChanged removeObserver:self];
			[_locationNew release];
		}
		_locationNew = [locationNew retain];
		if(_locationNew) {
			[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		[self modifyVersion];
	}
}

- (void)onEntityVersionChanged:(id)sender {
	[self modifyVersion];
}

- (void)dealloc {
	if(_noteLast) {
		[_noteLast.msgrVersionChanged removeObserver:self];
		[_noteLast release];
	}
	if(_noteContentLast) {
		[_noteContentLast.msgrVersionChanged removeObserver:self];
		[_noteContentLast release];
	}
	for(YTEntityBase *ent in _tagsLast)
		[ent.msgrVersionChanged removeObserver:self];
	[_tagsLast release];
	for(YTEntityBase *ent in _resourcesLast)
		[ent.msgrVersionChanged removeObserver:self];
	[_resourcesLast release];
	if(_locationLast) {
		[_locationLast.msgrVersionChanged removeObserver:self];
		[_locationLast release];
	}
	if(_noteNew) {
		[_noteNew.msgrVersionChanged removeObserver:self];
		[_noteNew release];
	}
	if(_noteContentNew) {
		[_noteContentNew.msgrVersionChanged removeObserver:self];
		[_noteContentNew release];
	}
	for(YTEntityBase *ent in _tagsNew)
		[ent.msgrVersionChanged removeObserver:self];
	[_tagsNew release];
	for(YTEntityBase *ent in _resourcesNew)
		[ent.msgrVersionChanged removeObserver:self];
	[_resourcesNew release];
	if(_locationNew) {
		[_locationNew.msgrVersionChanged removeObserver:self];
		[_locationNew release];
	}
	[super dealloc];
}

@end







