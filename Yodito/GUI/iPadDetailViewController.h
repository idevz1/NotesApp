//
//  iPadDetailViewController.h
//  iDevz
//
//  Created by George on 4/16/14.
//  Copyright (c) 2014 George Ciobanu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "YTNotesTableView.h"
@class YTNotesTableView;


@protocol iPadDetailViewControllerDelegate <NSObject>
@end

@interface iPadDetailViewController : UIViewController <UIAlertViewDelegate, YTNoteViewDelegate, iPadDetailViewControllerDelegate, UISplitViewControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate>
{
    UIViewController *popUpView;
    UIViewController *popUpDetailView;
    UINavigationController *popUpNav;
    UIPopoverController *popOver;
    UIButton *_btnDelete;
	UIButton *_btnAdd;
	UIButton *_btnAction;
    UIPopoverController *_activityPopoverController;
    UITextField *textField;
    YTNoteView *noteView;
    UIView *auxView;
    UIView *firstView;
}
@property (nonatomic, strong) id <iPadDetailViewControllerDelegate> delegate;
@property (strong, nonatomic)YTNoteInfo *note;
@property (strong, nonatomic)IBOutlet UIBarButtonItem *leftBtn;
@property(strong, nonatomic)    YTNoteView *noteView;
@property (strong, atomic)IBOutlet UILabel *lbl;
@property (strong, nonatomic)UIView *auxView;
@property (strong, nonatomic)UIView *firstView;
@property (strong, nonatomic)UIPopoverController *popOver;
@property (strong, nonatomic)UIViewController *popUpView;
@property (strong, nonatomic)UIViewController *popUpDetailView;

@property (strong, nonatomic)    UINavigationController *popUpNav;

-(void)setSwipe;
@end
