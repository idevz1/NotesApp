
#import "YTResourceWebDocView.h"

@implementation YTResourceWebDocView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor blackColor];
	_tempFilePath = [@"" retain];
	
	_webView = [UIWebView new];
	_webView.delegate = self;
	_webView.scalesPageToFit = YES;
	[self addSubview:_webView];
	
	[self updateViewAsync];
}

- (void)setTempFilePathInternal:(NSString *)tempFilePath {
	if(!tempFilePath)
		tempFilePath = @"";
	if(![_tempFilePath isEqual:tempFilePath]) {
		if(![NSString isEmpty:_tempFilePath]) {
			NSError *error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:&error];
			if(error)
				VLLogError(error);
		}
		[_tempFilePath release];
		_tempFilePath = [tempFilePath copy];
	}
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
				if(!_webViewStartedLoad) {
					
					NSString *tempFileName = [[[VLGuid makeUnique] toString] md5];
					tempFileName = [tempFileName stringByAppendingPathExtension:resource.attachmentTypeName];
					NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
					[self setTempFilePathInternal:tempFilePath];
					NSError *error = nil;
					[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:_tempFilePath error:&error];
					
					_webViewStartedLoad = YES;
					NSURL *url = [NSURL fileURLWithPath:_tempFilePath];
					[_webView loadRequest:[NSURLRequest requestWithURL:url]];
					_webViewLoading = YES;
				}
			}
		}
		if(!processing && _webViewLoading)
			processing = YES;
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self updateViewAsync];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if(_webViewLoading) {
		_webViewLoading = NO;
		[self updateViewAsync];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if(_webViewLoading) {
		_webViewLoading = NO;
		[self updateViewAsync];
	}
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_webView.frame = rcBnds;
}

- (void)dealloc {
	[self setTempFilePathInternal:nil];
	[_webView release];
	[_tempFilePath release];
	[super dealloc];
}

@end

