
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTUsersEnManager : YTEntitiesManager {
@private
	YTUserInfo *_userInfo;
	YTUserInfo *_userInfoST;
	VLDelegate *_dlgtUserBeforeLoggedOut;
	VLDelegate *_dlgtUserLoggedOut;
	VLDelegate *_dlgtUserLoggedIn;
	BOOL _refreshingAuthenticate;
	BOOL _userJustRegistered;
}

@property(nonatomic, readonly) BOOL isLoggedIn;
@property(nonatomic, readonly) BOOL isDemo;
@property(nonatomic, readonly) YTUserInfo *userInfo;
@property(nonatomic, readonly) NSString *authenticationToken;
@property(nonatomic, readonly) VLDelegate *dlgtUserBeforeLoggedOut;
@property(nonatomic, readonly) VLDelegate *dlgtUserLoggedOut;
@property(nonatomic, readonly) VLDelegate *dlgtUserLoggedIn;
@property(nonatomic, readonly) BOOL userJustRegistered;

+ (YTUsersEnManager *)shared;
- (void)startDemoUser;
- (void)loginWithEmail:email password:password resultBlock:(void (^)(NSError *error))resultBlock;
- (void)registerWithFirstName:(NSString *)firstName
					 lastName:(NSString *)lastName
						email:(NSString *)email
					 password:(NSString *)password
				  resultBlock:(void (^)(NSError *error))resultBlock;
- (void)logoutWithResultBlock:(void (^)(NSError *error))resultBlock;
- (void)checkAndRefreshAuthenticationIfNeededDTWithResultBlockDT:(void (^)(NSError *error))resultBlockDT;
- (void)updateUserInfoDTWithResultBlockDT:(void (^)(NSError *error))resultBlockDT;
- (void)startRestoreForgottenPasswordWithEmail:(NSString *)email resultBlock:(void (^)(NSError *error))resultBlock;

@end

