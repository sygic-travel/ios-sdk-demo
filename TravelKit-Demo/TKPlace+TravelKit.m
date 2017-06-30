//
//  TKPlace+TravelKit.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 04/05/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKPlace+TravelKit.h"

@implementation TKPlace (TravelKit)

+ (NSString *)localisedNameForCategory:(TKPlaceCategory)category
{
	NSDictionary *displayNames = @{
		@(TKPlaceCategorySightseeing): NSLocalizedString(@"Sightseeing", @"TravelKit - Category name"),
		@(TKPlaceCategoryShopping): NSLocalizedString(@"Shopping", @"TravelKit - Category name"),
		@(TKPlaceCategoryEating): NSLocalizedString(@"Restaurants", @"TravelKit - Category name"),
		@(TKPlaceCategoryDiscovering): NSLocalizedString(@"Museums", @"TravelKit - Category name"),
		@(TKPlaceCategoryPlaying): NSLocalizedString(@"Family", @"TravelKit - Category name"),
		@(TKPlaceCategoryTravelling): NSLocalizedString(@"Transport", @"TravelKit - Category name"),
		@(TKPlaceCategoryGoingOut): NSLocalizedString(@"Nightlife", @"TravelKit - Category name"),
		@(TKPlaceCategoryHiking): NSLocalizedString(@"Outdoors", @"TravelKit - Category name"),
		@(TKPlaceCategorySports): NSLocalizedString(@"Sports", @"TravelKit - Category name"),
		@(TKPlaceCategoryRelaxing): NSLocalizedString(@"Relaxation", @"TravelKit - Category name"),
		@(TKPlaceCategorySleeping): NSLocalizedString(@"Accommodation", @"TravelKit - Category name"),
	};

	return displayNames[@(category)];
}


- (NSArray<NSString *> *)localisedCategories
{
	NSMutableArray *localised = [NSMutableArray arrayWithCapacity:3];

	for (TKPlaceCategory c = TKPlaceCategorySightseeing; c <= TKPlaceCategorySleeping; c <<= 1)
	{
		if (!(self.categories & c)) continue;
		NSString *cat = [self.class localisedNameForCategory:c];
		if (cat) [localised addObject:cat];
	}

	return localised;
}

@end
