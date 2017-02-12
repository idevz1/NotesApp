
#import <Foundation/Foundation.h>
#import "VLSqliteDatabase.h"

@interface VLSqliteEntitiesManager : VLLogicObject {
@private
	Class _entityClass;
	VLSqliteDatabase *_db;
	NSMutableArray *_entities;
	VLSqliteEntity *_dummyEntity;
	VLDelegate *_dlgtEntityMarkedDeleted;
	NSMutableArray *_cacheEntitiesNotDeleted;
	int64_t _lastEntitiesNotDeletedVersion;
}

@property(nonatomic, readonly) Class entityClass;
@property(nonatomic, readonly) NSArray *entities;
@property(nonatomic, readonly) NSArray *entitiesNotDeleted;
@property(nonatomic, readonly) VLSqliteDatabase *database;

- (id)initWithEntityClass:(Class)entityClass database:(VLSqliteDatabase *)database;

- (NSArray *)loadEntitiesFromDbWithWhereClause:(NSString *)whereClause;
- (void)loadEntitiesFromDb;
- (void)addEntity:(VLSqliteEntity *)entity;
- (void)deleteEntityFromDb:(VLSqliteEntity *)entity;
- (void)saveEntityToDb:(VLSqliteEntity *)entity;
- (void)updateEntitiesFromOutside:(NSArray *)newEntities;
- (void)recreateTableInDb;
- (void)updateTableInDb;
- (void)saveChangesToDb;
- (BOOL)containsEntityReference:(VLSqliteEntity *)entity;
- (void)clearEntities;
- (void)deleteAllEntitiesFromDb;

@end
