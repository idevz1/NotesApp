
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface VLABEmailInfo : NSObject
{
	NSString *_label;
	NSString *_value;
}

@property(nonatomic,assign) NSString *label;
@property(nonatomic,assign) NSString *value;

@end
