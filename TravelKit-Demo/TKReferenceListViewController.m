//
//  TKReferenceListViewController.m
//  TravelKit Demo
//
//  Created by Michal Zelinka on 22/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKReferenceListViewController.h"
#import "TKBrowserViewController.h"

#import "TKNavigationController.h"
#import "TKPlaceDetailCells.h"
#import "UIKit+TravelKit.h"
#import "Foundation+TravelKit.h"


@interface TKReferenceListCell : TKPlaceDetailEmptyCell

@property (nonatomic, strong) TKPlaceDetailProductControl *productControl;

@end


@implementation TKReferenceListCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	_productControl.highlighted = highlighted;
}

@end


@interface TKReferenceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTable;

@end


@implementation TKReferenceListViewController

- (instancetype)initWithReferences:(NSArray<TKReference *> *)references
{
	if (self = [super init])
	{
		_references = references;
	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"More Options", @"TravelKit UI - References List generic title");
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

	_contentTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_contentTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentTable.delegate = self;
	_contentTable.dataSource = self;
	[self.view addSubview:_contentTable];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[_contentTable reloadData];
}

- (void)openURL:(NSURL *)URL
{
	if (!URL) return;

	TKBrowserViewController *vc = [[TKBrowserViewController alloc] initWithURL:URL];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
		nc.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentViewController:nc animated:YES completion:nil];
	}
	else [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _references.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView cellForRowAtIndexPath:indexPath].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TKReferenceListCell *cell = [[TKReferenceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

	cell.width = tableView.width;

	cell.productControl = [[TKPlaceDetailProductControl alloc] initWithFrame:cell.bounds];
	cell.productControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	cell.productControl.product = [_references safeObjectAtIndex:indexPath.row];
	cell.productControl.enabled = NO;

	cell.height = cell.productControl.height;
	[cell addSubview:cell.productControl];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	TKReference *reference = [_references safeObjectAtIndex:indexPath.row];

	if (!reference.onlineURL) return;

	[self openURL:reference.onlineURL];
}



@end
