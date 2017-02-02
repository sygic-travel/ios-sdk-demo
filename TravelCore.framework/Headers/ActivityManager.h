//
//  ActivityManager.h
//  Tripomatic
//
//  Created by Ondra Beneš on 7/26/12.
//  Refactored by Michal Zelinka on 21/1/14.
//  Copyright (c) 2014 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import <TravelCore/Activity.h>
#import <TravelCore/ActivityQuery.h>
#import <TravelCore/ActivityUserData.h>

#import <TravelCore/BatchActivityUpdateInfo.h>


typedef NS_ENUM(NSUInteger, ActivityPlannedState)
{
	ActivityPlannedStateNotFound = 0,
	ActivityPlannedStateFound,
	ActivityPlannedStateFoundToday,
	ActivityPlannedStateFoundMultiple,
};


@class ActivityQuery;


@interface ActivityManager : NSObject

@property (nonatomic, strong) NSOperationQueue *workingQueue;


/** Shared sigleton */

+ (ActivityManager *)defaultManager;
- (instancetype)init OBJC_UNAVAILABLE("Use [ActivityManager defaultManager].");


/** Single object fetching */

- (Activity *)activityWithID:(NSString *)activityID;
- (id)detailForActivity:(Activity *)activity;


/** Activity User Ddata */

- (ActivityUserData *)userDataForActivity:(Activity *)activity inTripWithID:(NSString *)tripID;
- (NSDictionary<NSString *, ActivityUserData *> *)userDataForActivitiesInTripWithID:(NSString *)tripID;


/** Favourites */

- (NSArray<NSString *> *)favouritesForUserID:(NSString *)userID;
- (void)addItemToFavouritesWithID:(NSString *)itemID forUserID:(NSString *)userID;
- (void)removeItemFromFavouritesWithID:(NSString *)itemID forUserID:(NSString *)userID;


/** Collections */

- (NSArray<Activity *> *)activitiesForQuery:(ActivityQuery *)query; // Preferred

- (NSArray<Activity *> *)activitiesAround:(CLLocation *)location radius:(CGFloat)radius
	limit:(NSInteger)limit ordered:(BOOL)ordered withCategory:(NSString *)categorySlug;
- (NSArray<Activity *> *)activitiesAround:(CLLocation *)location radius:(CGFloat)radius
	limit:(NSInteger)limit ordered:(BOOL)ordered withCategory:(NSString *)categorySlug type:(ActivityType)type;
- (NSArray<Activity *> *)bestActivitiesAround:(CLLocation *)location radius:(CGFloat)radius limit:(NSInteger)limit;

- (NSArray<BookableReview *> *)reviewsForActivityWithID:(NSString *)activityID;
- (NSArray<Activity *> *)locationsForActivityWithID:(NSString *)activityID;
- (NSArray<Reference *> *)referencesForActivityWithID:(NSString *)activityID;

- (NSArray<Activity *> *)activitiesForArrayOfIDs:(NSArray *)arrayOfIDs;

- (NSArray<Activity *> *)bestActivitiesForDestination:(Activity *)destination limit:(NSInteger)limit;
- (NSArray<Activity *> *)bestActivitiesForDestination:(Activity *)destination limit:(NSInteger)limit type:(ActivityType)type;

- (NSArray<Activity *> *)customActivitiesForUserWithID:(NSString *)userID;


/** Data object management */

- (void)saveActivity:(Activity *)activity;
- (void)saveActivityUserData:(ActivityUserData *)userData;
- (void)batchSaveActivities:(NSArray<Activity *> *)activities;
- (void)batchSaveActivities:(NSArray<Activity *> *)activities replace:(BOOL)replace;
- (void)batchSaveActivitiesUserData:(NSArray *)dataArray;
- (void)changeIDOfActivityWithID:(NSString *)activityID toID:(NSString *)toID;
- (void)removeActivity:(Activity *)activity;
- (NSSet *)missingActivityIDs;
- (NSSet *)missingActivityIDsFromArray:(NSArray *)itemIDs;


/** Caches */

- (void)invalidateActivityCaches;


/** Custom stuff */

- (NSArray<Activity *> *)activitiesForTripWithID:(NSString *)tripID;
- (NSArray<Activity *> *)activitiesWithNoImageAround:(CLLocation *)location withRadius:(CLLocationDistance)radius;


/** Batch Activity update info */

- (BatchActivityUpdateInfo *)batchActivityUpdateInfoForDestinationID:(NSString *)destinationID activityType:(ActivityType)type;
- (void)saveBatchActivityUpdateInfo:(BatchActivityUpdateInfo *)updateInfo;


/** Machine translation */

- (void)translationForActivity:(Activity *)activity completion:(void (^)(id))completion;


/** Speech synthesis */

- (NSString *)speechSynthesisVoiceCodeForLocationWithID:(NSString *)locationID;

@end
