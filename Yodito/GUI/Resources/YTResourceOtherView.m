
#import "YTResourceOtherView.h"
#import "../YTUiMediator.h"

@implementation YTResourceOtherView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor blackColor];
	
	_ivResIcon = [UIImageView new];
	_ivResIcon.backgroundColor = [UIColor clearColor];
	_ivResIcon.contentMode = UIViewContentModeCenter;
	[self addSubview:_ivResIcon];
	_ivResIcon.hidden = YES;
	
	_lbTitle = [VLLabel new];
	_lbTitle.backgroundColor = [UIColor clearColor];
	[_lbTitle centerText];
	_lbTitle.numberOfLines = 0;
	_lbTitle.lineBreakMode = NSLineBreakByWordWrapping;
	_lbTitle.textColor = [UIColor whiteColor];
	[self addSubview:_lbTitle];
	
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
	[self addGestureRecognizer:tap];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceInfo *resource = self.resource;
	if(resource) {
		_ivResIcon.image = [YTResourceFileTypeInfo imageByFileExt:resource.attachmentTypeName];
		NSString *title = [NSString stringWithFormat:@"%@\n%@", resource.descr, resource.filename];
		title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r \t"]];
		_lbTitle.text = title;
	} else {
		_ivResIcon.image = nil;
		_lbTitle.text = @"";
	}
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_ivResIcon.frame = rcBnds;
	CGRect rcLabel = rcBnds;
	if(!_ivResIcon.hidden) {
		rcLabel.size.height = rcBnds.size.height / 2;
		rcLabel.origin.y = CGRectGetMaxY(rcBnds) - rcLabel.size.height;
	}
	_lbTitle.frame = [UIScreen roundRect:rcLabel];
}

- (void)onTap:(UITapGestureRecognizer *)sender {
	if(sender.state == UIGestureRecognizerStateRecognized) {
		VLAlertView *alert = [[[VLAlertView alloc] init] autorelease];
		alert.title = NSLocalizedString(@"Unable to view file", nil);
		alert.message = NSLocalizedString(@"This file type cannot be viewed.", nil);
		[alert addButtonWithTitle:NSLocalizedString(@"OK {Button}", nil)];
		[alert showWithResultBlock:^(int btnIndex, NSString *btnTitle) {
		}];
		[[YTUiMediator shared].msgrFileCantBeViewedAlerted postMessage];
	}
}

- (void)dealloc {
	[_ivResIcon release];
	[_lbTitle release];
	[super dealloc];
}

@end

