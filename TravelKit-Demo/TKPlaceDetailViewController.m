//
//  TKPlaceDetailViewController.m
//  TravelKit Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIKit+TravelKit.h"
#import "TKPlace+TravelKit.h"

#import "TKNavigationController.h"
#import "TKPlaceDetailViewController.h"
#import "TKBrowserViewController.h"
#import "TKReferenceListViewController.h"
#import "TKGalleryCollectionViewController.h"

#import "TKPlaceDetailCells.h"


typedef NS_ENUM(NSInteger, PlaceDetailSection) {
	PlaceDetailSectionHeader = 0,
	PlaceDetailSectionName,
	PlaceDetailSectionDescription,
	PlaceDetailSectionDescriptionAttribution,
	PlaceDetailSectionDescriptionTranslation,
	PlaceDetailSectionTags,
	PlaceDetailSectionRatingSeparator,
	PlaceDetailSectionRating,
	PlaceDetailSectionOtherProductsSeparator,
	PlaceDetailSectionOtherProducts,
	PlaceDetailSectionPassesSeparator,
	PlaceDetailSectionPasses,
	PlaceDetailSectionBasicLinksSeparator,
	PlaceDetailSectionBasicLinks,
	PlaceDetailSectionAdmissionSeparator,
	PlaceDetailSectionAdmission,
	PlaceDetailSectionOpeningHoursSeparator,
	PlaceDetailSectionOpeningHours,
	PlaceDetailSectionTimeSeparator,
	PlaceDetailSectionTime,
	PlaceDetailSectionAddressSeparator,
	PlaceDetailSectionAddress,
	PlaceDetailSectionContactsSeparator,
	PlaceDetailSectionContacts,
	PlaceDetailSectionArticlesMapsSeparator,
	PlaceDetailSectionMaps,
	PlaceDetailSectionArticles,
	PlaceDetailSectionAttributionSeparator,
	PlaceDetailSectionAttribution,
	PlaceDetailSectionFootingSeparator,
	//////////////////
	PlaceDetailSectionsCount
};

const CGFloat kImageHeight = 256.0;
const CGFloat kDefaultLinksHeight = 54.0;

#define kContactsRowPadding  10.0
#define kSectionPadding  12.0
#define kSubtitleHeight 24.0
#define kHeaderButtonOverlapHeight 36.0
#define kNoteInitialHeight 128.0
#define kDescriptionInitialHeight 123.0
#define kTableSeparatorsHeight 8.0
#define kTableCellActionButtonPadding 15.0
#define kTableCellActionButtonSize 36.0


# /////////////////////
# /////////////////////
#pragma mark - Place Detail Table view -
# /////////////////////
# /////////////////////


@interface TKPlaceDetailTableView : UITableView
@end

@implementation TKPlaceDetailTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];

	static dispatch_once_t once;
	dispatch_once(&once, ^{

		@try {
			SEL badOne = NSSelectorFromString([@"allowsHeader" stringByAppendingString:@"ViewsToFloat"]);
			[self swizzleSelector:@selector(allowFloatingHeaders) withSelector:badOne];
		}
		@catch (NSException *exception) {}

	});

	return self;
}

- (BOOL)allowFloatingHeaders
{
	return NO;
}

@end


# /////////////////////
# /////////////////////
#pragma mark - Place Detail controller -
# /////////////////////
# /////////////////////


@interface TKPlaceDetailViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TKPlaceDetailHeaderCell *cachedHeaderCell;

// Helper
@property (nonatomic, strong) TKDetailedPlace *detailedPlace;

// View-related structures
@property (nonatomic, strong) TKReference *wiki;
@property (nonatomic, copy) NSArray<TKReference *> *passes;
@property (nonatomic, copy) NSArray<TKReference *> *otherProducts;
@property (nonatomic, copy) NSArray<TKReference *> *basicLinks;
@property (nonatomic, copy) NSArray<TKPlaceDetailLink *> *contacts;

