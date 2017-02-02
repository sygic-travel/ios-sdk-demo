//
//  MediaManager.m
//  Tripomatic
//
//  Created by Michal Zelinka on 08/09/15.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TravelCore/Medium.h>

#define MediaWithItemIDPair(media, itemID)    @{ @"media": media, @"itemID": itemID }


@interface MediaManager : NSObject

@property (atomic, strong) NSOperationQueue *mediaFetchQueue;
@property (nonatomic, readonly) NSString *mediaCachePath;

/** Singleton method */
- (instancetype)init __attribute__((unavailable("Use [MediaManager defaultManager].")));
+ (MediaManager *)defaultManager;

// Media getting
- (NSArray<Medium *> *)mediaForItemWithID:(NSString *)itemID;

// Media saving
- (void)batchSaveMedia:(NSArray *)media forItemWithID:(NSString *)itemID;
- (void)batchSaveMediaWithItemIDPairs:(NSArray *)pairs;
- (BOOL)deleteMediaLinksForItemWithID:(NSString *)itemID;

// Images-specific stuff
- (Medium *)imageForItemWithID:(NSString *)itemID type:(ImageType)type;
- (NSArray<Medium *> *)imagesForItemWithID:(NSString *)itemID type:(ImageType)type;

// Videos-specific stuff
- (Medium *)previewVideoForItemWithID:(NSString *)itemID;

// Direct data getting
- (NSString *)filenameForMedium:(Medium *)medium type:(ImageType)type;
- (NSString *)imageFilenameForItemWithID:(NSString *)itemID type:(ImageType)type;
- (UIImage *)imageFromCacheForMedium:(Medium *)medium type:(ImageType)type;
- (UIImage *)imageFromCacheForItemWithID:(NSString *)itemID type:(ImageType)type;

// Direct data saving
- (void)saveImage:(UIImage *)image toCacheForMedium:(Medium *)medium type:(ImageType)type;
- (void)saveImage:(UIImage *)image toCacheForItemWithID:(NSString *)itemID type:(ImageType)type;

@end
