
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "../Common/Classes.h"

typedef void (^VLMailComposeManager_ResultBlock)(MFMailComposeResult result, NSError *error);

@interface VLMailComposeManager : NSObject <MFMailComposeViewControllerDelegate>
{
@private
	VLMailComposeManager_ResultBlock _resultBlock;
}

+ (VLMailComposeManager *)shared;

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				attachments:(NSArray *)attachments
		attachmentMimeTypes:(NSArray *)attachmentMimeTypes
		attachmentFileNames:(NSArray *)attachmentFileNames
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock;

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock;

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
				  addresses:(NSArray *)addresses
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName;

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
					address:(NSString *)address
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName
				resultBlock:(VLMailComposeManager_ResultBlock)resultBlock;

- (void)sendMailWithSubject:(NSString *)subject
					   body:(NSString *)body
					address:(NSString *)address
				 attachment:(NSData *)attachment
		 attachmentMimeType:(NSString *)attachmentMimeType
		 attachmentFileName:(NSString *)attachmentFileName;

- (void)mailImage:(UIImage *)image emailBody:(NSString *)emailBody;

@end
