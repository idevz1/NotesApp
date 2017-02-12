
#import "VLInputAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "../Common/Classes.h"

#define kVLIVLogEvents NO//YES

@interface VLInputAlertOverlayWindow : UIWindow
{
}
@property (nonatomic,retain) UIWindow* oldKeyWindow;
@end

@implementation  VLInputAlertOverlayWindow
@synthesize oldKeyWindow;

- (void) makeKeyAndVisible
{
	self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
	self.windowLevel = UIWindowLevelAlert;
	[super makeKeyAndVisible];
}

- (void) resignKeyWindow
{
	[super resignKeyWindow];
	[self.oldKeyWindow makeKeyWindow];
}

- (void) drawRect: (CGRect) rect
{
	// render the radial gradient behind the alertview
	
	CGFloat width			= self.frame.size.width;
	CGFloat height			= self.frame.size.height;
	CGFloat locations[3]	= { 0.0, 0.5, 1.0 	};
	CGFloat components[12]	= {	1, 1, 1, 0.5,
		0, 0, 0, 0.5,
		0, 0, 0, 0.7	};
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef backgroundGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 3);
	CGColorSpaceRelease(colorspace);
	
	CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), 
								backgroundGradient, 
								CGPointMake(width/2, height/2), 0,
								CGPointMake(width/2, height/2), width,
								0);
	
	CGGradientRelease(backgroundGradient);
}

- (void) dealloc
{
	self.oldKeyWindow = nil;
	
	if(kVLIVLogEvents)
		NSLog( @"VLInputAlertView: VLInputAlertOverlayWindow dealloc" );
	
	[super dealloc];
}

@end

@interface VLInputAlertView (private)
@property (nonatomic, readonly) NSMutableArray* buttons;
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, readonly) UILabel* messageLabel;
@property (nonatomic, readonly) UITextView* messageTextView;
- (void) VLInputAlertView_commonInit;
- (void) releaseWindow: (int) buttonIndex;
- (void) pulse;
- (CGSize) titleLabelSize;
- (CGSize) messageLabelSize;
- (CGSize) inputTextFieldSize;
- (CGSize) buttonsAreaSize_Stacked;
- (CGSize) buttonsAreaSize_SideBySide;
- (CGSize) recalcSizeAndLayout: (BOOL) layout;
@end

@interface VLInputAlertViewController : UIViewController
{
}
@end

@implementation VLInputAlertViewController
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	VLInputAlertView* av = [self.view.subviews lastObject];
	if (!av || ![av isKindOfClass:[VLInputAlertView class]])
		return;
	// resize the alertview if it wants to make use of any extra space (or needs to contract)
	[UIView animateWithDuration:duration 
					 animations:^{
						 [av sizeToFit];
						 av.center = CGPointMake( CGRectGetMidX( self.view.bounds ), CGRectGetMidY( self.view.bounds ) );;
						 av.frame = CGRectIntegral( av.frame );
					 }];
}

- (void) dealloc
{
	if(kVLIVLogEvents)
		NSLog( @"VLInputAlertView: VLInputAlertViewController dealloc" );
	[super dealloc];
}

@end


@implementation VLInputAlertView

@synthesize delegate;
@synthesize cancelButtonIndex;
@synthesize firstOtherButtonIndex;
@synthesize returnKeyDoneTargetButtonIndex;
@synthesize buttonLayout;
@synthesize width;
@synthesize maxHeight;
@synthesize usesMessageTextView;
@synthesize backgroundImage = _backgroundImage;
@synthesize style;
@synthesize focusFirstNonEmptyTextField;
@synthesize inputTextFieldIndexToFocus;

const CGFloat kVLInputAlertView_LeftMargin	= 10.0;
const CGFloat kVLInputAlertView_TopMargin	= 16.0;
const CGFloat kVLInputAlertView_BottomMargin = 15.0;
const CGFloat kVLInputAlertView_RowMargin	= 5.0;
const CGFloat kVLInputAlertView_ColumnMargin = 10.0;

