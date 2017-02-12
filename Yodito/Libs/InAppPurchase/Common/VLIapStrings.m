
#import "VLIapStrings.h"

@implementation VLIapStrings

@synthesize errorPreviousRequestProcessing;
@synthesize errorAppStoreUnavailable;
@synthesize errorWebServerError;
@synthesize errorUndefinedError;
@synthesize errorUserNotRegistered;
@synthesize errorSubscriptionWithEmailNotFound;
@synthesize errorPaymentCancelled;
@synthesize errorCouldNotCheckReceiptInServer;

@synthesize alertTitleSubscription;
@synthesize alertAssociatedEmailNoLongerInDatabase;
@synthesize alertTitleSelectProduct;
@synthesize alertTitleExtendSubscription;
@synthesize alertSubscriptionWillExpireInD1;
@synthesize alertTitleRenewSubscription;
@synthesize alertSubscriptionHasExpired;

@synthesize buttonExtendNow;
@synthesize buttonRemindMeLater;
@synthesize buttonRenewNow;

+ (VLIapStrings*)shared
{
	static VLIapStrings *_shared;
	if(!_shared)
		_shared = [[VLIapStrings alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		self.errorPreviousRequestProcessing = @"Previous request processing...";
		self.errorAppStoreUnavailable = @"App Store Unavailable";
		self.errorWebServerError = @"Web Server Error";
		self.errorUndefinedError = @"Undefined Error";
		self.errorUserNotRegistered = @"User not Registered.";
		self.errorSubscriptionWithEmailNotFound = @"Subscription associated with e-mail was not found.";
		self.errorPaymentCancelled = @"Payment Cancelled";
		self.errorCouldNotCheckReceiptInServer = @"Could not check receipt in iTunes server";
		
		self.alertTitleSubscription = @"Subscription";
		self.alertAssociatedEmailNoLongerInDatabase = @"The email address associated with this subscription is no longer in our database.";
		self.alertTitleSelectProduct = @"Select product";
		self.alertTitleExtendSubscription = @"Extend Subscription";
		self.alertSubscriptionWillExpireInD1 = @"Your subscription will expire in %d days.";
		self.alertTitleRenewSubscription = @"Renew Subscription";
		self.alertSubscriptionHasExpired = @"Your subscription has expired";
		
		self.buttonExtendNow = @"Extend Now";
		self.buttonRemindMeLater = @"Remind Me Later";
		self.buttonRenewNow = @"Renew Now";
	}
	return self;
}

@end



