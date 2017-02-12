
#import "VLViewLocalizator.h"
#import "../Common/Classes.h"

@implementation VLViewLocalizator

+ (NSString*)localizedText:(NSString*)text
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *textLoc = [bundle localizedStringForKey:text value:nil table:nil];
	return (textLoc && textLoc.length && ![textLoc isEqual:text]) ? textLoc : text;
}

+ (void)localizeView:(UIView*)view andSubViews:(BOOL)andSubViews
{
	if(!view)
		return;
	UIButton *button = ObjectCast(view, UIButton);
	if(button)
	{
		static UIControlState states[4] = {UIControlStateNormal, UIControlStateHighlighted, UIControlStateDisabled, UIControlStateSelected};
		for(int i = 0; i < 4; i++)
		{
			UIControlState state = states[i];
			[button setTitle:[VLViewLocalizator localizedText:[button titleForState:state]] forState:state];
		}
	}
	UILabel *label = ObjectCast(view, UILabel);
	if(label)
		label.text = [VLViewLocalizator localizedText:label.text];
	UITabBar *tabBar = ObjectCast(view, UITabBar);
	if(tabBar)
	{
		for(UITabBarItem *item in tabBar.items)
			item.title = [VLViewLocalizator localizedText:item.title];
	}
	UINavigationBar *navBar = ObjectCast(view, UINavigationBar);
	if(navBar)
	{
		for(UINavigationItem *item in navBar.items)
			item.title = [VLViewLocalizator localizedText:item.title];
	}
	UIToolbar *toolBar = ObjectCast(view, UIToolbar);
	if(toolBar)
	{
		for(UIBarItem *item in toolBar.items)
		{
			UIBarButtonItem *bbi = ObjectCast(item, UIBarButtonItem);
			if(bbi && bbi.customView)
				[VLViewLocalizator localizeView:bbi.customView andSubViews:andSubViews];
		}
	}
	UITextField *textField = ObjectCast(view, UITextField);
	if(textField)
	{
		if(textField.placeholder)
			textField.placeholder = [VLViewLocalizator localizedText:textField.placeholder];
	}
	UITextView *textView = ObjectCast(view, UITextView);
	if(textView)
		textView.text = [VLViewLocalizator localizedText:textView.text];
	UISearchBar *searchBar = ObjectCast(view, UISearchBar);
	if(searchBar)
	{
		if(searchBar.placeholder)
			searchBar.placeholder = [VLViewLocalizator localizedText:searchBar.placeholder];
	}
	UISegmentedControl *segmCtrl = ObjectCast(view, UISegmentedControl);
	if(segmCtrl)
	{
		for(int i = 0; i < segmCtrl.numberOfSegments; i++)
			[segmCtrl setTitle:[VLViewLocalizator localizedText:[segmCtrl titleForSegmentAtIndex:i]] forSegmentAtIndex:i];
	}
	if(andSubViews)
	{
		for(UIView *subView in view.subviews)
			[VLViewLocalizator localizeView:subView andSubViews:andSubViews];
	}
}

+ (void)localizeViewController:(UIViewController*)vc andSubViews:(BOOL)andSubViews
{
	if([vc isViewLoaded])
		[VLViewLocalizator localizeView:vc.view andSubViews:andSubViews];
	if(vc.tabBarItem)
		vc.tabBarItem.title = [VLViewLocalizator localizedText:vc.tabBarItem.title];
	if(vc.navigationItem)
		vc.navigationItem.title = [VLViewLocalizator localizedText:vc.navigationItem.title];
	if(andSubViews)
	{
		UITabBarController *tbc = ObjectCast(vc, UITabBarController);
		if(tbc)
		{
			for(UIViewController *cvc in tbc.viewControllers)
				[VLViewLocalizator localizeViewController:cvc andSubViews:andSubViews];
			if(tbc.moreNavigationController)
				[VLViewLocalizator localizeViewController:tbc.moreNavigationController andSubViews:andSubViews];
		}
		UINavigationController *nvc = ObjectCast(vc, UINavigationController);
		if(nvc)
		{
			for(UIViewController *cvc in nvc.viewControllers)
				[VLViewLocalizator localizeViewController:cvc andSubViews:andSubViews];
		}
	}
}

@end
