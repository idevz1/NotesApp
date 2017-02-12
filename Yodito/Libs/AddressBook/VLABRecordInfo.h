
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "VLABAddressInfo.h"
#import "VLABEmailInfo.h"
#import "VLABPhoneInfo.h"

@interface VLABRecordInfo : NSObject
{
	ABRecordRef _record;
}

@property(nonatomic,assign) ABRecordRef record;
@property(nonatomic,assign) ABRecordID recordId;
@property(nonatomic,assign) NSString *firstName;
@property(nonatomic,assign) NSString *lastName;
@property(nonatomic,assign) NSArray *addresses;
@property(nonatomic,assign) NSArray *emails;
@property(nonatomic,readonly) NSArray *phones;

- (NSString*)fullName;

@end
