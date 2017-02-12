
#import <UIKit/UIKit.h>
#import "VLBaseView.h"

@class VLPopupPickerView;

typedef enum
{
	EVLPopupPickerViewTypeNone,
	EVLPopupPickerViewTypeDate,
	EVLPopupPickerViewTypeTime,
	EVLPopupPickerViewTypeDateAndTime,
	EVLPopupPickerViewTypeCountDownTimer,
	EVLPopupPickerViewTypeValuesSet,
	EVLPopupPickerViewTypeCurrency,
	EVLPopupPickerViewTypeText,
	EVLPopupPickerViewTypeString,
	EVLPopupPickerViewTypeCustomView
}
EVLPopupPickerViewType;


typedef void (^VLPopupPickerView_ResultBlock)(BOOL done, id resultVal);
typedef NSString* (^VLPopupPickerView_BlockTitleForValue)(NSObject *value);


@interface VLPopupPickerView : VLBaseView <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate>
{
@private
	EVLPopupPickerViewType _type;
	NSMutableArray *_valuesArray;
	UIDatePicker *_datePickerView;
	UIPickerView *_commonPickerView;
	UITextView *_textViewPicker;
	UITextField *_textFieldPicker;
	UIView *_customView;
	UIView *_pickerViewRef;
	UIToolbar *_toolbar;
	UILabel *_lbTitle;
	int _pickerSlideStage;
	UIView *_viewOverlay;
	UIView *_viewBack;
	NSString *_currencySymbol;
	BOOL _isDone;
	BOOL _isCanceled;
	VLPopupPickerView_ResultBlock _resultBlock;
	VLPopupPickerView_BlockTitleForValue _titleForValueBlock;
	UIBarButtonItem *_bbiLeft;
	UIBarButtonItem *_bbiRight;
}

@property(nonatomic, readonly) EVLPopupPickerViewType type;
@property(nonatomic, assign) NSObject *value;
@property(nonatomic, readonly) int selectedItemIndex;
@property(nonatomic, retain) NSString *currencySymbol;
@property(nonatomic, readonly) UIView *customView;
@property(nonatomic, assign, setter = setBbiLeft:) UIBarButtonItem *bbiLeft;
@property(nonatomic, readonly) UIDatePicker *viewDatePicker;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, readonly) UIToolbar *toolbar;

- (id)initWithType:(EVLPopupPickerViewType)type
	   valuesArray:(NSArray*)valuesArray
	titleForValueBlock:(VLPopupPickerView_BlockTitleForValue)titleForValueBlock;
- (id)initWithType:(EVLPopupPickerViewType)type valuesArray:(NSArray*)valuesArray;
- (id)initWithType:(EVLPopupPickerViewType)type titleForValueBlock:(VLPopupPickerView_BlockTitleForValue)titleForValueBlock;
- (id)initWithType:(EVLPopupPickerViewType)type;
- (id)initWithCustomView:(UIView*)customView;
- (void)setTimeZone:(NSTimeZone*)timeZone;
/**
 Show with result block. 'done' = YES if 'Done' clicked
 */
- (void)showWithResultBlock:(VLPopupPickerView_ResultBlock)resultBlock;
- (void)hide;

@end