@property (nonatomic, strong) TKMedium *imageMedium;

@property (nonatomic, strong) NSCache<NSString *, UITableViewCell *> *cellsCache;

@end


@implementation TKPlaceDetailViewController


#pragma mark -
#pragma mark View lifecycle


- (instancetype)initWithPlace:(TKPlace *)place
{
	if (self = [super init])
	{
		self.place = place;
	}

	return self;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return ([self isScreenScrolledBelowTheTitle]) ?
		UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (void)loadView
{
	[super loadView];

	// Basic attributes
	self.title = @"";

//	self.automaticallyAdjustsScrollViewInsets = NO;
//	self.edgesForExtendedLayout = UIRectEdgeTop;
//	self.extendedLayoutIncludesOpaqueBars = NO;

	self.navigationItem.backBarButtonItem = [UIBarButtonItem emptyBarButtonItem];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem emptyBarButtonItem];

	if (self.navigationController.viewControllers.firstObject == self)
		self.navigationItem.leftBarButtonItem = [UIBarButtonItem
			closeBarButtonItemWithTarget:self selector:@selector(closeButtonTapped:)];

	// TODO: Close button
//	if (!self.navigationController)
//		self.navigationItem.leftBarButtonItem = [UIBarButtonItem emptyBarButtonItem];


	_cellsCache = [NSCache new];

	// Content grid
	_tableView = [[TKPlaceDetailTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.backgroundColor = [UIColor colorWithWhite:.94 alpha:1];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_tableView];

	_tableView.delegate = self;
	_tableView.dataSource = self;

	// Force-refresh
	[self refreshView];

	__weak typeof(self) wself = self;

	// Fetch full detailed Place
	[[TravelKit sharedKit].places detailedPlaceWithID:_place.ID completion:^(TKPlace *place, NSError *error) {

		if (!place) return;

		wself.place = place;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[wself refreshView];
		}];
	}];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];

	[_cellsCache removeAllObjects];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	[self refreshView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self makeNavigationBarTransparent:![self isScreenScrolledBelowTheTitle] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self makeNavigationBarTransparent:![self isScreenScrolledBelowTheTitle] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	// TODO: Check on iPhone with pushing behaviour
	BOOL willDismiss = self.isBeingDismissed || self.navigationController.isBeingDismissed;
	willDismiss |= UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;

	[self makeNavigationBarTransparent:!willDismiss animated:YES];
}


#pragma mark -
#pragma mark Setters


- (void)setPlace:(TKPlace *)place
{
	_place = place;
	_detailedPlace = [place isKindOfClass:[TKDetailedPlace class]] ? (id)place : nil;

	TKReference *wiki = nil;
	NSMutableArray<TKReference *> *basicLinks = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKReference *> *passes = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKReference *> *otherProducts = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKPlaceDetailLink *> *contacts = [NSMutableArray arrayWithCapacity:6];

	for (TKReference *ref in _detailedPlace.detail.references)
	{
		if ([ref.type hasPrefix:@"guide"] || [ref.type hasPrefix:@"link:official"])
			[basicLinks addObject:ref];
		else if ([ref.type hasPrefix:@"link"]) {
			TKPlaceDetailLink *link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypeReference value:ref];
			[contacts addObject:link];
		}
		else if (!wiki && [ref.type hasPrefix:@"wiki"])
			wiki = ref;

		else if ([ref.type hasPrefix:@"tour"]) {
			if ([ref.type isEqual:@"tour:place"])
				[otherProducts insertObject:ref atIndex:0];
			else [otherProducts addObject:ref]; }

		else if ([ref.type hasPrefix:@"rent"])
			[otherProducts addObject:ref];
		else if ([ref.type hasPrefix:@"transfer"])
			[otherProducts addObject:ref];
		else if ([ref.type hasPrefix:@"buy:ticket"])
			[otherProducts addObject:ref];
		else if ([ref.type hasPrefix:@"book:table"])
			[otherProducts addObject:ref];
		else if ([ref.type hasPrefix:@"pass"])
			[passes addObject:ref];
		else if ([ref.type hasPrefix:@"parking"])
			[otherProducts addObject:ref];
	}

	if (_detailedPlace.detail.phone) {
		TKPlaceDetailLink *link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypePhone value:_detailedPlace.detail.phone];
		[contacts addObject:link];
	}

	if (_detailedPlace.detail.email) {
		TKPlaceDetailLink *link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypeEmail value:_detailedPlace.detail.email];
		[contacts addObject:link];
	}

	if (wiki) [basicLinks insertObject:wiki atIndex:0];
	_wiki = wiki;

	_basicLinks = basicLinks;
	_passes = passes;
	_otherProducts = otherProducts;
	_contacts = contacts;
}


