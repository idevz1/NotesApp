
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTLocationInfo : YTEntityBase {
@private
	int64_t _locationId;
	NSString *_name;
	double _latitude;
	double _longitude;
	VLDate *_lastUpdateTS;
}

@property(nonatomic, assign) int64_t locationId;
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) double latitude;
@property(nonatomic, assign) double longitude;
@property(nonatomic, assign) VLDate *lastUpdateTS;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTLocationInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTLocationInfo *)other;
- (NSComparisonResult)compareDataTo:(YTLocationInfo *)other;
- (NSComparisonResult)compareValuesTo:(YTLocationInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 Data Structure Name: 		Location
 Field Structure:
 
 LocationId		int
 LastUpdateTS		timestamp
 Name			varchar
 Latitude		decimal
 Longitude		decimal
*/