- (id) init 
{
	if ( ( self = [super init] ) )
	{
		[self VLInputAlertView_commonInit];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ( ( self = [super initWithFrame: frame] ) )
	{
		[self VLInputAlertView_commonInit];
		
		if ( !CGRectIsEmpty( frame ) )
		{
			width = frame.size.width;
			maxHeight = frame.size.height;
		}
	}
	return self;
}

- (id) initWithTitle: (NSString *) t message: (NSString *) m delegate: (id) d cancelButtonTitle: (NSString *) cancelButtonTitle otherButtonTitles: (NSString *) otherButtonTitles, ...
{
	self = [super init]; // will call into initWithFrame, thus VLInputAlertView_commonInit is called
	if(self)
	{
		self.title = t;
		self.message = m;
		self.delegate = d;
		
		if ( nil != cancelButtonTitle )
		{
			[self addButtonWithTitle: cancelButtonTitle ];
			self.cancelButtonIndex = 0;
		}
		
		if ( nil != otherButtonTitles )
		{
			firstOtherButtonIndex = [self.buttons count];
			[self addButtonWithTitle: otherButtonTitles ];
			
			va_list args;
			va_start(args, otherButtonTitles);
			
			id arg;
			while ( nil != ( arg = va_arg( args, id ) ) ) 
			{
				if ( ![arg isKindOfClass: [NSString class] ] )
					return nil;
				
				[self addButtonWithTitle: (NSString*)arg ];
			}
		}
	}
	
	return self;
}

+ (UIView*)findFirstResponder:(UIView*)parentView
{
	if(!parentView)
		return nil;
	if([parentView isFirstResponder])
		return parentView;
	for(UIView *view in [parentView subviews])
	{
		UIView *v = [VLInputAlertView findFirstResponder:view];
		if(v)
			return v;
	}
	return nil;
}

+ (void)findAndResignFirstResponder:(UIView*)parentView
{
	UIView *view = [self findFirstResponder:parentView];
	if([view isFirstResponder])
		[view resignFirstResponder];
}

- (CGSize) sizeThatFits: (CGSize) unused 
{
	CGSize s = [self recalcSizeAndLayout: NO];
	return s;
}

- (void) layoutSubviews
{
	[self recalcSizeAndLayout: YES];
}

- (void) drawRect:(CGRect)rect
{
	[self.backgroundImage drawInRect: rect];
}

- (void)dealloc 
{
	if(_resultBlock)
		Block_release(_resultBlock);
	[_backgroundImage release];
	[_buttons release];
	[_inputTitleLabels release];
	[_inputTextFields release];
	[_titleLabel release];
	[_messageLabel release];
	[_messageTextView release];
	[_messageTextViewMaskImageView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self ];
	
	if(kVLIVLogEvents)
		NSLog( @"VLInputAlertView: VLInputAlertOverlayWindow dealloc" );
	
    [super dealloc];
}


- (void) VLInputAlertView_commonInit
{
	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin; 
	
	// defaults:
	style = VLInputAlertViewStyleNormal;
	self.width = 0; // set to default
	self.maxHeight = 0; // set to default
	buttonLayout = VLInputAlertViewButtonLayoutNormal;
	cancelButtonIndex = -1;
	firstOtherButtonIndex = -1;
	returnKeyDoneTargetButtonIndex = -1;
	inputTextFieldIndexToFocus = -1;
}

- (void) setWidth:(CGFloat) w
{
	if ( w <= 0 )
		w = 284;
	
	width = MAX( w, self.backgroundImage.size.width );
}

- (CGFloat) width
{
	if ( nil == self.superview )
		return width;
	
	CGFloat maxWidth = self.superview.bounds.size.width - 20;
	
	return MIN( width, maxWidth );
}

- (void) setMaxHeight:(CGFloat) h
{
	if ( h <= 0 )
		h = 358;
	
	maxHeight = MAX( h, self.backgroundImage.size.height );
}

- (CGFloat) maxHeight
{
	if ( nil == self.superview )
		return maxHeight;
	
	return MIN( maxHeight, self.superview.bounds.size.height - 20 );
}

- (void) setStyle:(VLInputAlertViewStyle)newStyle
{
	if ( style != newStyle )
	{
		style = newStyle;
		
		if ( style == VLInputAlertViewStyleInput )
		{
			// need to watch for keyboard
			[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector( onKeyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
			[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector( onKeyboardWillHide:) name: UIKeyboardWillHideNotification object: nil];
		}
	}
}

- (void) onKeyboardWillShow: (NSNotification*) note
{
	NSValue* v = [note.userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
	CGRect kbframe = [v CGRectValue];
	kbframe = [self.superview convertRect: kbframe fromView: nil];
	
	if ( CGRectIntersectsRect( self.frame, kbframe) )
	{
		CGPoint c = self.center;
		
		if ( self.frame.size.height > kbframe.origin.y - 20 )
		{
			self.maxHeight = kbframe.origin.y - 20;
			[self sizeToFit];
			[self layoutSubviews];
		}
		
		c.y = kbframe.origin.y / 2;
		
		[UIView animateWithDuration: 0.2 
						 animations: ^{
							 self.center = c;
							 self.frame = CGRectIntegral(self.frame);
						 }];
	}
}

- (void) onKeyboardWillHide: (NSNotification*) note
{
	[UIView animateWithDuration: 0.2 
					 animations: ^{
						 self.center = CGPointMake( CGRectGetMidX( self.superview.bounds ), CGRectGetMidY( self.superview.bounds ));
						 self.frame = CGRectIntegral(self.frame);
					 }];
}

- (NSMutableArray*) buttons
{
	if ( _buttons == nil )
	{
		_buttons = [[NSMutableArray arrayWithCapacity:4] retain];
	}
	
	return _buttons;
}

- (UILabel*) titleLabel
{
	if ( _titleLabel == nil )
	{
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.font = [UIFont boldSystemFontOfSize: 18];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_titleLabel.numberOfLines = 0;
	}
	
	return _titleLabel;
}

- (UILabel*) messageLabel
{
	if ( _messageLabel == nil )
	{
		_messageLabel = [[UILabel alloc] init];
		_messageLabel.font = [UIFont systemFontOfSize: 16];
		_messageLabel.backgroundColor = [UIColor clearColor];
		_messageLabel.textColor = [UIColor whiteColor];
		_messageLabel.textAlignment = NSTextAlignmentCenter;
		_messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_messageLabel.numberOfLines = 0;
	}
	
	return _messageLabel;
}

- (UITextView*) messageTextView
{
	if ( _messageTextView == nil )
	{
		_messageTextView = [[UITextView alloc] init];
		_messageTextView.editable = NO;
		_messageTextView.font = [UIFont systemFontOfSize: 16];
		_messageTextView.backgroundColor = [UIColor whiteColor];
		_messageTextView.textColor = [UIColor darkTextColor];
		_messageTextView.textAlignment = NSTextAlignmentLeft;
		_messageTextView.bounces = YES;
		_messageTextView.alwaysBounceVertical = YES;
		_messageTextView.layer.cornerRadius = 5;
	}
	
	return _messageTextView;
}

- (UIImageView*) messageTextViewMaskView
{
	if ( _messageTextViewMaskImageView == nil )
	{
		UIImage* shadowImage = [[UIImage imageNamed:@"VLInputAlertViewMessageListViewShadow.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:7];
		
		_messageTextViewMaskImageView = [[UIImageView alloc] initWithImage: shadowImage];
		_messageTextViewMaskImageView.userInteractionEnabled = NO;
		_messageTextViewMaskImageView.layer.masksToBounds = YES;
		_messageTextViewMaskImageView.layer.cornerRadius = 6;
	}
	return _messageTextViewMaskImageView;
}

- (NSArray*) inputTextFields
{
	if ( _inputTextFields == nil )
		_inputTextFields = [[NSMutableArray alloc] init];
	if ( _inputTitleLabels == nil )
		_inputTitleLabels = [[NSMutableArray alloc] init];
	return _inputTextFields;
}

- (UITextField*)addInputTextFieldWithTitle:(NSString*)title
{
	if ( _inputTextFields == nil )
		[self inputTextFields];
	
	UITextField *inputTextField = [[[UITextField alloc] init] autorelease];
	inputTextField.borderStyle = UITextBorderStyleRoundedRect;
	[_inputTextFields addObject:inputTextField];
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.font = [UIFont systemFontOfSize: 16];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 1;
	label.adjustsFontSizeToFitWidth = YES;
	label.text = title ? title : @"";
	[_inputTitleLabels addObject:label];
	
	return inputTextField;
}

- (UITextField*)addInputTextFieldWithPlaceholder:(NSString*)placeholder
{
	UITextField *field = [self addInputTextFieldWithTitle:@""];
	field.placeholder = placeholder;
	return field;
}

- (UITextField*) inputTextField
{
	if ( _inputTextFields == nil )
		[self inputTextFields];
	if(_inputTextFields.count == 0)
		[self addInputTextFieldWithTitle:@""];
	return [_inputTextFields objectAtIndex:0];
}

- (void)chainInputTextFields
{
	if(!_inputTextFields)
		return;
	for(int i = 0; i < _inputTextFields.count; i++)
	{
		UITextField *field = [_inputTextFields objectAtIndex:i];
		field.delegate = self;
		if(i < _inputTextFields.count - 1)
			field.returnKeyType = UIReturnKeyNext;
		else
			field.returnKeyType = UIReturnKeyDone;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(!_inputTextFields)
		return NO;
	NSUInteger index = [_inputTextFields indexOfObject:textField];
	if(index == NSNotFound)
		return NO;
	if(index < _inputTextFields.count - 1)
	{
		UITextField *fieldNext = [_inputTextFields objectAtIndex:index+1];
		[fieldNext becomeFirstResponder];
	}
	else
	{
		[textField resignFirstResponder];
		if(textField.returnKeyType == UIReturnKeyDone && returnKeyDoneTargetButtonIndex >= 0)
		{
			[self onButtonPress:[_buttons objectAtIndex:returnKeyDoneTargetButtonIndex]];
		}
	}
	return NO;
}

- (UITextField *)inputTextFieldAtIndex:(int)index
{
	return [_inputTextFields objectAtIndex:index];
}

- (UITextField *)lastInputTextField
{
	return [_inputTextFields lastObject];
}

- (UIImage*) backgroundImage
{
	if ( _backgroundImage == nil )
	{
		self.backgroundImage = [[UIImage imageNamed: @"VLInputAlertViewBackground.png"] stretchableImageWithLeftCapWidth: 15 topCapHeight: 30];
	}
	
	return _backgroundImage;
}

- (void) setTitle:(NSString *)t
{
	self.titleLabel.text = t;
}

- (NSString*) title 
{
	return self.titleLabel.text;
}

- (void) setMessage:(NSString *)t
{
	self.messageLabel.text = t;
	self.messageTextView.text = t;
}

- (NSString*) message  
{
	return self.messageLabel.text;
}

- (NSInteger) numberOfButtons
{
	return [self.buttons count];
}

- (void) setCancelButtonIndex:(NSInteger)buttonIndex
{
	// avoid a NSRange exception
	if ( buttonIndex < 0 || buttonIndex >= [self.buttons count] )
		return;
	
	cancelButtonIndex = buttonIndex;
	
	UIButton* b = [self.buttons objectAtIndex: buttonIndex];
	
	UIImage* buttonBgNormal = [UIImage imageNamed: @"VLInputAlertViewCancelButtonBackground.png"];
	buttonBgNormal = [buttonBgNormal stretchableImageWithLeftCapWidth: buttonBgNormal.size.width / 2.0 topCapHeight: buttonBgNormal.size.height / 2.0];
	[b setBackgroundImage: buttonBgNormal forState: UIControlStateNormal];
	
	UIImage* buttonBgPressed = [UIImage imageNamed: @"VLInputAlertViewButtonBackground_Highlighted.png"];
	buttonBgPressed = [buttonBgPressed stretchableImageWithLeftCapWidth: buttonBgPressed.size.width / 2.0 topCapHeight: buttonBgPressed.size.height / 2.0];
	[b setBackgroundImage: buttonBgPressed forState: UIControlStateHighlighted];
}

- (BOOL) isVisible
{
	return self.superview != nil;
}

- (NSInteger) addButtonWithTitle: (NSString *) t
{
	UIButton* b = [UIButton buttonWithType: UIButtonTypeCustom];
	[b setTitle: t forState: UIControlStateNormal];
	
	UIImage* buttonBgNormal = [UIImage imageNamed: @"VLInputAlertViewButtonBackground.png"];
	buttonBgNormal = [buttonBgNormal stretchableImageWithLeftCapWidth: buttonBgNormal.size.width / 2.0 topCapHeight: buttonBgNormal.size.height / 2.0];
	[b setBackgroundImage: buttonBgNormal forState: UIControlStateNormal];
	
	UIImage* buttonBgPressed = [UIImage imageNamed: @"VLInputAlertViewButtonBackground_Highlighted.png"];
	buttonBgPressed = [buttonBgPressed stretchableImageWithLeftCapWidth: buttonBgPressed.size.width / 2.0 topCapHeight: buttonBgPressed.size.height / 2.0];
	[b setBackgroundImage: buttonBgPressed forState: UIControlStateHighlighted];
	
	[b addTarget: self action: @selector(onButtonPress:) forControlEvents: UIControlEventTouchUpInside];
	
	[self.buttons addObject: b];
	
	[self setNeedsLayout];
	
	return self.buttons.count-1;
}

- (NSString *) buttonTitleAtIndex:(NSInteger)buttonIndex
{
	// avoid a NSRange exception
	if ( buttonIndex < 0 || buttonIndex >= [self.buttons count] )
		return nil;
	
	UIButton* b = [self.buttons objectAtIndex: buttonIndex];
	
	return [b titleForState: UIControlStateNormal];
}

- (void) dismissWithClickedButtonIndex: (NSInteger)buttonIndex animated: (BOOL) animated
{
	[self retain];
	
	if ( self.style == VLInputAlertViewStyleInput )
	{
		[VLInputAlertView findAndResignFirstResponder:self];
	}
	
	if ( [self.delegate respondsToSelector: @selector(alertView:willDismissWithButtonIndex:)] )
	{
		[self.delegate alertView: self willDismissWithButtonIndex: buttonIndex ];
	}
	
	if ( animated )
	{
		self.window.backgroundColor = [UIColor clearColor];
		self.window.alpha = 1;
		
		[UIView animateWithDuration: 0.2 
						 animations: ^{
							 [self.window resignKeyWindow];
							 self.window.alpha = 0;
						 }
						 completion: ^(BOOL finished) {
							 [self releaseWindow:(int)buttonIndex];
						 }];
		
		[UIView commitAnimations];
	}
	else
	{
		[self.window resignKeyWindow];
		
		[self releaseWindow:(int)buttonIndex];
	}
	
	if(_resultBlock)
	{
		VLInputAlertView_ClickResultBlock resultBlock = Block_copy(_resultBlock);
		Block_release(_resultBlock);
		_resultBlock = nil;
		if(buttonIndex >= 0)
			resultBlock((int)buttonIndex, [self buttonTitleAtIndex:buttonIndex]);
		else
			resultBlock(-1, @"");
		Block_release(resultBlock);
		[self autorelease];
	}
	
	[self autorelease];
}

- (void) releaseWindow: (int) buttonIndex
{
	if ( [self.delegate respondsToSelector: @selector(alertView:didDismissWithButtonIndex:)] )
	{
		[self.delegate alertView: self didDismissWithButtonIndex: buttonIndex ];
	}
	
	// the one place we release the window we allocated in "show"
	// this will propogate releases to us (VLInputAlertView), and our VLInputAlertViewController
	
	//[self.window release];
	[_ow release];
	_ow = nil;
}

- (void) show
{
	[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
	
	VLInputAlertViewController* avc = [[[VLInputAlertViewController alloc] init] autorelease];
	avc.view.backgroundColor = [UIColor clearColor];
	
	// $important - the window is released only when the user clicks an alert view button
	_ow = [[VLInputAlertOverlayWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
	_ow.alpha = 0.0;
	_ow.backgroundColor = [UIColor clearColor];
	_ow.rootViewController = avc;
	[_ow makeKeyAndVisible];
	
	// fade in the window
	[UIView animateWithDuration: 0.2 animations: ^{
		_ow.alpha = 1;
	}];
	
	// add and pulse the alertview
	// add the alertview
	[avc.view addSubview: self];
	[self sizeToFit];
	self.center = CGPointMake( CGRectGetMidX( avc.view.bounds ), CGRectGetMidY( avc.view.bounds ) );;
	self.frame = CGRectIntegral( self.frame );
	[self pulse];
	
	if ( self.style == VLInputAlertViewStyleInput )
	{
		[self layoutSubviews];
		if(_inputTextFields)
		{
			if(_inputTextFields.count == 1)
				[self.inputTextField becomeFirstResponder];
			else if(focusFirstNonEmptyTextField)
			{
				for(UITextField *field in _inputTextFields)
				{
					if(field.text.length == 0)
					{
						[field becomeFirstResponder];
						break;
					}
				}
			}
			else if(inputTextFieldIndexToFocus >= 0 && inputTextFieldIndexToFocus < _inputTextFields.count)
				[[self inputTextFieldAtIndex:inputTextFieldIndexToFocus] becomeFirstResponder];
		}
	}
}

- (void)showWithResultBlock:(VLInputAlertView_ClickResultBlock)resultBlock
{
	[self retain];
	self.delegate = self;
	if(_resultBlock)
		Block_release(_resultBlock);
	_resultBlock = Block_copy(resultBlock);
	[self show];
}

- (void) pulse
{
	// pulse animation thanks to:  http://delackner.com/blog/2009/12/mimicking-uialertviews-animated-transition/
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
	[UIView animateWithDuration: 0.2 
					 animations: ^{
						 self.transform = CGAffineTransformMakeScale(1.1, 1.1);
					 }
					 completion: ^(BOOL finished){
						 [UIView animateWithDuration:1.0/15.0
										  animations: ^{
											  self.transform = CGAffineTransformMakeScale(0.9, 0.9);
										  }
										  completion: ^(BOOL finished){
											  [UIView animateWithDuration:1.0/7.5
															   animations: ^{
																   self.transform = CGAffineTransformIdentity;
															   }];
										  }];
					 }];
	
}

- (void) onButtonPress: (id) sender
{
	int buttonIndex = (int)[_buttons indexOfObjectIdenticalTo: sender];
	
	if ( [self.delegate respondsToSelector: @selector(alertView:clickedButtonAtIndex:)] )
	{
		[self.delegate alertView: self clickedButtonAtIndex: buttonIndex ];
	}
	
	if ( buttonIndex == self.cancelButtonIndex )
	{
		if ( [self.delegate respondsToSelector: @selector(alertViewCancel:)] )
		{
			[self.delegate alertViewCancel: self ];
		}	
	}
	
	[self dismissWithClickedButtonIndex: buttonIndex  animated: YES];
}

- (CGSize) recalcSizeAndLayout: (BOOL) layout
{
	BOOL	stacked = !(self.buttonLayout == VLInputAlertViewButtonLayoutNormal && [self.buttons count] == 2 );
	
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	
	CGSize  titleLabelSize = [self titleLabelSize];
	CGSize  messageViewSize = [self messageLabelSize];
	CGSize  inputTextFieldSize = [self inputTextFieldSize];
	CGSize  buttonsAreaSize = stacked ? [self buttonsAreaSize_Stacked] : [self buttonsAreaSize_SideBySide];
	
	CGFloat inputRowHeight = 0;
	if(self.style == VLInputAlertViewStyleInput)
	{
		[self inputTextFields];
		for(int i = 0; i < _inputTextFields.count; i++)
		{
			UILabel *label = [_inputTitleLabels objectAtIndex:i];
			if(label.text && label.text.length)
			{
				CGSize szText = [label.text vlSizeWithFont:label.font];
				inputRowHeight += szText.height;
			}
			else
				inputRowHeight += kVLInputAlertView_RowMargin;
			inputRowHeight += inputTextFieldSize.height;
		}
		inputRowHeight += kVLInputAlertView_RowMargin;
	}
	
	CGFloat totalHeight = kVLInputAlertView_TopMargin + titleLabelSize.height + kVLInputAlertView_RowMargin + messageViewSize.height + inputRowHeight + kVLInputAlertView_RowMargin + buttonsAreaSize.height + kVLInputAlertView_BottomMargin;
	
	float maxHeightVal = self.maxHeight;
	if ( totalHeight > maxHeightVal )
	{
		// too tall - we'll condense by using a textView (with scrolling) for the message
		
		totalHeight -= messageViewSize.height;
		//$$what if it's still too tall?
		messageViewSize.height = self.maxHeight - totalHeight;
		
		totalHeight = self.maxHeight;
		
		self.usesMessageTextView = YES;
	}
	
	if ( layout )
	{
		// title
		CGFloat y = kVLInputAlertView_TopMargin;
		if ( self.title != nil )
		{
			self.titleLabel.frame = CGRectMake( kVLInputAlertView_LeftMargin, y, titleLabelSize.width, titleLabelSize.height );
			[self addSubview: self.titleLabel];
			y += titleLabelSize.height + kVLInputAlertView_RowMargin;
		}
		
		// message
		if ( self.message != nil )
		{
			if ( self.usesMessageTextView )
			{
				self.messageTextView.frame = CGRectMake( kVLInputAlertView_LeftMargin, y, messageViewSize.width, messageViewSize.height );
				[self addSubview: self.messageTextView];
				y += messageViewSize.height + kVLInputAlertView_RowMargin;
				
				UIImageView* maskImageView = [self messageTextViewMaskView];
				maskImageView.frame = self.messageTextView.frame;
				[self addSubview: maskImageView];
			}
			else
			{
				self.messageLabel.frame = CGRectMake( kVLInputAlertView_LeftMargin, y, messageViewSize.width, messageViewSize.height );
				[self addSubview: self.messageLabel];
				y += messageViewSize.height + kVLInputAlertView_RowMargin;
			}
		}
		
		// input
		if ( self.style == VLInputAlertViewStyleInput )
		{
			for(int i = 0; i < _inputTextFields.count; i++)
			{
				UILabel *label = [_inputTitleLabels objectAtIndex:i];
				if(label.superview != self)
					[self addSubview:label];
				float labelHeight = 0;
				if(label.text && label.text.length)
				{
					CGSize szText = [label.text vlSizeWithFont:label.font];
					labelHeight = szText.height;
				}
				else
					labelHeight = (i > 0) ? kVLInputAlertView_RowMargin : 0;
				UITextField *field = [_inputTextFields objectAtIndex:i];
				if(field.superview != self)
					[self addSubview:field];
				
				CGRect rcLabel = CGRectMake( kVLInputAlertView_LeftMargin, y, inputTextFieldSize.width, labelHeight );
				label.frame = rcLabel;
				y += labelHeight;
				
				CGRect rcField = CGRectMake( kVLInputAlertView_LeftMargin, y, inputTextFieldSize.width, inputTextFieldSize.height );
				field.frame = rcField;
				y += inputTextFieldSize.height;
			}
			y += kVLInputAlertView_RowMargin;
		}
		
		// buttons
		CGFloat buttonHeight = [[self.buttons objectAtIndex:0] sizeThatFits: CGSizeZero].height;
		if ( stacked )
		{
			CGFloat buttonWidth = maxWidth;
			float rowMarginY = kVLInputAlertView_RowMargin;
			if(_buttons.count > 2)
			{
				float allButtonsHeight = buttonHeight * _buttons.count + kVLInputAlertView_RowMargin * _buttons.count * (_buttons.count - 1);
				if(y + allButtonsHeight > totalHeight)
				{
					float yScale = (totalHeight - y) / allButtonsHeight;
					buttonHeight = floor(buttonHeight * yScale);
					rowMarginY = floor(rowMarginY * yScale);
				}
			}
			for ( UIButton* b in self.buttons )
			{
				b.frame = CGRectMake( kVLInputAlertView_LeftMargin, y, buttonWidth, buttonHeight );
				[self addSubview: b];
				y += buttonHeight + rowMarginY;
			}
		}
		else
		{
			CGFloat buttonWidth = (maxWidth - kVLInputAlertView_ColumnMargin) / 2.0;
			CGFloat x = kVLInputAlertView_LeftMargin;
			for ( UIButton* b in self.buttons )
			{
				b.frame = CGRectMake( x, y, buttonWidth, buttonHeight );
				[self addSubview: b];
				x += buttonWidth + kVLInputAlertView_ColumnMargin;
			}
		}
		
	}
	
	return CGSizeMake( self.width, totalHeight );
}

- (CGSize) titleLabelSize
{
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	CGSize s = [self.titleLabel.text vlSizeWithFont: self.titleLabel.font constrainedToSize: CGSizeMake(maxWidth, 1000) lineBreakMode: self.titleLabel.lineBreakMode];
	if ( s.width < maxWidth )
		s.width = maxWidth;
	
	return s;
}

- (CGSize) messageLabelSize
{
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	CGSize s = [self.messageLabel.text vlSizeWithFont: self.messageLabel.font constrainedToSize: CGSizeMake(maxWidth, 1000) lineBreakMode: self.messageLabel.lineBreakMode];
	if ( s.width < maxWidth )
		s.width = maxWidth;
	
	return s;
}

- (CGSize) inputTextFieldSize
{
	if ( self.style == VLInputAlertViewStyleNormal)
		return CGSizeZero;
	
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	
	CGSize s = [self.inputTextField sizeThatFits: CGSizeZero];
	
	return CGSizeMake( maxWidth, s.height );
}

- (CGSize) buttonsAreaSize_SideBySide
{
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	
	CGSize bs = [[self.buttons objectAtIndex:0] sizeThatFits: CGSizeZero];
	
	bs.width = maxWidth;
	
	return bs;
}

- (CGSize) buttonsAreaSize_Stacked
{
	CGFloat maxWidth = self.width - (kVLInputAlertView_LeftMargin * 2);
	int buttonCount = (int)[self.buttons count];
	
	CGSize bs = [[self.buttons objectAtIndex:0] sizeThatFits: CGSizeZero];
	
	bs.width = maxWidth;
	
	bs.height = (bs.height * buttonCount) + (kVLInputAlertView_RowMargin * (buttonCount-1));
	
	return bs;
}

@end




