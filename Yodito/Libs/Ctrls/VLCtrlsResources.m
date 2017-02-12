
#import "VLCtrlsResources.h"
#import "../System/Classes.h"
#import "VLCtrlsCommon.h"

@implementation VLCtrlsResources

+ (UIFont*)fontTextField
{
	return [VLCtrlsResources setFontTextField:nil];
}
+ (UIFont*)setFontTextField:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(16, 20)] retain]; // Default
	return _value;
}

+ (UIFont*)fontTextFieldBig
{
	return [VLCtrlsResources setFontTextFieldBig:nil];
}
+ (UIFont*)setFontTextFieldBig:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(22, 26)] retain];
	return _value;
}


+ (UIFont*)fontButton
{
	return [VLCtrlsResources setFontButton:nil];
}
+ (UIFont*)setFontButton:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(16, 20)] retain]; // Default
	return _value;
}


+ (UIFont*)fontLabelSmall
{
	return [VLCtrlsResources setFontLabelSmall:nil];
}
+ (UIFont*)setFontLabelSmall:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(10, 14)] retain];
	return _value;
}

+ (UIFont*)fontLabelMedium
{
	return [VLCtrlsResources setFontLabelMedium:nil];
}
+ (UIFont*)setFontLabelMedium:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(16, 20)] retain]; // Default
	return _value;
}
+ (UIFont*)fontLabelMediumBold
{
	return [VLCtrlsResources setFontLabelMediumBold:nil];
}
+ (UIFont*)setFontLabelMediumBold:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont boldSystemFontOfSize:iUiChoice(16, 20)] retain]; // Default
	return _value;
}

+ (UIFont*)fontLabelBig
{
	return [VLCtrlsResources setFontLabelBig:nil];
}
+ (UIFont*)setFontLabelBig:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont systemFontOfSize:iUiChoice(20, 28)] retain]; // Default
	return _value;
}
+ (UIFont*)fontLabelBigBold
{
	return [VLCtrlsResources setFontLabelBigBold:nil];
}
+ (UIFont*)setFontLabelBigBold:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont boldSystemFontOfSize:iUiChoice(20, 28)] retain]; // Default
	return _value;
}

+ (UIFont*)fontBarTitle
{
	return [VLCtrlsResources setFontBarTitle:nil];
}
+ (UIFont*)setFontBarTitle:(UIFont*)value
{
	static UIFont* _value = nil;
	if(value)
	{
		[_value release];
		_value = [value retain];
	}
	if(!_value)
		_value = [[UIFont boldSystemFontOfSize:iUiChoice(20, 20)] retain];
	return _value;
}

@end


