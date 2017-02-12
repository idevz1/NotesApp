
#import "VLSettingsTableCells.h"
#import "VL_UIControls_Categories.h"

@interface VLSettingsCellView()

- (void)onSelectedOrHighlightedChangedInternal:(BOOL)selected;

@end


@implementation VLSettingsTableCell

@synthesize view = _view;

- (id)initWithView:(VLSettingsCellView*)view reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if(self)
	{
		_view = [view retain];
		[self.contentView addSubview:_view];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [self initWithView:[[[VLSettingsCellView alloc] initWithFrame:CGRectZero] autorelease] reuseIdentifier:reuseIdentifier];
	if(self)
	{
	}
	return self;
}

- (id)init {
	self = [self initWithView:[[[VLSettingsCellView alloc] initWithFrame:CGRectZero] autorelease] reuseIdentifier:nil];
	if(self) {
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if(_view)
		_view.frame = self.contentView.bounds;
}

- (void)setSelectedOrHighlightedInternal:(BOOL)selectedOrHighlighted {
	if(_wasSelectedOrHighlighted != selectedOrHighlighted) {
		_wasSelectedOrHighlighted = selectedOrHighlighted;
		if(self.selectionStyle != UITableViewCellSelectionStyleNone) {
			if(_view)
				[_view onSelectedOrHighlightedChangedInternal:selectedOrHighlighted];
		}
	}
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setSelectedOrHighlightedInternal:self.selected || self.highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	[self setSelectedOrHighlightedInternal:self.selected || self.highlighted];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setSelectedOrHighlightedInternal:self.selected || self.highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self setSelectedOrHighlightedInternal:self.selected || self.highlighted];
}

- (void)dealloc
{
	[_view release];
	[super dealloc];
}

@end



@implementation VLSettingsCellView_ColorBox

@synthesize color = _color;

- (void)initialize {
	[super initialize];
	_color = [[UIColor blackColor] retain];
}

- (void)setColor:(UIColor *)color {
	if(!color)
		color = [UIColor blackColor];
	[_color release];
	_color = [color retain];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[_color setFill];
	CGContextFillRect(ctx, rcBnds);
}

- (void)dealloc {
	[_color release];
	[super dealloc];
}

@end



#define kDefaultLabelFont [UIFont boldSystemFontOfSize:16.0]
#define kDefaultPaddings UIEdgeInsetsMake(2, 10, 2, 10)
#define kDistXDefault 12.0

@implementation VLSettingsCellView

@synthesize label = _label;
@synthesize textField = _textField;
@dynamic hasTextField;
@synthesize switcher = _switcher;
@synthesize labelValue = _labelValue;
@synthesize colorBox = _colorBox;
@synthesize msgrValueChanged = _msgrValueChanged;
@synthesize valueWidthWeight = _valueWidthWeight;
@synthesize horizontalControlsDistance = _horizontalControlsDistance;
@synthesize changeLabelsColorsWhenSelectedOrHighlighted = _changeLabelsColorsWhenSelectedOrHighlighted;
@synthesize paddings = _paddings;

- (void)initialize
{
	[super initialize];
	_paddings = kDefaultPaddings;
	_horizontalControlsDistance = kDistXDefault;
	_valueWidthWeight = -1;
	self.backgroundColor = [UIColor clearColor];
	_msgrValueChanged = [[VLMessenger alloc] init];
	_msgrValueChanged.owner = self;
	_label = [[VLLabel alloc] initWithFrame:CGRectZero];
	_label.backgroundColor = [UIColor clearColor];
	_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_label.font = kDefaultLabelFont;
	[self addSubview:_label];
}

