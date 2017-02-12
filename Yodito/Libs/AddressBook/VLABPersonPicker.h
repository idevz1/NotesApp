
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "VLABRecordInfo.h"

typedef enum
{
	EVLABPersonPickerModeNone,
	EVLABPersonPickerModeEmail,
	EVLABPersonPickerModeAddress
}
EVLABPersonPickerMode;

typedef void (^VLABPersonPicker_ResultBlock)(VLABRecordInfo* recordInfo);

@interface VLABPersonPicker : NSObject <ABPeoplePickerNavigationControllerDelegate>
{
	UIViewController *_parentVC;
	ABPeoplePickerNavigationController *_peoplePicker;
	VLABPersonPicker_ResultBlock _resultBlock;
	VLABRecordInfo *_recordInfo;
	EVLABPersonPickerMode _mode;
}

@property(nonatomic, assign) EVLABPersonPickerMode mode;

+ (VLABPersonPicker*)shared;

- (void)selectPersonFromVC:(UIViewController*)parentVC
			   resultBlock:(VLABPersonPicker_ResultBlock)resultBlock;

@end
