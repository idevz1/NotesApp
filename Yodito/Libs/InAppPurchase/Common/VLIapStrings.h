
#import <Foundation/Foundation.h>

@interface VLIapStrings : NSObject
{
@private
}

@property(nonatomic, copy) NSString *errorPreviousRequestProcessing;
@property(nonatomic, copy) NSString *errorAppStoreUnavailable;
@property(nonatomic, copy) NSString *errorWebServerError;
@property(nonatomic, copy) NSString *errorUndefinedError;
@property(nonatomic, copy) NSString *errorUserNotRegistered;
@property(nonatomic, copy) NSString *errorSubscriptionWithEmailNotFound;
@property(nonatomic, copy) NSString *errorPaymentCancelled;
@property(nonatomic, copy) NSString *errorCouldNotCheckReceiptInServer;

@property(nonatomic, copy) NSString *alertTitleSubscription;
@property(nonatomic, copy) NSString *alertAssociatedEmailNoLongerInDatabase;
@property(nonatomic, copy) NSString *alertTitleSelectProduct;
@property(nonatomic, copy) NSString *alertTitleExtendSubscription;
@property(nonatomic, copy) NSString *alertSubscriptionWillExpireInD1;
@property(nonatomic, copy) NSString *alertTitleRenewSubscription;
@property(nonatomic, copy) NSString *alertSubscriptionHasExpired;

@property(nonatomic, copy) NSString *buttonExtendNow;
@property(nonatomic, copy) NSString *buttonRemindMeLater;
@property(nonatomic, copy) NSString *buttonRenewNow;

+ (VLIapStrings*)shared;

@end