- (void)setPaddings:(UIEdgeInsets)paddings {
	if(!UIEdgeInsetsEqualToEdgeInsets(_paddings, paddings)) {
		_paddings = paddings;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, _paddings);
	CGRect rcLabel = rcCtrls;
	rcLabel.size.width = ceil([_label sizeOfText].width);
	CGRect rcValue = rcCtrls;
	rcValue.origin.x = CGRectGetMaxX(rcLabel) + _horizontalControlsDistance;
	rcValue.size.width = CGRectGetMaxX(rcCtrls) - rcValue.origin.x;
	if(_valueWidthWeight >= 0) {
		rcValue.size.width = round(rcCtrls.size.width * _valueWidthWeight);
		rcValue.origin.x = CGRectGetMaxX(rcCtrls) - rcValue.size.width;
	}
	if(_textField)
		_textField.frame = rcValue;
	if(_switcher) {
		CGRect rcSwitch = rcValue;
		rcSwitch.size = [_switcher sizeThatFits:rcSwitch.size];
		rcSwitch.origin.y = CGRectGetMidY(rcValue) - rcSwitch.size.height/2;
		rcSwitch.origin.x = CGRectGetMaxX(rcValue) - rcSwitch.size.width;
		if(CGRectGetMaxX(rcSwitch) > CGRectGetMaxX(rcCtrls))
			rcSwitch.origin.x -= CGRectGetMaxX(rcSwitch) - CGRectGetMaxX(rcCtrls);
		rcSwitch = [UIScreen roundRect:rcSwitch];
		_switcher.frame = rcSwitch;
		rcLabel.size.width = rcSwitch.origin.x - _horizontalControlsDistance - rcLabel.origin.x;
	}
	if(_labelValue)
		_labelValue.frame = rcValue;
	if(_colorBox)
		_colorBox.frame = rcValue;
	_label.frame = rcLabel;
}

- (void)setValueWidthWeight:(float)valueWidthWeight {
	if(_valueWidthWeight != valueWidthWeight) {
		_valueWidthWeight = valueWidthWeight;
		[self setNeedsLayout];
	}
}

- (UITextField*)textField
{
	if(!_textField)
	{
		_textField = [[UITextField alloc] initWithFrame:CGRectZero];
		_textField.borderStyle = UITextBorderStyleNone;
		_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
		_textField.delegate = self;
		_textField.returnKeyType = UIReturnKeyDone;
		[self addSubview:_textField];
		[self setNeedsLayout];
	}
	return _textField;
}

- (BOOL)hasTextField {
	return (_textField != nil);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self onValueChanged];
}

- (UISwitch *)switcher
{
	if(!_switcher)
	{
		_switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
		[_switcher addTarget:self action:@selector(onControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:_switcher];
		[self setNeedsLayout];
	}
	return _switcher;
}

- (VLLabel *)labelValue {
	if(!_labelValue) {
		_labelValue = [[VLLabel alloc] initWithFrame:CGRectZero];
		_labelValue.backgroundColor = [UIColor clearColor];
		_labelValue.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		_labelValue.textAlignment = NSTextAlignmentRight;
		[self addSubview:_labelValue];
		[self setNeedsLayout];
	}
	return _labelValue;
}

- (VLSettingsCellView_ColorBox *)colorBox {
	if(!_colorBox) {
		_colorBox = [[VLSettingsCellView_ColorBox alloc] initWithFrame:CGRectZero];
		[self addSubview:_colorBox];
		[self setNeedsLayout];
	}
	return _colorBox;
}

- (void)onValueChanged
{
	[_msgrValueChanged postMessage];
}

- (void)onControlEventValueChanged:(id)sender
{
	[self onValueChanged];
}

- (void)onSelectedOrHighlightedChangedInternal:(BOOL)selected {
	if(_changeLabelsColorsWhenSelectedOrHighlighted) {
		UIColor *selColor = [UIColor whiteColor];
		if(selected) {
			if(_label) {
				[_lastLabelColor release];
				_lastLabelColor = [_label.textColor retain];
				_label.textColor = selColor;
			}
			if(_labelValue) {
				[_lastLabelValueColor release];
				_lastLabelValueColor = [_labelValue.textColor retain];
				_labelValue.textColor = selColor;
			}
		} else {
			if(_label) {
				if(_lastLabelColor) {
					_label.textColor = _lastLabelColor;
					[_lastLabelColor release];
					_lastLabelColor = nil;
				}
			}
			if(_labelValue) {
				if(_lastLabelValueColor) {
					_labelValue.textColor = _lastLabelValueColor;
					[_lastLabelValueColor release];
					_lastLabelValueColor = nil;
				}
			}
		}
	}
}

- (void)dealloc
{
	[_label release];
	[_textField release];
	[_switcher release];
	[_labelValue release];
	[_colorBox release];
	[_msgrValueChanged release];
	[_lastLabelColor release];
	[_lastLabelValueColor release];
	[super dealloc];
}

@end
