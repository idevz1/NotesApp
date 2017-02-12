
#import <Foundation/Foundation.h>

@interface VLStringResources : NSObject
{
@private
}

@property(nonatomic, copy) NSString *buttonOK;
@property(nonatomic, copy) NSString *buttonCancel;
@property(nonatomic, copy) NSString *buttonYes;
@property(nonatomic, copy) NSString *buttonNo;
@property(nonatomic, copy) NSString *buttonNext;
@property(nonatomic, copy) NSString *searchBarPlaceholder;
@property(nonatomic, copy) NSString *errorCanceled;

+ (VLStringResources*)shared;

@end
