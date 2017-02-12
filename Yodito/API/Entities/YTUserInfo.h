
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

#define kYTUserInfoDemoPersonId (-1)

@interface YTUserInfo : YTEntityBase {
@private
	BOOL _isDemo;
	BOOL _hasDemoData; // Has demo data that is not synced with server yet
	int64_t _personId;
	VLDate *_lastUpdateTS;
	NSString *_firstName;
	NSString *_lastName;
	NSString *_emailId1;
	NSString *_emailId2;
	NSString *_emailId3;
	NSString *_accountStatus;
	float _diskSpaceUsed;
	NSString *_status;
	VLDate *_createdDate;
	int _packageId;
	
	NSString *_authenticationToken;
	VLDate *_currentTime;
	VLDate *_expiration;
}

@property(nonatomic, assign) BOOL isDemo;
@property(nonatomic, assign) BOOL hasDemoData;
@property(nonatomic, assign) int64_t personId;
@property(nonatomic, assign) VLDate *lastUpdateTS;
@property(nonatomic, assign) NSString *firstName;
@property(nonatomic, assign) NSString *lastName;
@property(nonatomic, assign) NSString *emailId1;
@property(nonatomic, assign) NSString *emailId2;
@property(nonatomic, assign) NSString *emailId3;
@property(nonatomic, assign) NSString *accountStatus;
@property(nonatomic, assign) float diskSpaceUsed;
@property(nonatomic, assign) NSString *status;
@property(nonatomic, assign) VLDate *createdDate;
@property(nonatomic, assign) int packageId;

@property(nonatomic, assign) NSString *authenticationToken;
@property(nonatomic, assign) VLDate *currentTime;
@property(nonatomic, assign) VLDate *expiration;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTUserInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTUserInfo *)other;
- (NSComparisonResult)compareDataTo:(YTUserInfo *)other;

- (void)clear;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 #define kYTJsonKeyAccountStatus @"AccountStatus"
 #define kYTJsonKeyCreatedDate @"CreatedDate"
 #define kYTJsonKeyDiskSpaceUsed @"DiskSpaceUsed"
 #define kYTJsonKeyEmailId1 @"EmailId1"
 #define kYTJsonKeyEmailId2 @"EmailId2"
 #define kYTJsonKeyEmailId3 @"EmailId3"
 #define kYTJsonKeyFirstName @"FirstName"
 #define kYTJsonKeyLastName @"LastName"
 #define kYTJsonKeyLastUpdateTS @"LastUpdateTS"
 #define kYTJsonKeyPackageId @"PackageId"
 #define kYTJsonKeyPersonId @"PersonId"
 #define kYTJsonKeyStatus @"Status"
*/