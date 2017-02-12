
#import "VLPopupPickerView.h"
#import "VLCtrlsUtils.h"
#import "VLBaseViewController.h"
#import "VL_UIControls_Categories.h"
#import "VLCtrlsResources.h"
#import "VLCtrlsCommon.h"
#import "VLAppDelegateBase.h"

#define kOverlayAlphaStart 0.0
#define kOverlayAlphaEnd 0.5
#define kBackAlphaStart 0.0
#define kBackAlphaEnd 1.0
#define kAnimationDuration 0.25

#define kTextViewHeight iUiChoice(100, 120)
#define kTextFieldHeight iUiChoice(40, 40)
#define kTextViewBorder 8
#define kTextFieldBorder 8

#define kDolsCount 100000
#define kDolsStep 1
#define kCentsCount 100
#define kCentsStep 1

@implementation VLPopupPickerView

@synthesize type = _type;
@dynamic value;
@dynamic selectedItemIndex;
@synthesize currencySymbol = _currencySymbol;
@synthesize customView = _customView;
@synthesize bbiLeft = _bbiLeft;
@dynamic viewDatePicker;
@dynamic title;
@synthesize toolbar = _toolbar;

- (UIDatePicker*)viewDatePicker
{
	return ObjectCast(_datePickerView, UIDatePicker);
}

- (void)createControls
{
	if(_pickerViewRef)
		return;
	CGRect rcPicker = CGRectMake(0, 0, 320, 220);
	if(_type == EVLPopupPickerViewTypeDate)
	{
		_datePickerView = [[UIDatePicker alloc] initWithFrame:rcPicker];
		_datePickerView.datePickerMode = UIDatePickerModeDate;
	}
	else if(_type == EVLPopupPickerViewTypeTime)
	{
		_datePickerView = [[UIDatePicker alloc] initWithFrame:rcPicker];
		_datePickerView.datePickerMode = UIDatePickerModeTime;
	}
	else if(_type == EVLPopupPickerViewTypeDateAndTime)
	{
		_datePickerView = [[UIDatePicker alloc] initWithFrame:rcPicker];
		_datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
	}
	else if(_type == EVLPopupPickerViewTypeCountDownTimer)
	{
		_datePickerView = [[UIDatePicker alloc] initWithFrame:rcPicker];
		_datePickerView.datePickerMode = UIDatePickerModeCountDownTimer;
	}
	else if(_type == EVLPopupPickerViewTypeValuesSet || _type == EVLPopupPickerViewTypeCurrency)
	{
		_commonPickerView = [[UIPickerView alloc] initWithFrame:rcPicker];
		_commonPickerView.showsSelectionIndicator = YES;
		_commonPickerView.dataSource = self;
		_commonPickerView.delegate = self;
	}
	else if(_type == EVLPopupPickerViewTypeText)
	{
		_textViewPicker = [[UITextView alloc] init];
		[_textViewPicker roundCorners:kTextViewBorder];
		_textViewPicker.font = [VLCtrlsResources fontTextFieldBig];
		_textViewPicker.delegate = self;
	}
	else if(_type == EVLPopupPickerViewTypeString)
	{
		_textFieldPicker = [[UITextField alloc] init];
		[_textFieldPicker roundCorners:kTextFieldBorder/2];
		_textFieldPicker.borderStyle = UITextBorderStyleRoundedRect;
		_textFieldPicker.font = [VLCtrlsResources fontTextFieldBig];
		_textFieldPicker.delegate = self;
	}
	else if(_type == EVLPopupPickerViewTypeCustomView)
	{
	}
	if(_datePickerView)
	{
		[_datePickerView setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	if(_datePickerView)
		_pickerViewRef = _datePickerView;
	if(_commonPickerView)
		_pickerViewRef = _commonPickerView;
	if(_textViewPicker)
		_pickerViewRef = _textViewPicker;
	if(_textFieldPicker)
		_pickerViewRef = _textFieldPicker;
	if(_customView)
		_pickerViewRef = _customView;
	if(!_pickerViewRef)
		return;
	self.backgroundColor = [UIColor clearColor];
	
	_viewOverlay = [[UIView alloc] initWithFrame:CGRectZero];
	[self addSubview:_viewOverlay];
	_viewBack = [[UIView alloc] initWithFrame:CGRectZero];
	[self addSubview:_viewBack];
	_viewOverlay.opaque = _viewBack.opaque = NO;
	_viewOverlay.backgroundColor = _viewBack.backgroundColor = [UIColor blackColor];
	_viewOverlay.alpha = kOverlayAlphaStart;
	_viewBack.alpha = kBackAlphaStart;
	
	[self addSubview:_pickerViewRef];
	
	// Fix for iOS7
	if(_pickerViewRef)
		_pickerViewRef.backgroundColor = [UIColor whiteColor];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	[self addSubview:_toolbar];
	
	UIBarButtonItem *bbiCancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				target:self
																				action:@selector(onCancel:)] autorelease];
	_bbiLeft = [bbiCancel retain];
	UIBarButtonItem *bbiSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			   target:nil
																			   action:nil] autorelease];
	UIBarButtonItem *bbiDone = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self
																			  action:@selector(onDone:)] autorelease];
	_bbiRight = [bbiDone retain];
	_toolbar.items = [NSArray arrayWithObjects:bbiCancel, bbiSpace, bbiDone, nil];
	
	_lbTitle = [[UILabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.textAlignment = NSTextAlignmentCenter;
	_lbTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_lbTitle.numberOfLines = 1;
	_lbTitle.lineBreakMode = NSLineBreakByTruncatingTail;
	_lbTitle.textColor = [UIColor whiteColor];
	_lbTitle.shadowColor = [UIColor blueColor];
	_lbTitle.shadowOffset = CGSizeMake(0, -1);
	_lbTitle.font = [UIFont boldSystemFontOfSize:16.0];
	[self addSubview:_lbTitle];
	
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation addObserver:self
				selector:@selector(willRotateToInterfaceOrientation:)];
}

