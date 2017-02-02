//
//  ActivityFilter.h
//  Tripomatic
//
//  Created by Michal Zelinka on 2/1/14.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/Activity.h>

typedef NS_ENUM(NSUInteger, ActivityFilter)
{
	////
	// General use
	////
	kActivityFilterAll = 0,
	kActivityFilterAround, // optional
	kActivityFilterInTrip,
	kActivityFilterPopular,
	kActivityFilterFavourites,
	kActivityFilterCustom,
	kActivityFilterItemType,
	kActivityFilterTag,
	////
	// Attractions
	////
	kActivityFilterSightseeing,
	kActivityFilterShopping,
	kActivityFilterEating,
	kActivityFilterDiscovering,
	kActivityFilterPlaying,
	kActivityFilterTravelling,
	kActivityFilterGoingOut,
	kActivityFilterHiking,
	kActivityFilterSports,
	kActivityFilterRelaxing,
	kActivityFilterSleeping,
	////
	// Activities
	////
//	kActivityFilterAirHelicopter,
//	kActivityFilterCruisesSailingWater,
//	kActivityFilterCultural,
//	kActivityFilterDayTrip,
//	kActivityFilterFamilyFriendly,
//	kActivityFilterFoodWine,
//	kActivityFilterHolidaySeasonal,
//	kActivityFilterLuxurySpecial,
//	kActivityFilterMultiday,
//	kActivityFilterOutdoorActivities,
//	kActivityFilterPrivateCustom,
//	kActivityFilterShoppingFashion,
//	kActivityFilterShoreExcursions,
//	kActivityFilterShowConcert,
//	kActivityFilterSightseeingTickets,
//	kActivityFilterThemePark,
//	kActivityFilterToursSightseeing,
//	kActivityFilterTransfers,
//	kActivityFilterViatorVIP,
//	kActivityFilterWalkingBiking,
//	kActivityFilterWaterSports,
//	kActivityFilterWeddings,
	////
	// Hotels
	////
	kActivityFilterHotelType,
	kActivityFilterStarRating,
	kActivityFilterPriceRange,
	kActivityFilterCustomerRating,
	//
	kActivityFilterAirConditioning,
	kActivityFilterAirportShuttle,
	kActivityFilterAccessible,
	kActivityFilterFamilyRooms,
	kActivityFilterFitness,
	kActivityFilterFreeParking,
	kActivityFilterFreeWiFi,
	kActivityFilterNonSmoking,
	kActivityFilterPool,
	kActivityFilterPets,
	kActivityFilterHotelRestaurant,
	kActivityFilterWellness,
	////
};

typedef NS_ENUM(NSUInteger, HotelPrice)
{
	HotelPriceAll = 0,
	HotelPriceBudget,
	HotelPriceMidRange,
	HotelPriceSplurge,
};

typedef NS_OPTIONS(NSUInteger, HotelType)
{
	HotelTypeAll       = (0),
	HotelTypeHotel     = (1 << 0),
	HotelTypeHostel    = (1 << 1),
	HotelTypeApartment = (1 << 2),
};

typedef NS_ENUM(NSUInteger, HotelCategory)
{
	HotelCategoryNoStar = 0,
	HotelCategory1Star  = 1,
	HotelCategory2Stars = 2,
	HotelCategory3Stars = 3,
	HotelCategory4Stars = 4,
	HotelCategory5Stars = 5,
};

typedef NS_ENUM(NSUInteger, ItemFavouritesState)
{
	ItemFavouritesStateNotFound = 0,
	ItemFavouritesStateFound,
};

#define ItemTypes      @[ @(kActivityFilterCustom), @(kActivityFilterFavourites), @(kActivityFilterInTrip) ]
#define HotelPrices    @[ @(HotelPriceAll), @(HotelPriceBudget), @(HotelPriceMidRange), @(HotelPriceSplurge) ]
#define HotelTypes     @[ @(HotelTypeHotel), @(HotelTypeHostel), @(HotelTypeApartment) ]
#define HotelRatings   @[ @9, @8, @7, @6, @0 ]
#define HotelPriceMin  0
#define HotelPriceMax  99999
#define HotelPriceBudgetMin HotelPriceMin
#define HotelPriceBudgetMax 50
#define HotelPriceMidRangeMin 25
#define HotelPriceMidRangeMax 100
#define HotelPriceSplurgeMin 100
#define HotelPriceSplurgeMax HotelPriceMax

@interface Activity (ActivityFilter)

// App-wide helpers
+ (NSString *)categorySlugForFilter:(ActivityFilter)filter;
+ (NSArray *)tagsForFilter:(ActivityFilter)filter;
+ (NSString *)tagForHotelType:(HotelType)type;
+ (NSString *)titleForFilter:(ActivityFilter)filter;
+ (NSString *)titleForHotelType:(HotelType)type;
+ (NSString *)descriptionForFilter:(ActivityFilter)filter;
+ (NSString *)originalCategoryTitleForSlug:(NSString *)categorySlug;
+ (BOOL)isCategoryTag:(NSString *)tag;
+ (NSString *)iconNameForFilter:(ActivityFilter)filter;
+ (NSString *)iconNameForHotelType:(HotelType)type;
+ (NSString *)viewTitleForFilter:(ActivityFilter)filter;
+ (NSString *)analyticsScreenNameForFilter:(ActivityFilter)filter;
+ (ActivityFilter)filterForFacilityTag:(NSString *)facility;
+ (NSString *)facilityTitleForTag:(NSString *)tag;
+ (NSDictionary *)reservedTags;

@end
