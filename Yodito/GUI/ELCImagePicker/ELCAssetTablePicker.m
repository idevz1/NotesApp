//
//  ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import "VLCommon.h"

@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;

@end

@implementation ELCAssetTablePicker

//Using auto synthesizers

- (id)init
{
    self = [super init];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
    self.elcAssets = tempArray;
	
    if (self.immediateReturn) {
        
    } else {
		NSString *title = NSLocalizedString(@"Loading...", nil);
        [self.navigationItem setTitle:title];
		[self updateHeader];
    }

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
}

- (void)updateHeader {
	if(!_bbiDone) {
		_bbiDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	}
	if(!_bbiCancel) {
		_bbiCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneAction:)];
	}
	UIBarButtonItem *bbiRight = nil;
	if([self getSelectedAssets].count > 0) {
		bbiRight = _bbiDone;
	} else {
		bbiRight = _bbiCancel;
	}
	if(self.navigationItem.rightBarButtonItem != bbiRight) {
		if(self.navigationItem.rightBarButtonItem) {
			[self.navigationItem setRightBarButtonItem:bbiRight animated:YES];
		} else {
			[self.navigationItem setRightBarButtonItem:bbiRight];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    @autoreleasepool {

        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result == nil) {
                return;
            }

            ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
            [elcAsset setParent:self];
            
            BOOL isAssetFiltered = NO;
            if (self.assetPickerFilterDelegate &&
               [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
            {
                isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(ELCAsset*)elcAsset];
            }

            if (!isAssetFiltered) {
                [self.elcAssets addObject:elcAsset];
            }

         }];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            // scroll to bottom
            long section = [self numberOfSectionsInTableView:self.tableView] - 1;
            long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
            if (section >= 0 && row >= 0) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:row
                                                     inSection:section];
                        [self.tableView scrollToRowAtIndexPath:ip
                                              atScrollPosition:UITableViewScrollPositionBottom
                                                      animated:NO];
            }
            
            //[self.navigationItem setTitle:self.singleSelection ? NSLocalizedString(@"Pick Photo", nil) : NSLocalizedString(@"Pick Photos", nil)];
			//ALAssetsGroupType
			ALAssetsGroup *assetGroup = self.assetGroup;
			NSString *sName = assetGroup ? ObjectCast([assetGroup valueForProperty:ALAssetsGroupPropertyName], NSString) : nil;
			if(sName && sName.length)
				[self.navigationItem setTitle:sName];
			//else
			//	[self.navigationItem setTitle:self.singleSelection ? NSLocalizedString(@"Select {Button}", nil) : NSLocalizedString(@"Select {Button}", nil)];
        });
    }
}

- (NSArray *)getSelectedAssets {
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	
	for (ELCAsset *elcAsset in self.elcAssets) {
		if ([elcAsset selected]) {
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
	return selectedAssetsImages;
}

- (void)doneAction:(id)sender
{
    [self.parent selectedAssets:[self getSelectedAssets]];
}


- (BOOL)shouldSelectAsset:(ELCAsset *)asset
{
    NSUInteger selectionCount = 0;
    for (ELCAsset *elcAsset in self.elcAssets) {
        if (elcAsset.selected) selectionCount++;
    }
    BOOL shouldSelect = YES;
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    return shouldSelect;
}

- (void)assetSelected:(ELCAsset *)asset
{
    if (self.singleSelection) {

        for (ELCAsset *elcAsset in self.elcAssets) {
            if (asset != elcAsset) {
                elcAsset.selected = NO;
            }
        }
    }
	[self updateHeader];
    if (self.immediateReturn) {
        NSArray *singleAssetArray = @[asset.asset];
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
    }
}

- (void)assetDeselected:(ELCAsset *)asset
{
	[self updateHeader];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns <= 0) { //Sometimes called before we know how many columns we have
        self.columns = 4;
    }
    NSInteger numRows = ceil([self.elcAssets count] / (float)self.columns);
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell setAssets:[self assetsForIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 79;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for (ELCAsset *asset in self.elcAssets) {
		if (asset.selected) {
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc {
	[_bbiDone release];
	[_bbiCancel release];
	[super dealloc];
}

@end
