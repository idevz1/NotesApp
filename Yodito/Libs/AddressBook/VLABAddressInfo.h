
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface VLABAddressInfo : NSObject
{
	NSString *_label;
	NSMutableArray *_streets;
	NSString *_city;
	NSString *_state;
	NSString *_zip;
	NSString *_country;
	NSString *_countryCode;
}

@property(nonatomic,assign) NSString *label;
@property(nonatomic,assign) NSArray *streets;
@property(nonatomic,assign) NSString *allStreetsAsLines;
@property(nonatomic,assign) NSString *city;
@property(nonatomic,assign) NSString *state;
@property(nonatomic,assign) NSString *zip;
@property(nonatomic,assign) NSString *country;
@property(nonatomic,assign) NSString *countryCode;

//- (BOOL)validateWithAlert:(BOOL)withAlert;
- (NSString*)toString;
- (void)assignFromDictionary:(NSDictionary*)theDict;
- (BOOL)isEqual:(VLABAddressInfo*)other;

@end
