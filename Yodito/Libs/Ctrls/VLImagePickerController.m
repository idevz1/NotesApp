
#import "VLImagePickerController.h"
#import "../Logic/Classes.h"
#import "../Ctrls/Classes.h"
#import "../System/Classes.h"
#import "../Drawing/Classes.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"
@implementation VLImagePickerController

@synthesize sourceType = _sourceType;
@synthesize pathToChosenVideo = _pathToChosenVideo;
@synthesize canPickVideo = _canPickVideo;
@synthesize doNotPickImage = _doNotPickImage;

+ (VLImagePickerController *)shared
{
	static VLImagePickerController *_shared = nil;
	if(!_shared)
		_shared = [[VLImagePickerController alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (void)showWithSource:(UIImagePickerControllerSourceType)sourceType 
		fromParentView:(UIView *)parentView
				  rect:(CGRect)rect
		   orBarButton:(UIBarButtonItem*)barButton
		   resultBlock:(VLImagePickerController_ResultBlock)resultBlock
{
	[_pathToChosenVideo release];
	_pathToChosenVideo = nil;
	if(_resultBlock)
		Block_release(_resultBlock);
	_resultBlock = Block_copy(resultBlock);
	_parentView = parentView;
	_parentViewRect = rect;
	if(_parentViewRect.size.width < 1)
		_parentViewRect.size.width = 1;
	if(_parentViewRect.size.height < 1)
		_parentViewRect.size.height = 1;
	UIViewController *holderVC = [[VLAppDelegateBase sharedAppDelegateBase] topModalViewController];
	if(!_ctr)
	{
		_ctr = [[UIImagePickerController alloc] init];
		_ctr.delegate = self;
		NSMutableArray *mediaTypes = [NSMutableArray arrayWithArray:_ctr.mediaTypes];
		NSString *movieType = (NSString *)kUTTypeMovie;
		if(_canPickVideo) {
			if(![mediaTypes containsObject:movieType])
				[mediaTypes addObject:movieType];
		} else {
			if([mediaTypes containsObject:movieType])
				[mediaTypes removeObject:movieType];
		}
		NSString *imageType = (NSString *)kUTTypeImage;
		if(_doNotPickImage) {
			if([mediaTypes containsObject:imageType])
				[mediaTypes removeObject:imageType];
		}
		_ctr.mediaTypes = mediaTypes;
	}
	_sourceType = sourceType;
	_ctr.sourceType = _sourceType;
	_isImageSelected = NO;
	_isCanceled = NO;
	if(IsUiIPad)
	{
        [[AppDelegate instance]showSettingsImagePicker:_ctr];
    }
	else
		[holderVC presentViewController:_ctr animated:YES completion:^{
		}];
	[self retain];
}

- (void)finishWithImage:(UIImage *)image {
	if(image)
		_isImageSelected = YES;
	else
		_isCanceled = YES;
	if(_resultBlock) {
		VLImagePickerController_ResultBlock resultBlock = Block_copy(_resultBlock);
		Block_release(_resultBlock);
		_resultBlock = nil;
		resultBlock(image);
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	_isImageSelected = YES;
	[self autorelease];
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
	[self finishWithImage:image];
    if(IsUiIPad)
        [[AppDelegate instance]settingsGoBack];
	
}
- (void)imagePickerController:(UIImagePickerController *)picker
	didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	/*Printing description of info:
	 {
	 UIImagePickerControllerMediaType = "public.movie";
	 UIImagePickerControllerMediaURL = "file://localhost/private/var/mobile/Applications/DC86D944-E39E-49BA-96AA-3A0703A92CDD/tmp//trim.3UDzaz.MOV";
	 UIImagePickerControllerReferenceURL = "assets-library://asset/asset.MOV?id=7D0895E2-9D6D-4724-9811-F62DBD7200A3&ext=MOV";
	 }*/
	_isImageSelected = YES;
	[self autorelease];
	NSString *sMediaType = [info objectForKey:UIImagePickerControllerMediaType];
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSString *movieType = (NSString *)kUTTypeMovie;
	if([sMediaType isEqual:movieType]) {
		[_pathToChosenVideo release];
		_pathToChosenVideo = nil;
		NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
		if(url)
			_pathToChosenVideo = [[url path] retain];
	}
    if(IsUiIPad)
        [[AppDelegate instance]settingsGoBack];
    else{
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
	[self finishWithImage:image];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	_isCanceled = YES;
	[self autorelease];
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
	[self finishWithImage:nil];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
	return YES;
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if(!_isImageSelected && !_isCanceled) {
		[self autorelease];
		[self finishWithImage:nil];
	}
}

- (void)dealloc
{
	if(_resultBlock)
		Block_release(_resultBlock);
	[_ctr release];
	[_popover release];
	[_pathToChosenVideo release];
	[super dealloc];
}

@end

