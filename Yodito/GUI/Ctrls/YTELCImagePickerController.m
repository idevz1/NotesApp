
#import "YTELCImagePickerController.h"
#import "../../Libs/Classes.h"
#import "AppDelegate.h"

static int _showsCounter;

@implementation YTELCImagePickerController

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)showWithResultBlock:(YTELCImagePickerController_ResultBlock)resultBlock {
	if(_resultBlock) {
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	_showsCounter++;
	if(resultBlock)
		_resultBlock = Block_copy(resultBlock);
	ELCImagePickerController *picker = [[[ELCImagePickerController alloc] initWithSelectDefultGroupOnShow:YES] autorelease];
	picker.maximumImagesCount = INT_MAX;
	picker.imagePickerDelegate = self;
	[picker view]; // Force to load view
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		return picker.albumPicker.defaultGroupShown;
	} ignoringTouches:YES completeBlock:^{
		if(kIosVersionFloat >= 7.0)
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
		[self retain];
		[[VLAppDelegateBase sharedAppDelegateBase].topModalViewController presentViewController:picker animated:YES completion:^{
		}];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [[AppDelegate instance]showImagePicker:picker];
        }
	}];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSLog(@"Done");
	if(kIosVersionFloat >= 7.0)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[info count]];
	for(NSDictionary *dict in info) {
		ALAsset *asset = [dict objectForKey:@"asset"];
		[assets addObject:asset];
	
    }
    
	[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:picker animated:YES];
    {
        [[AppDelegate instance]dismissImagePicker:picker];
    }

	if(_resultBlock) {
		_resultBlock(assets);
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	[self autorelease];
	_showsCounter--;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {

    
	if(kIosVersionFloat >= 7.0)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    [[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:picker animated:YES];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]dismissImagePicker:picker];
    }

	if(_resultBlock) {
		_resultBlock([NSArray array]);
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	[self autorelease];
	_showsCounter--;
}

+ (BOOL)isShown {
	return (_showsCounter > 0);
}

- (void)dealloc {
	if(_resultBlock) {
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	[super dealloc];
}

@end

