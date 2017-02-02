//
//  DestinationManager.h
//  Tripomatic
//
//  Created by Ondra Beneš on 7/26/12.
//  Copyright (c) 2012 Trinerdis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <TravelCore/Activity.h>


@interface DestinationManager : NSObject

/** Singleton */
+ (DestinationManager *)defaultManager;
- (instancetype)init OBJC_UNAVAILABLE("Use [DestinationManager defaultManager].");

- (Activity *)destinationWithID:(NSString *)destinationID;

// Updating
- (void)saveDestination:(Activity *)destination;
- (void)batchSaveDestinations:(NSArray *)destinations;

// Collections
- (NSArray *)allDestinations;
- (NSArray *)destinationsForTripWithID:(NSString *)tripID;
- (NSArray *)suggestedDestinationsForTripWithID:(NSString *)tripID;
- (NSArray *)destinationsWithinRegion:(MKCoordinateRegion)region;

- (NSArray *)destinationsFromArrayOfIDs:(NSArray *)destinationIDs;
- (Activity *)majorDestinationFromArray:(NSArray *)destinations;

// Search
- (NSArray *)searchDestinationsWithString:(NSString *)searchString limit:(NSUInteger)limit;

// Templates stuff
- (NSArray *)templatesForDestinationWithID:(NSString *)destinationID;
- (void)fetchTemplatesForDestinationWithID:(NSString *)destinationID completion:(void (^)(NSArray *))completion;

// Car Hire stuff
- (NSArray *)carHirePlacesForDestinationWithID:(NSString *)destinationID;
- (void)fetchCarHirePlacesForDestinationWithID:(NSString *)destinationID completion:(void (^)(NSArray *))completion;

@end
