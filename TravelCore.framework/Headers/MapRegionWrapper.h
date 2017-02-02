//
//  MapRegionWrapper.h
//  Tripomatic
//
//  Created by Michal Zelinka on 18/02/2016.
//  Copyright (c) 2016- Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


#pragma mark - Map Region wrapper


@interface MapRegionWrapper : NSObject

@property (nonatomic, assign) MKCoordinateRegion coordinateRegion;

@property (readonly) CLLocation *southWestPoint;
@property (readonly) CLLocation *northEastPoint;
@property (readonly) BOOL hasValidCoordinate;
@property (readonly) CLLocationDistance widthInKilometres;

- (instancetype)initWithMKCoordinateRegion:(MKCoordinateRegion)region;
- (instancetype)initWithSouthWestPoint:(CLLocation *)southWest northEastPoint:(CLLocation *)northEast;

- (BOOL)containsLocation:(CLLocation *)location;
- (void)invalidate;

@end
