
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../YTCommon.h"

@interface YTEntityBase : VLSqliteEntity {
@private
	BOOL _isTemporary;
}

@property(nonatomic, assign) BOOL isTemporary;

+ (void)setModifyingBreakpointDisabled;
+ (void)resetModifyingBreakpointDisabled;

- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTEntityBase *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;
- (void)loadFromData:(NSDictionary *)data;
- (NSComparisonResult)compareIdentityTo:(YTEntityBase *)other;
- (NSComparisonResult)compareValuesTo:(YTEntityBase *)other;

- (void)getData:(NSMutableDictionary *)data;
- (NSString *)description;
+ (NSString *)entityName;
- (BOOL)isInDb;

@end
