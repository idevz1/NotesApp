
#import <Foundation/Foundation.h>
#import "../ELCImagePicker/Classes.h"

@class YTELCImagePickerController;

typedef void (^YTELCImagePickerController_ResultBlock)(NSArray *assets);

@interface YTELCImagePickerController : NSObject <ELCImagePickerControllerDelegate> {
@private
	YTELCImagePickerController_ResultBlock _resultBlock;
}

- (void)showWithResultBlock:(YTELCImagePickerController_ResultBlock)resultBlock;
+ (BOOL)isShown;

@end