#pragma mark -
#pragma mark Refreshing


- (void)refreshView
{
	[_cellsCache removeAllObjects];
	[_tableView reloadData];
}


#pragma mark -
#pragma mark Misc


- (BOOL)isScreenScrolledBelowTheTitle
{
	return _tableView.contentOffset.y > kImageHeight-_tableView.contentInset.top;
}

- (UIColor *)currentNavbarTintColor
{
	BOOL dismissing = [self isMovingFromParentViewController];
	BOOL appearing = [self isMovingToParentViewController];

	dismissing |= !appearing && !self.view.superview;

	if (dismissing) return nil;

	if ([self isScreenScrolledBelowTheTitle])
		return [UIColor colorFromRGB:_place.displayableHexColor];

	return [UIColor whiteColor];
}


#pragma mark -
#pragma mark Control actions


- (IBAction)closeButtonTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)headerImageTapped
{
	[[[TravelKit sharedKit] places] mediaForPlaceWithID:_place.ID completion:^(NSArray<TKMedium *> *media, NSError *error) {

		if (!media.count) return;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			TKGalleryCollectionViewController *vc = [[TKGalleryCollectionViewController alloc] initWithPlace:_place media:media];
			UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
			nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentViewController:nc animated:YES completion:nil];
		}];

	}];
}


#pragma mark -
#pragma mark Other actions


