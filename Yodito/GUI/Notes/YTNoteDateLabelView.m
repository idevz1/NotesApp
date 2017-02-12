
#import "YTNoteDateLabelView.h"

#define kPadding UIEdgeInsetsMake(8, 8, 8, 2)

@implementation YTNoteDateLabelView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	_label = [[VLLabel alloc] initWithFrame:CGRectZero];
	_label.backgroundColor = [UIColor clearColor];
	_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_label.textColor = [UIColor colorWithRed:0x30/255.0 green:0x30/255.0 blue:0x30/255.0 alpha:1.0];//kYTLabelsBlueTextColor;
	_label.adjustsFontSizeToFitWidth = YES;
	[self addSubview:_label];
	
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_label.font = [[YTFontsManager shared] fontWithSize:10 fixed:YES];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNoteInfo *note = self.note;
	if(!note)
		return;
	NSDate *createdDate = [note.createdDate toNSDate];
	NSDateFormatter *frmTime = [[[NSDateFormatter alloc] init] autorelease];
	frmTime.dateStyle = NSDateFormatterNoStyle;
	frmTime.timeStyle = NSDateFormatterShortStyle;
	NSString *sTime = [frmTime stringFromDate:createdDate];
	NSDateFormatter *frmDate = [[[NSDateFormatter alloc] init] autorelease];
	frmDate.timeStyle = NSDateFormatterNoStyle;
	frmDate.dateFormat = @"EEEE, MMMM dd, yyyy";
	NSString *sDate = [frmDate stringFromDate:createdDate];
	NSString *sTitle = [NSString stringWithFormat:@"%@ %@", sTime, sDate];
	sTitle = [sTitle uppercaseString];
	_label.text = sTitle;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, kPadding);
	_label.frame = rcCtrls;
}

- (CGSize)sizeThatFits:(CGSize)size {
	//size.height = kPadding.top + [_label sizeOfText].height + kPadding.bottom;
	size.height = 30.0;
	return size;
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	[self updateViewAsync];
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_label release];
	[super dealloc];
}

@end

