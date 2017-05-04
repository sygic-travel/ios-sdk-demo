//
//  TKMapViewViewController.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 19/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <TravelKit/TravelKit.h>

#import <pthread.h>

#import "TKNavigationController.h"
#import "TKMapViewController.h"
#import "TKPlaceDetailViewController.h"

#import "TKPlaceImageView.h"

#import "UIKit+TravelKit.h"
#import "TKPlace+TravelKit.h"


@interface TKMapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) NSArray<TKPlace *> *placesToDisplay;

@property (nonatomic, copy) NSString *filterCategory;

@end


@implementation TKMapViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Map", @"TravelKit UI - Screen title");

	self.navigationItem.backBarButtonItem = [UIBarButtonItem emptyBarButtonItem];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Category"
		style:UIBarButtonItemStylePlain target:self action:@selector(categoryButtonTapped:)];

	_mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	_mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_mapView.delegate = self;
	_mapView.mapType = MKMapTypeStandard;
	_mapView.showsPointsOfInterest = NO;
	_mapView.showsBuildings = NO;
	[self.view addSubview:_mapView];

	_mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(51.5, -0.1), 2000000, 2000000);

	[self fetchData];
}



- (IBAction)categoryButtonTapped:(id)sender
{
	UIAlertController *sheet = [UIAlertController alertControllerWithTitle:
		@"Choose category" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	NSArray<NSString *> *categoryArray = @[ @"sightseeing", @"shopping",
		@"eating", @"discovering", @"playing", @"traveling", @"going_out",
		@"hiking", @"sports", @"relaxing" ];

	[sheet addAction:[UIAlertAction actionWithTitle:@"All" style:UIAlertActionStyleDestructive
	  handler:^(UIAlertAction * _Nonnull action) {
		_filterCategory = nil;
		[self fetchData];
	}]];

	for (NSString *slug in categoryArray)
	{
		NSString *title = [TKPlace localisedNameForCategorySlug:slug];
		if (!title) continue;
		[sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault
		  handler:^(UIAlertAction * _Nonnull action) {
			_filterCategory = slug;
			[self fetchData];
		}]];
	}

	[sheet addAction:[UIAlertAction actionWithTitle:@"Close"
		style:UIAlertActionStyleCancel handler:nil]];

	sheet.popoverPresentationController.barButtonItem = sender;

	[self presentViewController:sheet animated:YES completion:nil];
}

- (void)reloadData
{
	static NSLock *lock = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		lock = [NSLock new];
	});

	[lock lock];

	NSArray *annotations = [[TravelKit sharedKit]
		spreadedAnnotationsForPlaces:_placesToDisplay
			mapRegion:_mapView.region mapViewSize:_mapView.bounds.size];

	NSMutableArray *toAdd = [NSMutableArray array];
	NSMutableArray *toKeep = [NSMutableArray array];
	NSMutableArray *toRemove = [NSMutableArray array];

	[[TravelKit sharedKit] interpolateNewAnnotations:annotations oldAnnotations:
		_mapView.annotations toAdd:toAdd toKeep:toKeep toRemove:toRemove];

	dispatch_async(dispatch_get_main_queue(), ^{
		[_mapView removeAnnotations:toRemove];
		[_mapView addAnnotations:toAdd];
	});

	[lock unlock];
}

- (void)fetchData
{
	static uint32_t i = 0;

	uint32_t current = arc4random();
	i = current;

	double zoom = [self zoomLevel];

	TKPlacesQuery *query = [TKPlacesQuery new];
	query.levels = TKPlaceLevelPOI;
	query.bounds = [[TKMapRegion alloc] initWithCoordinateRegion:_mapView.region];
	query.limit = @512;

	if (_filterCategory)
		query.categories = @[ _filterCategory ];

	if (zoom < 7.0)
	{
		query.levels = TKPlaceLevelCity | TKPlaceLevelTown;
		query.categories = nil;
		query.tags = nil;
		query.searchTerm = nil;
	}

	[[TravelKit sharedKit] placesForQuery:query completion:^(NSArray<TKPlace *> *places, NSError *error) {

		if (current != i) return;

		static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

		pthread_mutex_lock(&mutex);

		_placesToDisplay = places ?: @[ ];

		[self reloadData];

		pthread_mutex_unlock(&mutex);
	}];
}

-(double)zoomLevel
{
	static double maxLevels = -1.0;

	if (maxLevels < 0.0)
		maxLevels = log2(MKMapSizeWorld.width / 256.0);

	CLLocationDegrees longitudeDelta = _mapView.region.span.longitudeDelta;
	CGFloat mapWidthInPixels = _mapView.bounds.size.width;
	double zoomScale = longitudeDelta * 85445659.44705395 * M_PI / (180.0 * mapWidthInPixels);
	double zoomer = maxLevels - log2(zoomScale);
	if (zoomer < 0) zoomer = 0;

	return zoomer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	TKMapPlaceAnnotation *anno = annotation;

	if (![anno isKindOfClass:[TKMapPlaceAnnotation class]] || !anno.place) return nil;

	TKPlace *place = anno.place;
	CGFloat size = anno.pixelSize;

	MKAnnotationView *v = [[MKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
	v.userInteractionEnabled = YES;
	v.backgroundColor = [UIColor colorFromRGB:[place displayableHexColor]];
	v.layer.cornerRadius = floor(size/2);

	if (size > 30)
	{
		TKPlaceImageView *img = [[TKPlaceImageView alloc] initWithFrame:v.bounds];
		img.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
			UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		img.width -= 6; img.height -= 6;
		img.layer.cornerRadius = img.width/2;
		img.layer.masksToBounds = YES;
		[v addCenteredSubview:img];
		[img setImageForPlace:place withSize:CGSizeMake(150, 150)];
	}

	return v;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	TKMapPlaceAnnotation *anno = view.annotation;

	if (![anno isKindOfClass:[TKMapPlaceAnnotation class]] || !anno.place) return;

	TKPlaceDetailViewController *vc = [[TKPlaceDetailViewController alloc] initWithPlace:anno.place];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
		nc.modalPresentationStyle = UIModalPresentationFormSheet;
		nc.preferredContentSize = CGSizeMake(440, 560);
		[self presentViewController:nc animated:YES completion:nil];
	}
	else [self.navigationController pushViewController:vc animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self fetchData];
}


@end
