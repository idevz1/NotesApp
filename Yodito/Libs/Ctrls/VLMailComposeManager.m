
#import "VLMailComposeManager.h"
#import "../Common/Classes.h"
#import "VLAppDelegateBase.h"
#import "AppDelegate.h"
@implementation VLMailComposeManager

+ (VLMailComposeManager *)shared
{
	static VLMailComposeManager *_shared;
	if(!_shared)
		_shared = [[VLMailComposeManager alloc] init];
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

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				attachments:(NSArray *)attachments
		attachmentMimeTypes:(NSArray *)attachmentMimeTypes
		attachmentFileNames:(NSArray *)attachmentFileNames
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock {
	
	if(!attachments)
		attachments = [NSArray array];
	if(!attachmentMimeTypes)
		attachmentMimeTypes = [NSArray array];
	if(!attachmentFileNames)
		attachmentFileNames = [NSArray array];
	if (![MFMailComposeViewController canSendMail])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry, you can't send emails from your device. Make sure that you have added at least one email account."
															message:@""
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView autorelease];
		return;
	}
	if(_resultBlock) {
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	if(resultBlock) {
		_resultBlock = Block_copy(resultBlock);
	}
	MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
	picker.mailComposeDelegate = self;
	if(addresses && addresses.count)
		[picker setToRecipients:addresses];
	[picker setSubject:subject];
	if(![NSString isEmpty:body])
		[picker setMessageBody:body isHTML:YES];
	int attachmentsCount = (int)MIN(MIN(attachments.count, attachmentMimeTypes.count), attachmentFileNames.count);
	for(int i = 0; i < attachmentsCount; i++) {
		NSData *attachment = [attachments objectAtIndex:i];
		NSString *attachmentMimeType = [attachmentMimeTypes objectAtIndex:i];
		NSString *attachmentFileName = [attachmentFileNames objectAtIndex:i];
		[picker addAttachmentData:attachment mimeType:attachmentMimeType fileName:attachmentFileName];
	}
	picker.modalPresentationStyle = UIModalPresentationFormSheet;
	UIViewController *vc = [[VLAppDelegateBase sharedAppDelegateBase] topModalViewController];
	[vc presentViewController:picker animated:YES completion:^{
	}];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]showMailPicker:picker];
    }
}

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock {
	
	[self sendMailWithSubject:subject
						 body:body
					addresses:addresses
				  attachments:attachment ? [NSArray arrayWithObject:attachment] : [NSArray array]
		  attachmentMimeTypes:attachmentMimeType ? [NSArray arrayWithObject:attachmentMimeType] : [NSArray array]
		  attachmentFileNames:attachmentFileName ? [NSArray arrayWithObject:attachmentFileName] : [NSArray array]
				  resultBlock:^(MFMailComposeResult result, NSError *error) {
		if(resultBlock)
			resultBlock(result, error);
	}];
}

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName
{
	[self sendMailWithSubject:subject
						 body:body
					addresses:addresses
				   attachment:attachment
		   attachmentMimeType:attachmentMimeType
		   attachmentFileName:attachmentFileName
				  resultBlock:nil];
}

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
					address:(NSString *)address
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock {
	[self sendMailWithSubject:subject
						 body:body
					addresses:address ? [NSArray arrayWithObject:address] : nil
				   attachment:attachment
		   attachmentMimeType:attachmentMimeType
		   attachmentFileName:attachmentFileName
				  resultBlock:resultBlock];
}

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
					address:(NSString *)address
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName {
	[self sendMailWithSubject:subject
						 body:body
					addresses:address ? [NSArray arrayWithObject:address] : nil
				   attachment:attachment
		   attachmentMimeType:attachmentMimeType
		   attachmentFileName:attachmentFileName
				  resultBlock:nil];
}

- (void)mailImage:(UIImage *)image emailBody:(NSString *)emailBody
{
	NSData *attachmentData = UIImageJPEGRepresentation(image, 1.0);
	NSString *attachmentMimeType = @"image/jpeg";
	NSString *attachmentFileName = @"image.jpg";
	[self sendMailWithSubject:nil
						 body:![NSString isEmpty:emailBody] ? emailBody : nil
					  address:nil
				   attachment:attachmentData
		   attachmentMimeType:attachmentMimeType
		   attachmentFileName:attachmentFileName];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
	[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:controller animated:YES];
	if(_resultBlock) {
		VLMailComposeManager_ResultBlock resultBlock = Block_copy(_resultBlock);
		Block_release(_resultBlock);
		_resultBlock = nil;
		resultBlock(result, error);
		Block_release(resultBlock);
	}
    [[AppDelegate instance]dismissMailPicker:controller];
}

- (void)dealloc
{
	if(_resultBlock)
		Block_release(_resultBlock);
	[super dealloc];
}

@end
