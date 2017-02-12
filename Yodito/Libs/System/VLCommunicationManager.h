
#import <Foundation/Foundation.h>

@interface VLCommunicationManager : NSObject
{
	
}

+ (BOOL)isPhoneAvailable;
+ (BOOL)isFacetimeAvailable;
+ (BOOL)isIMessageAvailable;

+ (void)startPhoneCallWithNumber:(NSString*)sNumber;
+ (void)startFacetimeWithNumber:(NSString*)sNumber;
+ (void)startMessageWithNumber:(NSString*)sNumber;

@end