- (id)initWithType:(EVLPopupPickerViewType)type
	   valuesArray:(NSArray*)valuesArray
titleForValueBlock:(VLPopupPickerView_BlockTitleForValue)titleForValueBlock
{
	self = [super init];
	if(self)
	{
		_valuesArray = [[NSMutableArray alloc] init];
		_currencySymbol = [@"" retain];
		
		_type = type;
		[_valuesArray removeAllObjects];
		if(valuesArray)
			[_valuesArray addObjectsFromArray:valuesArray];
		if(titleForValueBlock)
			_titleForValueBlock = Block_copy(titleForValueBlock);
		[self createControls];
	}
	return self;
}
- (id)initWithType:(EVLPopupPickerViewType)type valuesArray:(NSArray*)valuesArray
{
	if(self = [self initWithType:type valuesArray:valuesArray titleForValueBlock:nil])
	{
	}
	return self;
}
- (id)initWithType:(EVLPopupPickerViewType)type titleForValueBlock:(VLPopupPickerView_BlockTitleForValue)titleForValueBlock
{
	if(self = [self initWithType:type valuesArray:nil titleForValueBlock:titleForValueBlock])
	{
	}
	return self;
}
- (id)initWithType:(EVLPopupPickerViewType)type
{
	if(self = [self initWithType:type valuesArray:nil titleForValueBlock:nil])
	{
	}
	return self;
}
- (id)initWithCustomView:(UIView*)customView
{
	if(self = [self initWithType:EVLPopupPickerViewTypeCustomView valuesArray:nil titleForValueBlock:nil])
	{
		_customView = [customView retain];
		[self createControls];
	}
	return self;
}

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setTimeZone:(NSTimeZone*)timeZone
{
	if(_datePickerView)
		[_datePickerView setTimeZone:timeZone];
}

- (void)setBbiLeft:(UIBarButtonItem *)bbiLeft
{
	if(_bbiLeft != bbiLeft)
	{
		NSMutableArray *items = [NSMutableArray arrayWithArray:_toolbar.items];
		if(_bbiLeft)
		{
			[_bbiLeft release];
			_bbiLeft = nil;
			[items removeObjectAtIndex:0];
		}
		if(bbiLeft)
		{
			_bbiLeft = [bbiLeft retain];
			[items insertObject:_bbiLeft atIndex:0];
		}
		_toolbar.items = items;
	}
}

