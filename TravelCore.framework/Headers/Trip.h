//
//  Trip.h
//  Tripomatic
//
//  Created by Pavel Zak on 12.3.12.
//  Refactored by Ondra Benes on 18.6.12.
//  Refactored again by Michal Zelinka on 28/09/2015.
//  Copyright (c) 2012 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/ActivityManager.h>

#define LOCAL_TRIP_PREFIX         "*trip:"
#define DEFAULT_TRIP_NAME_FORMAT  NSLocalizedString(@"Trip to %@", @"Default trip name pattern -- f.e. Trip to London")
#define DEFAULT_TRIP_NAME_PREFIX  [DEFAULT_TRIP_NAME_FORMAT stringByReplacingOccurrencesOfString:@"%@" withString:@""]
#define GENERIC_TRIP_NAME         NSLocalizedString(@"My Trip", @"Generic Trip name")

// Note: Trip name definitions need to be updated in .m to tranlate properly.

typedef NS_ENUM(NSUInteger, DirectionTransportType) {
	DirectionTransportTypeUnknown = 0,
	DirectionTransportTypeWalk,
	DirectionTransportTypeCar,
	DirectionTransportTypeFlight,
}; // ABI-EXPORTED

typedef NS_ENUM(NSUInteger, TripPrivacy) {
	TripPrivacyPrivate = 0,
	TripPrivacyShareable,
}; // ABI-EXPORTED

typedef NS_OPTIONS(NSUInteger, TripRights) {
	TripRightsNoRights    = (0),
	TripRightsEdit        = (1 << 0),
	TripRightsManage      = (1 << 1),
	TripRightsDelete      = (1 << 2),
	TripRightsAllRights   = TripRightsEdit | TripRightsManage | TripRightsDelete,
}; // ABI-EXPORTED


///////////////
#pragma mark - Transport matrix
///////////////


@interface TransportMatrix : NSObject

// Handled initializer
- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

// Serialization methods
- (NSDictionary *)asDictionary;

// Data getter
- (DirectionTransportType)transportTypeBetweenActivityWithID:(NSString *)firstID andActivityWithID:(NSString *)secondID;

// Data setter
- (void)setTransportType:(DirectionTransportType)transportType betweenActivityWithID:(NSString *)firstID
	   andActivityWithID:(NSString *)secondID;

@end


///////////////
#pragma mark - Trip Day model
///////////////


@interface TripDay : NSObject

/** Array of Item IDs */
@property (nonatomic, strong) NSMutableArray *items;

/** Array of Destination objects */
@property (nonatomic, readonly) NSArray *destinations;

// Set of (hopefully set) properties
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *dayName;
@property (nonatomic, copy) NSString *dayNumber;
@property (nonatomic, assign) NSUInteger dayIndex;
@property (nonatomic, assign) BOOL isToday;
@property (nonatomic, copy) NSString *previousDayHotelID;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) TransportMatrix *transportMatrix;

// Handled initializer
- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

// Serialization methods
- (NSDictionary *)asDictionary;

// Test for presence
- (BOOL)containsItem:(NSString *)poiID;
- (BOOL)containsItemOfType:(ActivityType)type;

// Insertion methods
- (void)addItem:(NSString *)poiID;

// Removal methods
- (void)removeItem:(NSString *)poiID;

// Helpers
- (NSString *)formattedDayName;

@end


///////////////
#pragma mark - Trip model
///////////////


@interface Trip : NSObject

@property (nonatomic, copy) NSString *ID NS_SWIFT_NAME(ID);
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, strong) NSDate *dateStart;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) TripPrivacy privacy;
@property (nonatomic, assign) TripRights rights;
@property (nonatomic, copy) NSString *ownerID, *userID; // Trip owner and Local record holder

@property (nonatomic, readonly) BOOL isEditable;
@property (nonatomic, readonly) BOOL isManageable;
@property (nonatomic, readonly) BOOL isDeletable;

/** Array of Trip Day objects */
@property (nonatomic, copy) NSArray<TripDay *> *days;

/** Array of Destination IDs */
@property (nonatomic, copy) NSArray<NSString *> *destinationIDs;

/** Set of suggested Destination IDs */
@property (nonatomic, copy) NSArray<NSString *> *suggestedDestinationIDs;

// Dirty flag for synchronization
@property (atomic, assign) BOOL changedSinceLastSynchronization;

/**
 * Init object from dictionary taken from API
 *
 * @param dictionary object from API
 * @return object with fully filled information
 */
- (instancetype)initFromReponseDictionary:(NSDictionary *)dictionary;

/**
 * Init object from dictionary taken from SQL
 *
 * @param dictionary object from database
 * @return object with filled information
 */
- (instancetype)initFromDatabase:(NSDictionary *)dictionary;

// API serialization methods
- (NSString *)asJSONString;

// Day workers
- (void)addNewDay;
- (void)removeDay:(TripDay *)day;

// Item workers
- (void)addItem:(NSString *)itemID toDay:(NSUInteger)dayIndex;
- (void)removeItem:(NSString *)itemID fromDay:(NSUInteger)dayIndex;
- (void)removeItem:(NSString *)itemID;

// Destination workers
- (void)addDestination:(Activity *)destination;
- (void)removeDestination:(Activity *)destination;

// User Data workers
- (void)setNote:(NSString *)note onDay:(NSUInteger)dayIndex;
- (void)setTransportMatrix:(TransportMatrix *)matrix onDay:(NSUInteger)dayIndex;

// Information providers
- (NSSet *)itemIDsInTrip;
- (BOOL)containsItemWithID:(NSString *)itemID;
- (NSArray *)indexesOfDaysContainingItemWithID:(NSString *)itemID;
- (ActivityPlannedState)plannedStateOfItemWithID:(NSString *)itemID;
- (BOOL)isEmpty;

// Returns Trip day object with additional properties set
- (TripDay *)dayWithDateAtIndex:(NSUInteger)index;

// Duration string
- (NSString *)formattedDuration;

// Manipulation methods
- (BOOL)moveDayAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex;
- (BOOL)moveActivityAtDay:(NSUInteger)dayIndex withIndex:(NSUInteger)activityIndex toDay:(NSUInteger)destDayIndex withIndex:(NSUInteger)destIndex;
- (BOOL)removeActivityAtDay:(NSUInteger)dayIndex withIndex:(NSUInteger)activityIndex;

@end


///////////////
#pragma mark - Trip info
///////////////


@interface TripInfo : NSObject

@property (nonatomic, copy) NSString *ID NS_SWIFT_NAME(ID);
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ownerID, *userID;
@property (nonatomic) NSUInteger version;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *lastUpdate;

@property (nonatomic) NSUInteger daysCount;
@property (nonatomic, copy) NSArray *destinations;
@property (nonatomic, copy) NSArray *suggestedDestinations;

@property (nonatomic, readonly) BOOL isEditable;
@property (nonatomic, readonly) BOOL isManageable;
@property (nonatomic, readonly) BOOL isDeletable;

@property (nonatomic, assign) TripPrivacy privacy;
@property (nonatomic, assign) TripRights rights;

@property (nonatomic, assign) BOOL changed;
@property (nonatomic, assign) BOOL deleted;

- (instancetype)initFromDatabaseDictionary:(NSDictionary *)dictionary;

@end


///////////////
#pragma mark - Trip collaborator model
///////////////


@interface TripCollaborator : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) NSURL *photoURL;
@property (atomic) BOOL accepted;
@property (atomic) BOOL hasWriteAccess;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