- (void)openURL:(NSURL *)URL
{
	if (!URL) return;

	BOOL isHTTP = [URL.scheme hasPrefix:@"http"];
	BOOL isMail = [URL.scheme hasPrefix:@"mailto"];

	if (!isHTTP)
		if (isMail) {
			NSString *mail = [[URL absoluteString] stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
			MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
			vc.mailComposeDelegate = self;
			[vc setToRecipients:@[ mail ]];
			[self presentViewController:vc animated:YES completion:nil];
		} else [[UIApplication sharedApplication] openURL:URL];

	else if (_urlOpeningBlock)
		_urlOpeningBlock(URL);

	else {
		TKBrowserViewController *vc = [[TKBrowserViewController alloc] initWithURL:URL];

		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
			nc.modalPresentationStyle = UIModalPresentationPageSheet;
			[self presentViewController:nc animated:YES completion:nil];
		}
		else [self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)openListingForProducts:(NSArray<TKReference *> *)products
{
	TKReferenceListViewController *vc = [[TKReferenceListViewController alloc] initWithReferences:products];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)makeNavigationBarTransparent:(BOOL)transparent animated:(BOOL)animated
{
	UINavigationBar *navbar = self.navigationController.navigationBar;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	SEL selector = NSSelectorFromString([@"_" stringByAppendingString:@"backgroundView"]);
	UIView *navbarBackground = ([navbar respondsToSelector:selector]) ?
		[navbar performSelector:selector] : navbar.subviews.firstObject;
#pragma clang diagnostic pop

	[UIView animateWithDuration:animated?.1:0 animations:^{
		navbar.tintColor = [self currentNavbarTintColor];
	}];

	if ((transparent && navbarBackground.alpha != 1) ||
	    (!transparent && navbarBackground.alpha == 1))
		return;

	if (transparent)
	{
		self.title = @"";
		navbar.backgroundColor = [UIColor clearColor];
		[UIView animateWithDuration:animated?.14:0 delay:0 options:0 animations:^{
			navbarBackground.alpha = 0;
		} completion:nil];
	}
	else
	{
		self.title = _place.name;
		navbar.backgroundColor = [UINavigationBar appearance].backgroundColor;
		[UIView animateWithDuration:animated?.06:0 delay:0 options:0 animations:^{
			navbarBackground.alpha = 1;
		} completion:nil];
	}
}


#pragma mark -
#pragma mark Table view delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return PlaceDetailSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {

		case PlaceDetailSectionHeader:
		case PlaceDetailSectionName:
			return 1;

		case PlaceDetailSectionDescription:
			return (_place.perex.length ||
			        _detailedPlace.detail.fullDescription.text.length) ? 1:0;

		case PlaceDetailSectionTags:
			return (_place.categories || _detailedPlace.detail.tags.count) ? 1:0;

		case PlaceDetailSectionOtherProductsSeparator:
		case PlaceDetailSectionOtherProducts:
			return (_otherProducts.count) ? 1:0;

		case PlaceDetailSectionPassesSeparator:
		case PlaceDetailSectionPasses:
			return (_passes.count) ? 1:0;

		case PlaceDetailSectionBasicLinksSeparator:
			return (_basicLinks.count) ? 1:0;
		case PlaceDetailSectionBasicLinks:
			return _basicLinks.count;

		case PlaceDetailSectionAdmissionSeparator:
		case PlaceDetailSectionAdmission:
			return _detailedPlace.detail.admission.length ? 1:0;

		case PlaceDetailSectionOpeningHoursSeparator:
		case PlaceDetailSectionOpeningHours:
			return _detailedPlace.detail.openingHours.length ? 1:0;

		case PlaceDetailSectionAddressSeparator:
		case PlaceDetailSectionAddress:
			return (_place.location || _detailedPlace.detail.address.length) ? 1:0;

		case PlaceDetailSectionContactsSeparator:
			return (_contacts.count) ? 1:0;
		case PlaceDetailSectionContacts:
			return _contacts.count;

		case PlaceDetailSectionAttributionSeparator:
		case PlaceDetailSectionAttribution:
			return (_imageMedium) ? 1:0;

		case PlaceDetailSectionFootingSeparator:
			return 1;
	}

	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	NSString *header = [self tableView:tableView titleForHeaderInSection:section];

	if (section == PlaceDetailSectionPasses || section == PlaceDetailSectionOtherProducts)
		return (header) ? 34 : 0;

	return (header) ? 26 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger section = indexPath.section;

	NSString *cacheKey = [NSString stringWithFormat:@"%zd_%zd", indexPath.section, indexPath.row];

	UITableViewCell *cell = [_cellsCache objectForKey:cacheKey];

	if (cell) return CGRectGetHeight(cell.frame);

	switch (section) {

		case PlaceDetailSectionHeader:
			return kImageHeight;

		case PlaceDetailSectionRatingSeparator:
		case PlaceDetailSectionOtherProductsSeparator:
		case PlaceDetailSectionPassesSeparator:
		case PlaceDetailSectionBasicLinksSeparator:
		case PlaceDetailSectionAdmissionSeparator:
		case PlaceDetailSectionOpeningHoursSeparator:
		case PlaceDetailSectionTimeSeparator:
		case PlaceDetailSectionAddressSeparator:
		case PlaceDetailSectionContactsSeparator:
		case PlaceDetailSectionArticlesMapsSeparator:
		case PlaceDetailSectionAttributionSeparator:
		case PlaceDetailSectionFootingSeparator:
			return kTableSeparatorsHeight;

		case PlaceDetailSectionBasicLinks:
		case PlaceDetailSectionContacts:
			return kDefaultLinksHeight;

	}

	cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

	return CGRectGetHeight(cell.frame);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == PlaceDetailSectionPasses)
		return (_passes.count) ?
			NSLocalizedString(@"This place accepts", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionOtherProducts)
		return (_otherProducts.count) ?
			NSLocalizedString(@"Tours & Tickets", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionOpeningHours)
		return (_detailedPlace.detail.openingHours.length) ?
			NSLocalizedString(@"Opening hours", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionAdmission)
		return (_detailedPlace.detail.admission.length) ?
			NSLocalizedString(@"Admission", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionAddress)
		return (_detailedPlace.detail.address.length) ?
			NSLocalizedString(@"Address", @"TravelKit UI Place Detail header") :
		(_place.location) ? NSLocalizedString(@"Location", @"TravelKit UI Place Detail header") : nil;

	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *header = [self tableView:tableView titleForHeaderInSection:section] ?: @"";
	header = [header uppercaseString];

	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	v.backgroundColor = [UIColor whiteColor];

	CGRect f = v.bounds;
	f.size.width -= 2*kTKPlaceDetailCellsSidePadding;
	f.origin.x = kTKPlaceDetailCellsSidePadding;

	UILabel *label = [[UILabel alloc] initWithFrame:f];
	label.font = [UIFont lightSystemFontOfSize:13];
	label.textColor = [UIColor blackColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.transform = CGAffineTransformMakeTranslation(0, 5);
	[v addSubview:label];

	if (section == PlaceDetailSectionPasses || section == PlaceDetailSectionOtherProducts)
	{
		label.textColor = [UIColor colorWithWhite:.6 alpha:1];
		label.textAlignment = NSTextAlignmentCenter;
	}

	label.attributedText = [[NSAttributedString alloc] initWithString:header attributes:@{
		NSFontAttributeName: label.font,
		NSForegroundColorAttributeName: label.textColor,
		NSKernAttributeName: @1,
	}];

	return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cacheKey = [NSString stringWithFormat:@"PlaceDetail_%zd_%zd", indexPath.section, indexPath.row];

	UITableViewCell *cell = [_cellsCache objectForKey:cacheKey];

	if (cell) return cell;

	CGRect basicRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 64);
	NSInteger section = indexPath.section;

	if (section == PlaceDetailSectionRatingSeparator ||
		section == PlaceDetailSectionOtherProductsSeparator ||
		section == PlaceDetailSectionPassesSeparator ||
		section == PlaceDetailSectionBasicLinksSeparator ||
		section == PlaceDetailSectionAdmissionSeparator ||
		section == PlaceDetailSectionOpeningHoursSeparator ||
		section == PlaceDetailSectionTimeSeparator ||
		section == PlaceDetailSectionAddressSeparator ||
		section == PlaceDetailSectionContactsSeparator ||
		section == PlaceDetailSectionArticlesMapsSeparator ||
		section == PlaceDetailSectionAttributionSeparator ||
		section == PlaceDetailSectionFootingSeparator)
	{
		basicRect.size.height = kTableSeparatorsHeight;

		TKPlaceDetailSeparatorCell *cell = [[TKPlaceDetailSeparatorCell alloc] initWithFrame:basicRect];
		cell.isAccessibilityElement = NO;

		if (section == PlaceDetailSectionFootingSeparator)
			cell.hasBottomSeparator = NO;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionHeader)
	{
		if (_cachedHeaderCell) return _cachedHeaderCell;

		__weak typeof(self) wself = self;

		basicRect.size.height = kImageHeight;

		TKPlaceDetailHeaderCell *cell = [[TKPlaceDetailHeaderCell alloc] initWithFrame:basicRect];
		cell.place = _place;
		cell.imageTapHandler = ^{
			[wself headerImageTapped];
		};
		_cachedHeaderCell = cell;

		[cell updateWithVerticalOffset:tableView.contentOffset.y inset:tableView.contentInset.top];

		return cell;
	}

	if (section == PlaceDetailSectionName)
	{
		TKPlaceDetailNameCell *cell = [[TKPlaceDetailNameCell alloc] initWithFrame:basicRect];
		cell.displayName = _place.name;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionDescription)
	{
		TKPlaceDetailDescriptionCell *cell = [[TKPlaceDetailDescriptionCell alloc] initWithFrame:basicRect];
		cell.headingDetectionEnabled = YES;
		cell.displayedText = _detailedPlace.detail.fullDescription.text ?: _place.perex;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionTags)
	{
		TKPlaceDetailTagsCell *cell = [[TKPlaceDetailTagsCell alloc] initWithFrame:basicRect];
		cell.overridingTopPadding = (_place.perex) ? -5 : 0;
		cell.categories = _place.localisedCategories;
		cell.tags = _detailedPlace.detail.tags;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionAdmission)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];
		cell.headingDetectionEnabled = YES;
		cell.displayedText = _detailedPlace.detail.admission;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionOpeningHours)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];
		cell.headingDetectionEnabled = YES;
		cell.displayedText = _detailedPlace.detail.openingHours;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionAddress)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];

		CLLocationCoordinate2D loc = _place.location.coordinate;
		NSString *latSuffix = (loc.latitude >= 0) ? @"N":@"S";
		NSString *lngSuffix = (loc.longitude >= 0) ? @"E":@"W";

		NSString *location = [NSString stringWithFormat:@"%.3f°%@ %.3f°%@",
			ABS(loc.latitude), latSuffix, ABS(loc.longitude), lngSuffix];

		NSString *address = _detailedPlace.detail.address;

		NSMutableArray *comps = [NSMutableArray arrayWithCapacity:2];
		if (address) [comps addObject:address];
		[comps addObject:location];

		NSString *addrString = [comps componentsJoinedByString:@"\n"];

		NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:addrString attributes:@{
			NSForegroundColorAttributeName: cell.textLabel.textColor,
			NSFontAttributeName: cell.textLabel.font,
		}];

		NSRange r = [addrString rangeOfString:location];

		if (address && r.location != NSNotFound) {
			[str addAttributes:@{
				NSForegroundColorAttributeName: [UIColor colorWithWhite:.84 alpha:1],
			} range:r];
		}

		cell.textLabel.attributedText = str;

		[cell layoutSubviews];

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionBasicLinks)
	{
		TKReference *ref = [_basicLinks safeObjectAtIndex:indexPath.row];

		TKPlaceDetailLinkCell *cell = [[TKPlaceDetailLinkCell alloc] initWithFrame:basicRect];
		cell.link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypeReference value:ref];

		if (indexPath.row) [cell addSeparatingLineToTop:YES toBottom:NO];

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionContacts)
	{
		TKPlaceDetailLinkCell *cell = [[TKPlaceDetailLinkCell alloc] initWithFrame:basicRect];
		cell.link = [_contacts safeObjectAtIndex:indexPath.row];

		if (indexPath.row) [cell addSeparatingLineToTop:YES toBottom:NO];

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionOtherProducts)
	{
		TKPlaceDetailProductsCell *cell = [[TKPlaceDetailProductsCell alloc] initWithFrame:basicRect];
		cell.products = _otherProducts;

		__weak typeof(self) wf = self;
		cell.productTappingBlock = ^(TKReference *ref) {
			if (ref.onlineURL) [wf openURL:ref.onlineURL];
		};
		cell.productsListTappingBlock = ^{
			[wf openListingForProducts:wf.otherProducts];
		};

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionPasses)
	{
		TKPlaceDetailProductsCell *cell = [[TKPlaceDetailProductsCell alloc] initWithFrame:basicRect];
		cell.products = _passes;

		__weak typeof(self) wf = self;
		cell.productTappingBlock = ^(TKReference *ref) {
			if (ref.onlineURL) [wf openURL:ref.onlineURL];
		};
		cell.productsListTappingBlock = ^{
			[wf openListingForProducts:wf.passes];
		};

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

// TODO:
//	PlaceDetailSectionDescriptionAttribution,
//	PlaceDetailSectionDescriptionTranslation,
//	PlaceDetailSectionRating,

//	PlaceDetailSectionTime,
//	PlaceDetailSectionMaps,
//	PlaceDetailSectionArticles,
//	PlaceDetailSectionAttribution,

	return [TKPlaceDetailGenericCell new];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {

		case PlaceDetailSectionOtherProducts:
		case PlaceDetailSectionPasses:
		case PlaceDetailSectionBasicLinks:
		case PlaceDetailSectionMaps:
		case PlaceDetailSectionArticles:
			return YES;

		case PlaceDetailSectionContacts: {
			TKPlaceDetailLink *link = [_contacts safeObjectAtIndex:indexPath.row];
			if (link.type == TKPlaceDetailLinkTypePhone)
				return [[UIDevice currentDevice] canPerformPhoneCall];
			if (link.type == TKPlaceDetailLinkTypeEmail)
				return [[UIDevice currentDevice] canComposeEmail];
		} return YES;
	}

	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	switch (indexPath.section) {

		case PlaceDetailSectionOtherProducts:
		case PlaceDetailSectionPasses:
			break;

		case PlaceDetailSectionBasicLinks:
		{
			TKReference *ref = [_basicLinks safeObjectAtIndex:indexPath.row];
			if (ref.onlineURL) [self openURL:ref.onlineURL];

		} break;

		case PlaceDetailSectionMaps:
		case PlaceDetailSectionArticles:
			break;

		case PlaceDetailSectionContacts:
		{
			TKPlaceDetailLink *link = [_contacts safeObjectAtIndex:indexPath.row];

			if (link.type == TKPlaceDetailLinkTypePhone)
			{
				NSString *phone = link.value;
				NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"[^0-9*+#]"
					options:NSRegularExpressionCaseInsensitive error:nil];
				phone = [exp stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, phone.length) withTemplate:@""];
				phone = [@"tel:" stringByAppendingString:phone];
				NSURL *URL = [NSURL URLWithString:phone];
				if (URL) [self openURL:URL];
			}

			else if (link.type == TKPlaceDetailLinkTypeEmail)
			{
				NSString *email = link.value;
				email = [@"mailto:" stringByAppendingString:email];
				NSURL *URL = [NSURL URLWithString:email];
				if (URL) [self openURL:URL];
			}

			else if (link.type == TKPlaceDetailLinkTypeURL)
			{
				NSURL *URL = link.value;
				if (URL) [self openURL:URL];
			}

			else if (link.type == TKPlaceDetailLinkTypeReference)
			{
				TKReference *ref = link.value;
				NSURL *URL = ref.onlineURL;
				if (URL) [self openURL:URL];
			}

		} break;

	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!self.view.superview) return;

	BOOL belowTitle = [self isScreenScrolledBelowTheTitle];
//	if (scrollView.contentSize.height < 568+kImageHeight)
//		belowTitle = NO;

	[_cachedHeaderCell updateWithVerticalOffset:
		scrollView.contentOffset.y inset:scrollView.contentInset.top];

	[self.navigationController setNeedsStatusBarAppearanceUpdate];

	[self makeNavigationBarTransparent:!belowTitle animated:YES];

	_tableView.showsVerticalScrollIndicator = belowTitle;
}


#pragma mark -
#pragma mark Mail compose delegate


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	if (self.presentedViewController == controller)
		[self dismissViewControllerAnimated:YES completion:nil];
}

@end