- (BOOL)isValue:(NSObject*)val1 equalTo:(NSObject*)val2
{
	if(val1 == val2)
		return YES;
	if(!val1 || !val2)
		return NO;
	NSString *sVal1 = ObjectCast(val1, NSString);
	NSString *sVal2 = ObjectCast(val2, NSString);
	if(sVal1 && sVal2 && [sVal1 isEqual:sVal2])
		return YES;
	if([val1 isEqual:val2])
		return YES;
	return NO;
}

- (NSObject*)value
{
	if(_type == EVLPopupPickerViewTypeDate || _type == EVLPopupPickerViewTypeTime || _type == EVLPopupPickerViewTypeDateAndTime)
		return _datePickerView.date;
	else if(_type == EVLPopupPickerViewTypeCountDownTimer)
		return [NSNumber numberWithDouble:_datePickerView.countDownDuration];
	else if(_type == EVLPopupPickerViewTypeCurrency)
	{
		int dols = (int)[_commonPickerView selectedRowInComponent:0] * kDolsStep;
		int cents = (int)[_commonPickerView selectedRowInComponent:1] * kCentsStep;
		double dbl = dols + cents / 100.0;
		NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:dbl] decimalValue]];
		return num;
	}
	else if(_commonPickerView)
	{
		int index = (int)[_commonPickerView selectedRowInComponent:0];
		NSObject *val = [_valuesArray objectAtIndex:index];
		return val;
	}
	else if(_textViewPicker)
		return _textViewPicker.text;
	else if(_textFieldPicker)
		return _textFieldPicker.text;
	return nil;
}
- (void)setValue:(NSObject*)value
{
	NSDate *valDate = ObjectCast(value, NSDate);
	NSNumber *valNum = ObjectCast(value, NSNumber);
	NSString *valStr = ObjectCast(value, NSString);
	if(_type == EVLPopupPickerViewTypeDate || _type == EVLPopupPickerViewTypeTime || _type == EVLPopupPickerViewTypeDateAndTime)
		_datePickerView.date = valDate;
	else if(_type == EVLPopupPickerViewTypeCountDownTimer)
	{
		NSTimeInterval valInterval = [valNum doubleValue];
		_datePickerView.countDownDuration = valInterval;
	}
	else if(_type == EVLPopupPickerViewTypeCurrency)
	{
		NSDecimalNumber *num = ObjectCast(value, NSDecimalNumber);
		double dblVal = round([num doubleValue] * 100.0) / 100.0;
		long dols = (round(dblVal*100) + 0.1) / 100;
		int cents = round( (dblVal - dols) * 100.0 );
		[_commonPickerView selectRow: MIN((dols / kDolsStep), kDolsCount-1) inComponent:0 animated:NO];
		[_commonPickerView selectRow: MIN((cents / kCentsStep), kCentsCount-1) inComponent:1 animated:NO];
	}
	else if(_commonPickerView)
	{
		for(int i = 0; i < [_valuesArray count]; i++)
		{
			if([self isValue:[_valuesArray objectAtIndex:i] equalTo:value])
			{
				[_commonPickerView selectRow:i inComponent:0 animated:NO];
				break;
			}
		}
	}
	else if(_textViewPicker)
		_textViewPicker.text = valStr ? valStr : @"";
	else if(_textFieldPicker)
		_textFieldPicker.text = valStr ? valStr : @"";
}

