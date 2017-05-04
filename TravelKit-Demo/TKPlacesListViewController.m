//
//  TKPlacesListViewController.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 06/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <TravelKit/TravelKit.h>
#import "TKNavigationController.h"
#import "TKPlacesListViewController.h"
#import "TKPlaceDetailViewController.h"
#import "TKPlaceImageView.h"
#import "UIKit+TravelKit.h"
#import "TKPlace+TravelKit.h"


///////////////////////
///////////////////////
#pragma mark - Places List cell -
///////////////////////
///////////////////////


@interface TKPlacesListCell : UICollectionViewCell

@property (nonatomic, strong) TKPlace *place;

@property (nonatomic, strong) TKPlaceImageView *placeImageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property (nonatomic, strong) UIView *separator;

@end


@implementation TKPlacesListCell

- (instancetype)init
{
	if (self = [super init])
		[self tk_initialise];

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
		[self tk_initialise];

	return self;
}

- (void)tk_initialise
{
	self.backgroundColor = [UIColor whiteColor];

	_placeImageView = [[TKPlaceImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
	_placeImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
	_placeImageView.layer.masksToBounds = YES;
	_placeImageView.layer.cornerRadius = 64/2;
	_placeImageView.layer.borderWidth = 0.5;
	_placeImageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
	[self.contentView addCenteredSubview:_placeImageView];
	_placeImageView.left = 10;

	self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.textLabel.font = [UIFont systemFontOfSize:17];
	self.textLabel.numberOfLines = 1;
	self.textLabel.textAlignment = NSTextAlignmentLeft;
	[self.contentView addSubview:_textLabel];

	self.detailTextLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.detailTextLabel.font = [UIFont lightSystemFontOfSize:15];
	self.detailTextLabel.textColor = [UIColor colorWithWhite:0.66 alpha:1];
	self.detailTextLabel.numberOfLines = 2;
	[self.contentView addSubview:_detailTextLabel];

	_separator = [[UIView alloc] initWithFrame:self.bounds];
	_separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_separator.height = 0.5;
	_separator.backgroundColor = [UIColor colorWithWhite:.84 alpha:1];
	[self.contentView addSubview:_separator];
	_separator.fromBottomEdge = 0;
}

- (void)setPlace:(TKPlace *)place
{
	_place = place;

	NSString *detail = [place.perex parsedString];
	if (!detail) detail = [[place localisedCategories] componentsJoinedByString:@" • "];

	self.textLabel.text = [place.name parsedString];
	self.detailTextLabel.text = detail;

	[_placeImageView setImageForPlace:place withSize:CGSizeMake(150, 150)];

	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	static CGFloat sideSep = 15.0;
	static CGFloat txtImgSep = 10.0;
	static CGFloat textSep = 2.0;

	[super layoutSubviews];

	_textLabel.left = _detailTextLabel.left = _placeImageView.right + txtImgSep;
	_textLabel.width = _detailTextLabel.width = self.width - _textLabel.left - sideSep;

	_textLabel.height = [_textLabel expandedSizeOfText].height;
	_detailTextLabel.height = [_detailTextLabel expandedSizeOfText].height;

	_textLabel.top = (self.height - _textLabel.height - _detailTextLabel.height - textSep) / 2;
	_detailTextLabel.top = _textLabel.bottom + textSep;

	_separator.left = _textLabel.left;
	_separator.width = self.width - _separator.left;
	_separator.hidden = self.layer.cornerRadius;
}

- (void)setHighlighted:(BOOL)highlighted
{
//	super.highlighted = highlighted;

	[UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		if (self.layer.cornerRadius)
			self.transform = (highlighted) ?
				CGAffineTransformMakeScale(0.99, 0.99) : CGAffineTransformIdentity;
		self.backgroundColor = (highlighted) ?
			[UIColor colorWithWhite:.97 alpha:1] : [UIColor whiteColor];
	} completion:nil];
}

- (void)setSelected:(BOOL)selected
{
//	super.selected = selected;

	self.backgroundColor = (selected || self.isHighlighted) ?
		[UIColor colorWithWhite:.97 alpha:1] : [UIColor whiteColor];
}

@end


///////////////////////
///////////////////////
#pragma mark - Places List controller -
///////////////////////
///////////////////////


@interface TKPlacesListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

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

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
		[UIImage templateImageNamed:@"navbar-filter"] style:UIBarButtonItemStylePlain
			target:self action:@selector(filterButtonTapped:)];

	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(self.view.width, 78);
	layout.minimumInteritemSpacing = 0;
	layout.minimumLineSpacing = 0;
	layout.sectionInset = UIEdgeInsetsZero;

	CGFloat itemsPerLine = (self.view.width > 1000) ? 3 : (self.view.width > 600) ? 2 : 1;

	if (itemsPerLine > 1) {
		CGFloat inset = 10;
		self.view.backgroundColor = [UIColor colorWithWhite:.99 alpha:1];
		layout.itemSize = CGSizeMake((self.view.width - (itemsPerLine+1)*inset)/itemsPerLine, 80);
		layout.minimumInteritemSpacing = inset;
		layout.minimumLineSpacing = inset;
		layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
	}

	// Content grid
	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_collectionView.backgroundColor = [UIColor clearColor];
