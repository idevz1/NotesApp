//
//  iPadDetailViewController.m
//  iDevz
//
//  Created by George on 4/16/14.
//  Copyright (c) 2014 George Ciobanu. All rights reserved.
//

#import "Classes.h"
#import "YTUiMediator.h"
#import "iPadDetailViewController.h"
#import "iPadDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@class YTNotesTableView;

@interface iPadDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation iPadDetailViewController
@synthesize leftBtn;
@synthesize lbl;
@synthesize auxView;
@synthesize firstView;
@synthesize popOver;
@synthesize popUpView;
@synthesize popUpNav;
@synthesize popUpDetailView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    self.view.clipsToBounds = NO;
    
    auxView = [[UIView alloc]init];
    popUpView = [[UIViewController alloc]init];
    popUpDetailView = [[UIViewController alloc]init];
   // firstView = [[UIView alloc]init]
    popUpNav = [[UINavigationController alloc] initWithRootViewController:popUpView];
    popUpNav.navigationBarHidden = YES;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,64)];
    view.backgroundColor = [UIColor colorWithRed:0x5E/255.0 green:0x7D/255.0 blue:0x9A/255.0 alpha:1.0];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    view2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view2];
    [self.view addSubview:view];

    
}
-(void)viewWillAppear:(BOOL)animated{
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipee)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipee = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipee2)];
    swipee.numberOfTouchesRequired = 1;
    swipee.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipee];
    
}
-(void)swipee2{
    
    if (!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        NSArray *controllers = self.splitViewController.viewControllers;
        UIViewController *rootViewController = [controllers objectAtIndex:0];
        
        UIView *rootView = rootViewController.view;
        CGRect rootFrame = rootView.frame;
        if (rootFrame.origin.x>-320){

        rootFrame.origin.x -= rootFrame.size.width;
        [UIView beginAnimations:@"hideView" context:NULL];
        rootView.frame = rootFrame;
            [UIView commitAnimations];}
    }
}




-(void)swipee{

    if (!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {

    NSArray *controllers = self.splitViewController.viewControllers;
    UIViewController *rootViewController = [controllers objectAtIndex:0];
    
    UIView *rootView = rootViewController.view;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(rootView.frame.size.width-1, 0, 1.5, rootView.frame.size.height)];
        line.backgroundColor = [UIColor darkGrayColor];
        [rootView addSubview:line];
        
    [self.view bringSubviewToFront:rootView];
    CGRect rootFrame = rootView.frame;
        if (rootFrame.origin.x<0){

    rootFrame.origin.x += rootFrame.size.width;
    [UIView beginAnimations:@"showView" context:NULL];
    rootView.frame = rootFrame;
            [UIView commitAnimations];}
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        NSLog(@"Mda");

    } else {
        
        NSLog(@"Mnu");
       
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-    (BOOL)splitViewController: (UISplitViewController*)svc
      shouldHideViewController:(UIViewController *)vc
                 inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



- (void) orientationChanged:(NSNotification *)note
{
    
}



-(void)setSwipe{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipee)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipee = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipee2)];
    swipee.numberOfTouchesRequired = 1;
    swipee.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipee];

    NSArray *controllers = self.splitViewController.viewControllers;
    UIViewController *rootViewController = [controllers objectAtIndex:0];
    
    UIView *rootView = rootViewController.view;
    [self.view bringSubviewToFront:rootView];
    
 
    
 
    
}
-(void)viewDidLayoutSubviews{

}
@end
