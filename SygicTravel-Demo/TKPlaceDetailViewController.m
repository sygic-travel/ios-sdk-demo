//
//  TKPlaceDetailViewController.m
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKPlaceDetailViewController.h"
#import "TKPlaceDetailCells.h"
#import "Foundation+TravelKit.h"
#import "UIKit+TravelKit.h"


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


@interface TKPlaceDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTable;

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

- (void)loadView
{
	[super loadView];

	// Basic attributes
	self.title = _place.name;

//	self.automaticallyAdjustsScrollViewInsets = NO;
//	self.edgesForExtendedLayout = UIRectEdgeTop;
//	self.extendedLayoutIncludesOpaqueBars = NO;

	_cellsCache = [NSCache new];

	// Content grid
	_contentTable = [[TKPlaceDetailTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_contentTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentTable.backgroundColor = [UIColor colorWithWhite:.94 alpha:1];
	_contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_contentTable];

	_contentTable.delegate = self;
	_contentTable.dataSource = self;

	// Force-refresh
	[self refreshView];

	// Fetch full detailed Place
	[[TravelKit sharedKit] detailedPlaceWithID:_place.ID completion:^(TKPlace *place, NSError *error) {

		if (!place) return;

		self.place = place;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self refreshView];
		}];
	}];
}

- (void)viewWillLayoutSubviews
{
	[_cellsCache removeAllObjects];
}

- (void)viewDidLayoutSubviews
{
	[self refreshView];
}


#pragma mark -
#pragma mark Setters


- (void)setPlace:(TKPlace *)place
{
	_place = place;

	TKReference *wiki = nil;
	NSMutableArray<TKReference *> *basicLinks = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKReference *> *passes = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKReference *> *otherProducts = [NSMutableArray arrayWithCapacity:6];
	NSMutableArray<TKPlaceDetailLink *> *contacts = [NSMutableArray arrayWithCapacity:6];

	for (TKReference *ref in _place.detail.references)
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

	if (_place.detail.phone) {
		TKPlaceDetailLink *link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypePhone value:_place.detail.phone];
		[contacts addObject:link];
	}

	if (_place.detail.email) {
		TKPlaceDetailLink *link = [TKPlaceDetailLink linkWithType:TKPlaceDetailLinkTypeEmail value:_place.detail.email];
		[contacts addObject:link];
	}

	if (wiki) [basicLinks insertObject:wiki atIndex:0];
	_wiki = wiki;

	_basicLinks = basicLinks;
	_passes = passes;
	_otherProducts = otherProducts;
	_contacts = contacts;

//	@property (nonatomic, strong) TKMedium *imageMedium;
}


#pragma mark -
#pragma mark Refreshing


- (void)refreshView
{
	[_cellsCache removeAllObjects];
	[_contentTable reloadData];
}


#pragma mark -
#pragma mark Actions


- (void)openURL:(NSURL *)URL
{
	if (!URL) return;

	BOOL needsBrowser = [URL.scheme containsString:@"http"];

	if (needsBrowser && _urlOpeningBlock)
		_urlOpeningBlock(URL);

	else [[UIApplication sharedApplication] openURL:URL];
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
			        _place.detail.fullDescription.length) ? 1:0;

		case PlaceDetailSectionTags:
			return (_place.categories.count || _place.detail.tags.count) ? 1:0;

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
			return _place.detail.admission.length ? 1:0;

		case PlaceDetailSectionOpeningHoursSeparator:
		case PlaceDetailSectionOpeningHours:
			return _place.detail.openingHours.length ? 1:0;

		case PlaceDetailSectionAddressSeparator:
		case PlaceDetailSectionAddress:
			return (_place.location || _place.detail.address.length) ? 1:0;

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
	if (section == PlaceDetailSectionOpeningHours)
		return (_place.detail.openingHours.length) ?
			NSLocalizedString(@"Opening hours", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionAdmission)
		return (_place.detail.admission.length) ?
			NSLocalizedString(@"Admission", @"TravelKit UI Place Detail header") : nil;

	if (section == PlaceDetailSectionAddress)
		return (_place.detail.address.length) ?
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

		if (section == PlaceDetailSectionFootingSeparator)
			cell.hasBottomSeparator = NO;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionHeader)
	{
		basicRect.size.height = kImageHeight;

		TKPlaceDetailHeaderCell *cell = [[TKPlaceDetailHeaderCell alloc] initWithFrame:basicRect];
		cell.place = _place;

		[_cellsCache setObject:cell forKey:cacheKey];

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
		cell.displayedText = _place.detail.fullDescription ?: _place.perex;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionTags)
	{
		TKPlaceDetailTagsCell *cell = [[TKPlaceDetailTagsCell alloc] initWithFrame:basicRect];
		cell.overridingTopPadding = (_place.perex) ? -5 : 0;
		cell.categories = _place.displayableCategories;
		cell.tags = _place.detail.tags;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionAdmission)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];
		cell.headingDetectionEnabled = YES;
		cell.displayedText = _place.detail.admission;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionOpeningHours)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];
		cell.headingDetectionEnabled = YES;
		cell.displayedText = _place.detail.openingHours;

		[_cellsCache setObject:cell forKey:cacheKey];

		return cell;
	}

	if (section == PlaceDetailSectionAddress)
	{
		TKPlaceDetailSingleLabelCell *cell = [[TKPlaceDetailSingleLabelCell alloc] initWithFrame:basicRect];

		NSString *location = [NSString stringWithFormat:@"%.3f, %.3f",
			_place.location.coordinate.latitude, _place.location.coordinate.longitude];

		NSString *address = _place.detail.address;

		NSMutableArray *comps = [NSMutableArray arrayWithCapacity:2];
		if (address) [comps addObject:address];
		if (location) [comps addObject:location];

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
		case PlaceDetailSectionContacts:
		case PlaceDetailSectionMaps:
		case PlaceDetailSectionArticles:
			return YES;
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



		} break;



	}


}







@end
