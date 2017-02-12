
#import <Foundation/Foundation.h>
#import "../../Common/Classes.h"
#import <StoreKit/StoreKit.h>
#import "JSON.h"

#define kVLIapLogEvents (kVLLogEvents && YES)

#define kVLIapJsonKeyNonRenSubInfo @"iap_subscription_info"

#define kVLIapJsonKeyStartDate @"start_date"
#define kVLIapJsonKeyMonthsCount @"months_count"
#define kVLIapJsonKeyTransactionId @"transaction_id"
#define kVLIapJsonKeyReceipt @"receipt"
#define kVLIapJsonKeyUserName @"user_name"
#define kVLIapJsonKeyUserPassword @"user_password"
#define kVLIapJsonKeyDeviceId @"device_id"
#define kVLIapJsonKeyPeriodsInfos @"periods_infos"
#define kVLIapJsonKeyPeriodInfo @"period_info"
#define kVLIapJsonKeyCurTime @"cur_time"

#define kVLIapHttpPostParamUserName @"user_name"
#define kVLIapHttpPostParamDeviceId @"device_id"
#define kVLIapHttpPostParamTransactionId @"transaction_id"
#define kVLIapHttpPostParamReceipt @"receipt"

#define kVLIapHttpGetParamAction @"action"

#ifdef kVLIapDebugMode
#define kVLIapHttpGetParamAction_ClearSubscriptions @"clear_subscriptions_htkgkjsgbkjabfjhbgbagjkbkjgbeaiu4g3i"
#else
#define kVLIapHttpGetParamAction_ClearSubscriptions @""
#endif

#define kVLIapNonRenHttpGetParamAction_SaveSubInfo @"action_save_sub_info"
#define kVLIapNonRenHttpGetParamAction_GetSubInfo @"action_get_sub_info"
#define kVLIapNonRenHttpGetParamAction_RegisterSubInfo @"action_register_sub_info"

#define kVLIapNonRenApiWebPage @"vliapsubapi.php"
#define kVLIapCheckReceiptWebPage @"vliapcheckreceipt.php"

#define kVLIapHttpParamSecret @"secret"
#define kVLIapHttpParamReceipt @"receipt"
#define kVLIapHttpParamDebug @"debug"

#define kVLIapJsonKeyCode @"code"
#define kVLIapJsonKeyStatus @"status"
#define kVLIapJsonKeyReceiptStatus @"receipt_stat"
#define kVLIapJsonErrorWrongResponseFromITunesServer -401
#define kJsonReceiptValidStatusValue 73953

#define kVLIapWebBigDataTimeout 120.0

@interface VLIapCommon : NSObject

+ (void)initializeWithIsSandbox:(BOOL)isSandbox;
+ (BOOL)isSandbox;

+ (NSError*)errorStillProcessing;
+ (NSError*)errorStoreUnavailable;
+ (NSError*)errorWebServer;
+ (NSError*)errorUndefined;

+ (NSString*)stringFromSKProduct:(SKProduct*)product;
+ (NSString*)stringFromSKProductsList:(NSArray*)products;
+ (NSString*)stringFromSKProductsPrice:(SKProduct*)product;
+ (NSString*)transactionToString:(SKPaymentTransaction*)transaction;
+ (NSString*)paymentToString:(SKPayment*)payment;
+ (NSString*)transactionStateToString:(SKPaymentTransactionState)transactionState;

@end

