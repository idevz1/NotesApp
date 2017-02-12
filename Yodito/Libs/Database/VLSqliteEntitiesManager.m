
#import "VLSqliteEntitiesManager.h"

@implementation VLSqliteEntitiesManager

@synthesize entityClass = _entityClass;
@synthesize entities = _entities;
@dynamic entitiesNotDeleted;
@synthesize database = _db;

- (id)initWithEntityClass:(Class)entityClass database:(VLSqliteDatabase *)database {
	self = [super init];
	if(self) {
		_entityClass = entityClass;
		_entities = [[NSMutableArray alloc] init];
		_dummyEntity = [[_entityClass alloc] init];
		_db = [database retain];
		_dlgtEntityMarkedDeleted = [[VLDelegate alloc] init];
		_dlgtEntityMarkedDeleted.owner = self;
		_cacheEntitiesNotDeleted = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)clearEntities {
	if(_entities.count) {
		for(VLSqliteEntity *entity in _entities)
			[entity resetParent:self];
		[_entities removeAllObjects];
		[self modifyVersion];
	}
}

- (void)deleteAllEntitiesFromDb {
	if(_entities.count) {
		for(VLSqliteEntity *entity in [NSArray arrayWithArray:_entities]) {
			[self deleteEntityFromDb:entity];
		}
		[_entities removeAllObjects];
		[self modifyVersion];
	}
}

- (NSArray *)loadEntitiesFromDbWithWhereClause:(NSString *)whereClause {
	NSString *dbTableName = [_dummyEntity dbTableName];
	NSMutableArray *result = [NSMutableArray array];
	[_db readRowsInTable:dbTableName whereClause:whereClause rowReadBlock:^(NSDictionary *dictValues) {
		VLSqliteEntity *entity = [[[_entityClass alloc] init] autorelease];
		[entity loadFromData:dictValues];
		entity.modified = [dictValues boolValueForKey:kVLSqliteFieldKeyModified defaultVal:entity.modified];
		entity.needSave = NO;
		[result addObject:entity];
	}];
	for(VLSqliteEntity *entity in result)
		entity.parent = self;
	return result;
}

- (void)loadEntitiesFromDb {
	[self clearEntities];
	NSArray *entities = [self loadEntitiesFromDbWithWhereClause:nil];
	[_entities addObjectsFromArray:entities];
	if(_entities.count)
		[self modifyVersion];
}

- (void)addEntity:(VLSqliteEntity *)entity {
	if([self containsEntityReference:entity]) {
		VLLogWarning(@"Already contains this entity");
		return;
	}
	entity.parent = self;
	entity.added = YES;
	entity.deleted = entity.modified = NO;
	entity.needSave = YES;
	entity.nId = 0;
	[_entities addObject:entity];
	[self saveEntityToDb:entity];
	[self modifyVersion];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	if(![self containsEntityReference:entity]) {
		VLLogError(@"Does not contain this entity")
		return;
	}
	[_db deleteRowWithId:entity.nId colIdName:kVLSqliteFieldKeyId fromTableWithName:[_dummyEntity dbTableName]];
	[entity resetParent:self];
	[_entities removeObject:entity];
	[self modifyVersion];
}

- (void)saveEntityToDb:(VLSqliteEntity *)entity {
	NSString *dbTableName = [_dummyEntity dbTableName];
	NSMutableDictionary *dictValues = [NSMutableDictionary dictionary];
	NSArray *fileds = [entity dbFields];
	for(VLSqliteEntityField *field in fileds) {
		NSString *fieldName = field.fieldName;
		if([fieldName isEqual:kVLSqliteFieldKeyId])
			continue;
		if(![entity respondsToSelector:field.selectorGet])
			continue;
		EVLSqliteEntityAttrType attrType = field.attrType;
		//EVLSqliteFieldTypeFlag fieldFlags = field.fieldFlags;
		id val = nil;
		if(attrType == EVLSqliteEntityAttrTypeString) {
			val = [entity performSelector:field.selectorGet];
		} else if(attrType == EVLSqliteEntityAttrTypeInt) {
			val = [NSNumber numberWithInt:(int)[entity performSelector:field.selectorGet]];
		} else if(attrType == EVLSqliteEntityAttrTypeInt64) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
							[[entity class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:entity];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			int64_t retVal = 0;
			[invocation getReturnValue:&retVal];
			val = [NSNumber numberWithLongLong:retVal];
		} else if(attrType == EVLSqliteEntityAttrTypeDouble) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
							[[entity class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:entity];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			double dblVal = 0;
			[invocation getReturnValue:&dblVal];
			val = [NSNumber numberWithDouble:dblVal];
		} else if(attrType == EVLSqliteEntityAttrTypeFloat) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
										[[entity class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:entity];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			float fltVal = 0;
			[invocation getReturnValue:&fltVal];
			val = [NSNumber numberWithFloat:fltVal];
		} else if(attrType == EVLSqliteEntityAttrTypeBool) {
			val = [NSNumber numberWithInt:(int)[entity performSelector:field.selectorGet]];
		} else if(attrType == EVLSqliteEntityAttrTypeDate) {
			VLDate *date = [entity performSelector:field.selectorGet];
			val = [VLDbCommon stringFromDate:date];
		} else if(attrType == EVLSqliteEntityAttrTypeDateNoTime) {
			VLDateNoTime *date = [entity performSelector:field.selectorGet];
			val = [VLDbCommon stringFromDateNoTime:date];
		} else if(attrType == EVLSqliteEntityAttrTypeTime) {
			VLTime *time = [entity performSelector:field.selectorGet];
			val = [VLDbCommon stringFromTime:time];
		} else if(attrType == EVLSqliteEntityAttrTypeIds) {
			NSSet *setIds = [entity performSelector:field.selectorGet];
			NSMutableString *sIds = [NSMutableString stringWithCapacity:setIds.count*10];
			for(NSNumber *num in setIds) {
				if(sIds.length)
					[sIds appendString:@","];
				[sIds appendString:[num stringValue]];
			}
			val = sIds;
		}
		if(val) {
			[dictValues setObject:val forKey:fieldName];
		}
	}
	if(entity.nId == 0) {
		int64_t nId = [_db insertValues:dictValues toTableWithName:dbTableName];
		if(nId) {
			entity.nId = nId;
			entity.needSave = NO;
		}
	} else {
		BOOL bRes = [_db updateRowWithId:entity.nId colIdName:kVLSqliteFieldKeyId values:dictValues inTableWithName:dbTableName];
		if(bRes)
			entity.needSave = NO;
	}
}

- (void)saveChangesToDb {
	NSArray *entities = [NSArray arrayWithArray:_entities];
	for(VLSqliteEntity *entity in entities) {
		if(entity.needSave) {
			[self saveEntityToDb:entity];
		}
	}
}

- (VLSqliteEntity *)entityWithIdentity:(VLSqliteEntity *)other inEntities:(NSArray *)entities {
	for(VLSqliteEntity *entity in entities)
		if([entity compareIdentityTo:other] == 0)
			return entity;
	return nil;
}

- (void)updateEntitiesFromOutside:(NSArray *)newEntities {
	for(VLSqliteEntity *entityNew in newEntities)
		entityNew.added = entityNew.deleted = entityNew.modified = NO;
	// Remove
	NSArray *entities = [NSArray arrayWithArray:_entities];
	for(VLSqliteEntity *entity in entities) {
		if(!entity.added && !entity.deleted) {
			if(![self entityWithIdentity:entity inEntities:newEntities])
				[self deleteEntityFromDb:entity];
		}
	}
	// Change
	for(VLSqliteEntity *entityNew in newEntities) {
		VLSqliteEntity *entity = [self entityWithIdentity:entityNew inEntities:_entities];
		if(entity && [entity compareDataTo:entityNew] != 0) {
			[entity assignDataFrom:entityNew];
			entity.added = entity.deleted = entity.modified = NO;
			entity.needSave = YES;
		}
	}
	// Add
	for(VLSqliteEntity *entityNew in newEntities) {
		VLSqliteEntity *entity = [self entityWithIdentity:entityNew inEntities:_entities];
		if(!entity) {
			entityNew.parent = self;
			entityNew.added = entityNew.deleted = entityNew.modified = NO;
			entityNew.needSave = YES;
			[_entities addObject:entityNew];
			[self modifyVersion];
		}
	}
}

- (void)recreateTableInDb {
	NSString *dbTableName = [_dummyEntity dbTableName];
	[_db dropTableWithName:dbTableName];
	NSMutableArray *colNames = [NSMutableArray array];
	NSMutableArray *colTypeFlags = [NSMutableArray array];
	NSArray *fileds = [_dummyEntity dbFields];
	for(VLSqliteEntityField *field in fileds) {
		NSString *fieldName = field.fieldName;
		EVLSqliteFieldTypeFlag fieldFlags = field.fieldFlags;
		[colNames addObject:fieldName];
		[colTypeFlags addObject:[NSNumber numberWithInt:fieldFlags]];
	}
	[_db createTableWithName:dbTableName colNames:colNames colTypeFlags:colTypeFlags];
}

- (void)updateTableInDb {
	NSString *dbTableName = [_dummyEntity dbTableName];
	NSMutableArray *colNames = [NSMutableArray array];
	NSMutableArray *colTypeFlags = [NSMutableArray array];
	NSArray *fileds = [_dummyEntity dbFields];
	for(VLSqliteEntityField *field in fileds) {
		NSString *fieldName = field.fieldName;
		EVLSqliteFieldTypeFlag fieldFlags = field.fieldFlags;
		[colNames addObject:fieldName];
		[colTypeFlags addObject:[NSNumber numberWithInt:fieldFlags]];
	}
	[_db updateTableWithName:dbTableName colNames:colNames colTypeFlags:colTypeFlags];
}

- (BOOL)containsEntityReference:(VLSqliteEntity *)entity {
	return [_entities indexOfObjectIdenticalTo:entity] != NSNotFound;
}

- (NSArray *)entitiesNotDeleted {
	int64_t entitiesNotDeletedVersion = self.version;
	if(_lastEntitiesNotDeletedVersion != entitiesNotDeletedVersion) {
		[_cacheEntitiesNotDeleted removeAllObjects];
		for(VLSqliteEntity *entity in _entities)
			if(!entity.deleted)
				[_cacheEntitiesNotDeleted addObject:entity];
		_lastEntitiesNotDeletedVersion = entitiesNotDeletedVersion;
	}
	return _cacheEntitiesNotDeleted;
}

- (void)dealloc {
	[self clearEntities];
	[_db release];
	[_entities release];
	[_dummyEntity release];
	[_dlgtEntityMarkedDeleted release];
	[_cacheEntitiesNotDeleted release];
	[super dealloc];
}

@end
