
#import "YTResourceMediaView.h"
#import <AudioToolbox/AudioToolbox.h>

#define kAudioPlayerHeight 30.0

@implementation YTResourceMediaView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor blackColor];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceInfo *resource = self.resource;
	if(resource) {
		[self.loadingReference setResourceHash:resource.attachmenthash andType:resource.attachmentTypeName categoryId:(int)resource.attachmentCategoryId];
		BOOL processing = self.loadingReference.parentInfoRef.processing;
		if(processing) {
			
		} else {
			NSString *filePath = self.loadingReference.parentInfoRef.resourceFilePath;
			if(![NSString isEmpty:filePath]) {
				if(!_playerController) {
					NSString *tempFileName = kYTResourceVideoTempFileName;
					if([resource isAudio])
						tempFileName = kYTResourceAudioTempFileName;
					tempFileName = [tempFileName stringByAppendingPathExtension:resource.attachmentTypeName];
					NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
					NSError *error = nil;
					[[VLFileManager shared] deleteFileOrDir:tempFilePath error:&error];
					[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:tempFilePath error:&error];
					
					NSURL *url = [[[NSURL alloc] initFileURLWithPath:tempFilePath] autorelease];
					_playerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
					_playerController.fullscreen = NO;
					_playerController.controlStyle = MPMovieControlStyleEmbedded;
					[self addSubview:_playerController.view];
					if(self.activityView)
						[self bringSubviewToFront:self.activityView];
					[self layoutSubviews];
					[_playerController prepareToPlay];
					[_playerController play];
				}
			}
		}
		if(processing != self.activityView.visible) {
			if(processing) {
				self.activityView.visible = YES;
				[self.activityView startAnimating];
				[self bringSubviewToFront:self.activityView];
			} else {
				[self.activityView stopAnimating];
				self.activityView.visible = NO;
			}
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	YTResourceInfo *resource = self.resource;
	if(_playerController) {
		CGRect rcPlayer = rcBnds;
		if(resource && [resource isAudio]) {
			//rcPlayer.size.height = kAudioPlayerHeight;
			//rcPlayer.origin.y = (int)(CGRectGetMidY(rcBnds) - rcPlayer.size.height/2);
		}
		_playerController.view.frame = rcPlayer;
		_playerController.view.visible = YES;
	}
}

- (void)dealloc {
	[_playerController release];
	[super dealloc];
}

@end