- (int)selectedItemIndex
{
	if(_commonPickerView && [_valuesArray count])
	{
		return (int)[_commonPickerView selectedRowInComponent:0];
	}
	return -1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	if(_type == EVLPopupPickerViewTypeCurrency)
		return 2;
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(_type == EVLPopupPickerViewTypeCurrency)
	{
		if(component == 0)
			return kDolsCount;
		else
			return kCentsCount;
	}
	return [_valuesArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(_type == EVLPopupPickerViewTypeCurrency)
	{
		if(component == 0)
			return [NSString stringWithFormat:@"%@ %d", _currencySymbol, (int)row];
		else
			return [NSString stringWithFormat:@".%02d", (int)row];
	}
	NSObject *val = [_valuesArray objectAtIndex:row];
	NSString *sVal = nil;
	if(_titleForValueBlock)
	{
		sVal = _titleForValueBlock(val);
		if(sVal)
			return sVal;
	}
	sVal = ObjectCast(val, NSString);
	if(sVal)
		return sVal;
	return [val description];
}

- (void)updateFrame
{
	if(self.superview)
		self.frame = self.superview.bounds;
	[self layoutSubviews];
}

- (void)onResult:(BOOL)done
{
	if(_titleForValueBlock)
	{
		Block_release(_titleForValueBlock);
		_titleForValueBlock = nil;
	}
	VLPopupPickerView_ResultBlock resultBlockInt = Block_copy(_resultBlock);
	Block_release(_resultBlock);
	_resultBlock = nil;
	resultBlockInt(done, done ? self.value : nil);
	Block_release(resultBlockInt);
}

- (BOOL)isPickerViewTextual
{
	return (ObjectCast(_pickerViewRef, UITextField) || ObjectCast(_pickerViewRef, UITextView));
}

- (void)showWithResultBlock:(VLPopupPickerView_ResultBlock)resultBlock
{
	[VLCtrlsUtils findAndResignFirstResponder:[UIApplication sharedApplication].keyWindow];
	_isDone = NO;
	_isCanceled = NO;
	_resultBlock = Block_copy(resultBlock);
	
	_pickerSlideStage = 0;
	
	UIView *parentView = nil;
	UIViewController *parVC = [[VLAppDelegateBase sharedAppDelegateBase] topModalViewController];
	parentView = parVC.view;
	if(!parentView)
	{
		UIWindow *wnd = [[UIApplication sharedApplication] keyWindow];
		parentView = wnd;
	}
	[parentView addSubview:self];
	[self updateFrame];
	
	self.hidden = NO;
	_viewOverlay.alpha = kOverlayAlphaStart;
	_viewBack.alpha = kBackAlphaStart;
	[self layoutSubviews];
	
	[UIView beginAnimations:@"VLPopupPickerView_SlidePickerUp" context:self];
	[UIView setAnimationDuration:kAnimationDuration];
	_pickerSlideStage = 1;
	_viewOverlay.alpha = kOverlayAlphaEnd;
	_viewBack.alpha = kBackAlphaEnd;
	[self layoutSubviews];
	[UIView commitAnimations];
	
	if([self isPickerViewTextual]//[[_pickerViewRef class] conformsToProtocol:@protocol(UITextInput)]
	   && [_pickerViewRef respondsToSelector:@selector(becomeFirstResponder)])
		[_pickerViewRef performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:kAnimationDuration*1.1];
}

- (void)closePickerWithDelay
{
	[self autorelease];
	[self removeFromSuperview];
}

- (void)closePicker
{
	self.userInteractionEnabled = NO;
	[UIView beginAnimations:@"VLPopupPickerView_SlidePickerDown" context:self];
	[UIView setAnimationDuration:kAnimationDuration];
	_pickerSlideStage = 2;
	_viewOverlay.alpha = kOverlayAlphaStart;
	_viewBack.alpha = kBackAlphaStart;
	[self layoutSubviews];
	[UIView commitAnimations];
	[self retain];
	[self performSelector:@selector(closePickerWithDelay) withObject:nil afterDelay:kAnimationDuration*1.1];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	
	CGRect rcOverlay = rcBnds;
	
	CGRect rcPicker = rcBnds;
	if(_textViewPicker)
		rcPicker.size.height = kTextViewHeight + 2*kTextViewBorder;
	else if(_textFieldPicker)
		rcPicker.size.height = kTextFieldHeight + 2*kTextFieldBorder;
	else
	{
		//rcPicker = _pickerViewRef.frame;
		rcPicker.size = [_pickerViewRef sizeThatFits:rcPicker.size];
		if(kIosVersionFloat >= 7.0) // Fix fo iOS7
			rcPicker.size.width = rcBnds.size.width;
		//rcPicker.size.width = MAX(rcPicker.size.width, rcBnds.size.width/2);
	}
	rcPicker.origin.x = round(CGRectGetMidX(rcBnds) - rcPicker.size.width/2);
	rcPicker.origin.y = CGRectGetMaxY(rcBnds) - rcPicker.size.height;
	
	CGRect rcToolbar = rcBnds;
	rcToolbar.size = [_toolbar sizeThatFits:rcToolbar.size];
	rcToolbar.size.width = rcBnds.size.width;
	
	CGRect rcCtrls = rcBnds;
	rcCtrls.size.height = rcPicker.size.height + rcToolbar.size.height;
	BOOL showOnTop = [self isPickerViewTextual];//[[_pickerViewRef class] conformsToProtocol:@protocol(UITextInput)];
	if(showOnTop)
	{
		rcCtrls.origin.y = rcBnds.origin.y;
		rcPicker.origin.y = rcCtrls.origin.y;
		rcToolbar.origin.y = CGRectGetMaxY(rcPicker);
	}
	else
	{
		rcCtrls.origin.y = CGRectGetMaxY(rcBnds) - rcCtrls.size.height;
		rcPicker.origin.y = rcCtrls.origin.y + rcToolbar.size.height;
		rcToolbar.origin.y = rcPicker.origin.y - rcToolbar.size.height;
	}
	
	if(_pickerSlideStage == 0 || _pickerSlideStage == 2)
	{
		float dH = rcPicker.size.height + rcToolbar.size.height;
		if(showOnTop)
		{
			rcPicker.origin.y -= dH;
			rcToolbar.origin.y -= dH;
		}
		else
		{
			rcPicker.origin.y += dH;
			rcToolbar.origin.y += dH;
		}
	}
	
	if(showOnTop)
	{
		rcOverlay.origin.y = CGRectGetMaxY(rcCtrls);
		rcOverlay.size.height = CGRectGetMaxY(rcBnds) - CGRectGetMaxY(rcCtrls);
	}
	else
	{
		rcOverlay.size.height = rcCtrls.origin.y - rcOverlay.origin.y;
	}
	
	_viewOverlay.frame = rcOverlay;
	_viewBack.frame = rcCtrls;
	if(_textViewPicker)
		rcPicker = CGRectInset(rcPicker, kTextViewBorder, kTextViewBorder);
	if(_textFieldPicker)
		rcPicker = CGRectInset(rcPicker, kTextFieldBorder, kTextFieldBorder);
	_pickerViewRef.frame = rcPicker;
	_toolbar.frame = rcToolbar;
	_lbTitle.frame = rcToolbar;
}

- (void)willRotateToInterfaceOrientation:(id)sender
{
	[self updateFrame];
}

- (void)onCancel:(id)sender
{
	_isCanceled = YES;
	[[self retain] autorelease];
	[self closePicker];
	[self onResult:NO];
}

- (void)onDone:(id)sender
{
	_isDone = YES;
	[[self retain] autorelease];
	[self closePicker];
	[self onResult:YES];
}

- (void)hide
{
	[self onCancel:self];
}

- (NSString *)title {
	return _lbTitle.text;
}

- (void)setTitle:(NSString *)title {
	_lbTitle.text = title;
}

- (void)dealloc
{
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation removeObserver:self];
	if(_titleForValueBlock)
	{
		Block_release(_titleForValueBlock);
		_titleForValueBlock = nil;
	}
	[_datePickerView release];
	[_commonPickerView release];
	[_textViewPicker release];
	[_textFieldPicker release];
	[_customView release];
	[_toolbar release];
	[_lbTitle release];
	[_viewOverlay release];
	[_viewBack release];
	[_valuesArray release];
	[_currencySymbol release];
	[_bbiLeft release];
	[_bbiRight release];
	[super dealloc];
}

@end