//	_collectionView.contentInset = UIEdgeInsetsMake(6, 0, 6, 0);
	[self.view addSubview:_collectionView];

	[_collectionView registerClass:[TKPlacesListCell class] forCellWithReuseIdentifier:@"PlacesListCell"];

	_collectionView.delegate = self;
	_collectionView.dataSource = self;

	[self fetchData];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

}


#pragma mark -
#pragma mark Actions


- (void)fetchData
{
	__weak typeof(self) wself = self;

	[[TravelKit sharedKit] placesForQuery:_query completion:^(NSArray<TKPlace *> *places, NSError *error) {

		if (error) return;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			wself.fetchedPlaces = places;
			[wself.collectionView scrollRectToVisible:CGRectZero animated:NO];
			[wself.collectionView reloadData];
		}];

	}];
}

- (IBAction)filterButtonTapped:(id)sender
{
	NSString *title = NSLocalizedString(@"Select category", @"TravelKit UI - Filers title");

	UIAlertController *prompt = [UIAlertController alertControllerWithTitle:title
		message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {

		if ([action.title isEqualToString:@"Sights"])
			_query.categories = @[ @"sightseeing" ];
		else if ([action.title isEqualToString:@"Museums"])
			_query.categories = @[ @"discovering" ];
		else if ([action.title isEqualToString:@"Nightlife"])
			_query.categories = @[ @"going_out" ];
		else if ([action.title isEqualToString:@"Transport"])
			_query.categories = @[ @"traveling" ];
		else _query.categories = nil;

		[self fetchData];
	};

	[prompt addAction:[UIAlertAction actionWithTitle:@"All" style:UIAlertActionStyleDestructive handler:handler]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Sights" style:UIAlertActionStyleDefault handler:handler]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Museums" style:UIAlertActionStyleDefault handler:handler]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Nightlife" style:UIAlertActionStyleDefault handler:handler]];
	[prompt addAction:[UIAlertAction actionWithTitle:@"Transport" style:UIAlertActionStyleDefault handler:handler]];

	prompt.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;

	[self presentViewController:prompt animated:YES completion:nil];
}


#pragma mark -
#pragma mark Table view delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _fetchedPlaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 78;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	TKPlace *place = _fetchedPlaces[indexPath.row];

	TKPlacesListCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"PlacesListCell" forIndexPath:indexPath];
	cell.place = place;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		cell.layer.cornerRadius = 8;
		cell.layer.borderWidth = 0.5;
		cell.layer.borderColor = cell.separator.backgroundColor.CGColor;
	}

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];

	TKPlace *place = _fetchedPlaces[indexPath.row];

	TKPlaceDetailViewController *vc = [[TKPlaceDetailViewController alloc] initWithPlace:place];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
		nc.modalPresentationStyle = UIModalPresentationFormSheet;
		nc.preferredContentSize = CGSizeMake(440, 560);
		[self presentViewController:nc animated:YES completion:nil];
	}
	else [self.navigationController pushViewController:vc animated:YES];
}

@end
