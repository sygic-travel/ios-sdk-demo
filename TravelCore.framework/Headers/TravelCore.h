//
//  TravelCore.h
//  TravelCore
//
//  Created by Michal Zelinka on 27/01/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for TravelCore.
FOUNDATION_EXPORT double TravelCoreVersionNumber;

//! Project version string for TravelCore.
FOUNDATION_EXPORT const unsigned char TravelCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TravelCore/PublicHeader.h>

#import <TravelCore/Activity.h>
#import <TravelCore/Activity+ActivityFilter.h>
#import <TravelCore/ActivityDetail.h>
#import <TravelCore/ActivityManager.h>
#import <TravelCore/ActivityQuery.h>
#import <TravelCore/ActivityUpdateOperation.h>
#import <TravelCore/ActivityUserData.h>
#import <TravelCore/API.h>
#import <TravelCore/APIConnection.h>
#import <TravelCore/BatchActivityUpdateInfo.h>
#import <TravelCore/BatchActivityUpdateOperation.h>
#import <TravelCore/BatchActivityUpdater.h>
#import <TravelCore/ConnectionManager.h>
#import <TravelCore/DestinationManager.h>
#import <TravelCore/FMDatabase.h>
#import <TravelCore/FMDatabaseAdditions.h>
#import <TravelCore/FMDatabasePool.h>
#import <TravelCore/FMDatabaseQueue.h>
#import <TravelCore/FMDB.h>
#import <TravelCore/FMResultSet.h>
#import <TravelCore/LoadFeaturesOperation.h>
#import <TravelCore/MapAnnotation.h>
#import <TravelCore/MapRegionWrapper.h>
#import <TravelCore/MapWorkers.h>
#import <TravelCore/MediaManager.h>
#import <TravelCore/Medium.h>
#import <TravelCore/NSDate+Tripomatic.h>
#import <TravelCore/NSObject+Parsing.h>
#import <TravelCore/PlanningManager.h>
#import <TravelCore/Reachability.h>
#import <TravelCore/Reference.h>
#import <TravelCore/TravelCore.h>
#import <TravelCore/Trip.h>
#import <TravelCore/UserSettings.h>
#import <TravelCore/Utils.h>
#import <TravelCore/WeatherManager.h>
