//
//  TKPlacesListViewController.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 06/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKPlacesListViewController.h"
#import "TKPlaceDetailViewController.h"
#import "TKPlaceDetailCells.h"
#import "UIKit+TravelKit.h"


# /////////////////////
# /////////////////////
#pragma mark - Places List controller -
# /////////////////////
# /////////////////////


@interface TKPlacesListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTable;

@property (nonatomic, strong) NSArray<TKPlace *> *fetchedPlaces;

@end


@implementation TKPlacesListViewController

- (instancetype)initWithQuery:(TKPlacesQuery *)query
{
	if (self = [super init])
	{
		_query = query;
	}

	return self;
}

- (void)loadView
{
	[super loadView];

	self.title = NSLocalizedString(@"Places", @"TravelKit UI - Places List title");
	self.view.backgroundColor = [UIColor whiteColor];

	self.navigationItem.backBarButtonItem = [UIBarButtonItem emptyBarButtonItem];

	// Content grid
	_contentTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_contentTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentTable.backgroundColor = [UIColor clearColor];
	_contentTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//	_contentTable.contentInset = UIEdgeInsetsMake(6, 0, 6, 0);
	[self.view addSubview:_contentTable];

	_contentTable.delegate = self;
	_contentTable.dataSource = self;

	[self fetchData];
}


#pragma mark -
#pragma mark Actions


- (void)fetchData
{
	[[TravelKit sharedKit] placesForQuery:_query completion:^(NSArray<TKPlace *> *places, NSError *error) {

		if (error) return;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			_fetchedPlaces = places;
			[_contentTable reloadData];
		}];

	}];
}


#pragma mark -
#pragma mark Table view delegates


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _fetchedPlaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TKPlace *place = _fetchedPlaces[indexPath.row];

	TKPlacesListCell *cell = [[TKPlacesListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	cell.place = place;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	TKPlace *place = _fetchedPlaces[indexPath.row];

	TKPlaceDetailViewController *vc = [[TKPlaceDetailViewController alloc] initWithPlace:place];
	[self.navigationController pushViewController:vc animated:YES];
}


@end
