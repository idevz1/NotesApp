
#import <Foundation/Foundation.h>
#import "YTResourceBaseView.h"

@interface YTResourceWebDocView : YTResourceBaseView <UIWebViewDelegate> {
@private
	UIWebView *_webView;
	BOOL _webViewStartedLoad;
	NSString *_tempFilePath;
	BOOL _webViewLoading;
}

@end

