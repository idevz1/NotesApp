
#import <UIKit/UIKit.h>

typedef enum
{
	EVLNumberPickerViewStyleNone,
	EVLNumberPickerViewStyleTextField
}
EVLNumberPickerViewStyle;

@interface VLNumberPickerView : UIView <UITextFieldDelegate>
{
	UIButton *_bnMinus;
	UIButton *_bnPlus;
	UILabel *_label;
	int _minValue;
	int _maxValue;
	int _value;
	int _step;
	UITextField *_tfValue;
	EVLNumberPickerViewStyle _style;
}

@property(nonatomic,assign) int minValue;
@property(nonatomic,assign) int maxValue;
@property(nonatomic,assign) int value;
@property(nonatomic,assign) int step;

- (id)initWithStyle:(EVLNumberPickerViewStyle)style;

- (void)onBnMinusTapped:(id)sender;
- (void)onBnPlusTapped:(id)sender;

+ (UIImage*)imagePlus64;
+ (UIImage*)imageMinus64;

@end
