//
//  MapAnnotation.h
//  Travel
//
//  Created by Michal Zelinka on 27/01/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface MapAnnotation : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (atomic, assign) CLLocationCoordinate2D coordinate;
@property (atomic, assign) BOOL enabled;

@end
